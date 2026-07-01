package com.ren.yinghui.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ren.yinghui.backend.mapper.VmmMapper;
import jakarta.annotation.PostConstruct;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Virtual Market Maker — runs Geometric Brownian Motion every 2 s.
 *
 * Each tick:
 *  1. Updates in-memory prices (fast path for PnL / liquidation checks)
 *  2. Writes new price to artwork_markets.current_share_price (DB)
 *  3. Appends a row to artwork_price_history (DB)
 *  4. Pushes a 'vmm' SSE event to all connected browser clients
 *
 * History snapshots written every HISTORY_INTERVAL ticks (~30 s at 2 s/tick)
 * to avoid flooding artwork_price_history with a row every 2 seconds per artwork.
 */
@Service
public class VmmService {

    // GBM parameters — same calibration as the original frontend trading.js
    private static final double MU             = 6e-5;
    private static final double SIGMA          = 8e-3;
    private static final int    MAX_MEMORY_HISTORY = 200;   // in-memory ring buffer
    private static final int    HISTORY_INTERVAL   = 15;    // write DB history every 15 ticks (30 s)

    private final VmmMapper    vmmMapper;
    private final ObjectMapper mapper = new ObjectMapper();

    // In-memory state (fast access for SSE / PnL)
    private final ConcurrentHashMap<Long, Double>               prices    = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<Long, List<double[]>>       memory    = new ConcurrentHashMap<>(); // [timestamp, price]
    private final ConcurrentHashMap<Long, Double>               prices24hAgo = new ConcurrentHashMap<>();
    private final List<SseEmitter>                              emitters  = new CopyOnWriteArrayList<>();
    private final AtomicInteger                                 tickCount = new AtomicInteger(0);

    public VmmService(VmmMapper vmmMapper) {
        this.vmmMapper = vmmMapper;
    }

    @PostConstruct
    public void init() {
        List<Map<String, Object>> rows = vmmMapper.findTradableArtworkPrices();
        if (rows.isEmpty()) {
            // DB not seeded yet — use hardcoded defaults so VMM can still start
            Map<Long, Double> defaults = Map.of(
                1L, 6.90, 2L, 2.80, 3L, 1.92, 4L, 3.20, 5L, 1.40, 6L, 0.88
            );
            defaults.forEach((id, p) -> {
                prices.put(id, p);
                memory.put(id, Collections.synchronizedList(new ArrayList<>()));
                prices24hAgo.put(id, p);
            });
        } else {
            rows.forEach(row -> {
                Long id = toLong(row.get("artworkId"));
                double p = toDouble(row.get("price"));
                prices.put(id, p);
                memory.put(id, Collections.synchronizedList(new ArrayList<>()));
                prices24hAgo.put(id, p);
            });
        }
    }

    @Scheduled(fixedRate = 2000)
    public void tick() {
        int tick = tickCount.incrementAndGet();
        long ts = System.currentTimeMillis();
        ThreadLocalRandom rng = ThreadLocalRandom.current();
        boolean writeHistory = (tick % HISTORY_INTERVAL == 0);

        Map<Long, Double> newPrices = new HashMap<>();
        List<Map<String, Object>> ticks = new ArrayList<>();

        prices.forEach((id, p) -> {
            double z    = rng.nextGaussian();
            double newP = Math.max(1e-4, p * Math.exp((MU - 0.5 * SIGMA * SIGMA) + SIGMA * z));
            prices.put(id, newP);
            newPrices.put(id, newP);

            // In-memory ring buffer
            List<double[]> hist = memory.get(id);
            if (hist != null) {
                hist.add(new double[]{ts, newP});
                if (hist.size() > MAX_MEMORY_HISTORY) hist.remove(0);
            }

            // DB: update live price
            try { vmmMapper.updateCurrentPrice(id, newP); } catch (Exception ignored) {}

            // DB: price history (throttled)
            if (writeHistory) {
                try { vmmMapper.insertPriceHistory(id, newP); } catch (Exception ignored) {}
                // Recalculate 24h change
                double base = prices24hAgo.getOrDefault(id, newP);
                double pct  = base > 0 ? (newP - base) / base * 100 : 0;
                try { vmmMapper.updateChange24h(id, pct); } catch (Exception ignored) {}
            }

            ticks.add(Map.of("artworkId", id, "t", ts, "p", newP));
        });

        // Rotate 24h reference price every ~24 h (43200 ticks at 2 s each)
        if (tick % 43_200 == 0) prices24hAgo.putAll(newPrices);

        // Push SSE event to all connected clients
        Map<String, Object> payload;
        try {
            payload = Map.of("prices", newPrices, "ticks", ticks, "ts", ts);
        } catch (Exception e) {
            return;
        }
        List<SseEmitter> dead = new ArrayList<>();
        for (SseEmitter emitter : emitters) {
            try {
                emitter.send(SseEmitter.event().name("vmm").data(mapper.writeValueAsString(payload)));
            } catch (Exception e) {
                dead.add(emitter);
            }
        }
        emitters.removeAll(dead);
    }

    /** Register a new SSE client; immediately sends the current price snapshot. */
    public SseEmitter subscribe() {
        SseEmitter emitter = new SseEmitter(0L);
        emitters.add(emitter);
        emitter.onCompletion(() -> emitters.remove(emitter));
        emitter.onTimeout(()    -> emitters.remove(emitter));
        emitter.onError(e       -> emitters.remove(emitter));
        try {
            Map<String, Object> snapshot = Map.of(
                "prices", new HashMap<>(prices), "ticks", List.of(), "ts", System.currentTimeMillis()
            );
            emitter.send(SseEmitter.event().name("vmm").data(mapper.writeValueAsString(snapshot)));
        } catch (Exception ignored) {}
        return emitter;
    }

    public Map<Long, Double> getPrices() { return new HashMap<>(prices); }

    // ── helpers ───────────────────────────────────────────────────────────────

    private static Long toLong(Object o) {
        if (o instanceof Number n) return n.longValue();
        return Long.valueOf(o.toString());
    }

    private static double toDouble(Object o) {
        if (o instanceof Number n) return n.doubleValue();
        return Double.parseDouble(o.toString());
    }
}
