package com.ren.yinghui.backend.service.impl;

import com.ren.yinghui.backend.mapper.MarketMapper;
import com.ren.yinghui.backend.service.VmmMarketMakerService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Random;

@Service
public class VmmMarketMakerServiceImpl implements VmmMarketMakerService {
    private static final BigDecimal DRIFT = new BigDecimal("0.00006");
    private static final BigDecimal VOLATILITY = new BigDecimal("0.008");
    private static final BigDecimal HALF = new BigDecimal("0.5");
    private static final BigDecimal BOOK_SPACING = new BigDecimal("0.003");
    private static final BigDecimal MIN_PRICE = new BigDecimal("0.00010000");
    private static final int LEVELS_PER_SIDE = 10;
    private static final int HISTORY_KEEP_ROWS = 200;
    private static final int VMM_TRADES_KEEP_ROWS = 60;

    private final MarketMapper marketMapper;
    private final Random random = new Random();

    public VmmMarketMakerServiceImpl(MarketMapper marketMapper) {
        this.marketMapper = marketMapper;
    }

    @Override
    @Scheduled(fixedDelay = 2000, initialDelay = 2000)
    @Transactional
    public void tick() {
        List<MarketMapper.VmmMarketRow> markets = marketMapper.findTradableMarketRows();
        for (MarketMapper.VmmMarketRow market : markets) {
            BigDecimal nextPrice = nextPrice(market.currentSharePrice);
            BigDecimal change24h = nextPrice
                    .subtract(market.initialSharePrice)
                    .divide(market.initialSharePrice, 8, RoundingMode.HALF_UP)
                    .multiply(BigDecimal.valueOf(100))
                    .setScale(4, RoundingMode.HALF_UP);

            BigDecimal volumeDelta = BigDecimal.ZERO;
            if (random.nextDouble() < 0.65) {
                BigDecimal size = BigDecimal.valueOf(50 + random.nextInt(400)).setScale(6, RoundingMode.UNNECESSARY);
                BigDecimal tradePrice = nextPrice
                        .multiply(BigDecimal.ONE.add(BigDecimal.valueOf((random.nextDouble() - 0.5) * 0.001)))
                        .setScale(8, RoundingMode.HALF_UP);
                volumeDelta = tradePrice.multiply(size).setScale(2, RoundingMode.HALF_UP);
                String side = random.nextDouble() < 0.52 ? "buy" : "sell";
                marketMapper.insertTrade(market.artworkId, null, null, side, tradePrice, size, volumeDelta, "vmm");
                marketMapper.deleteOldVmmTrades(market.artworkId, VMM_TRADES_KEEP_ROWS);
            }

            marketMapper.updateMarketPrice(market.artworkId, nextPrice, change24h, volumeDelta);
            marketMapper.insertPriceHistory(market.artworkId, nextPrice);
            marketMapper.deleteOldPriceHistory(market.artworkId, HISTORY_KEEP_ROWS);
            rebuildOrderBook(market.artworkId, nextPrice);
        }
    }

    private BigDecimal nextPrice(BigDecimal currentPrice) {
        double sigma = VOLATILITY.doubleValue();
        double drift = DRIFT.subtract(HALF.multiply(VOLATILITY.multiply(VOLATILITY))).doubleValue();
        double multiplier = Math.exp(drift + sigma * random.nextGaussian());
        BigDecimal next = currentPrice.multiply(BigDecimal.valueOf(multiplier)).setScale(8, RoundingMode.HALF_UP);
        return next.max(MIN_PRICE);
    }

    private void rebuildOrderBook(Long artworkId, BigDecimal price) {
        marketMapper.deleteOpenVmmOrders(artworkId);
        for (int level = 1; level <= LEVELS_PER_SIDE; level++) {
            BigDecimal levelSpacing = BOOK_SPACING.multiply(BigDecimal.valueOf(level));
            BigDecimal jitter = BigDecimal.valueOf(random.nextDouble() * 0.0004);
            BigDecimal bidPrice = price.multiply(BigDecimal.ONE.subtract(levelSpacing).subtract(jitter))
                    .setScale(8, RoundingMode.HALF_UP);
            BigDecimal askPrice = price.multiply(BigDecimal.ONE.add(levelSpacing).add(jitter))
                    .setScale(8, RoundingMode.HALF_UP);
            BigDecimal bidSize = BigDecimal.valueOf(500 + random.nextInt(3000)).setScale(6, RoundingMode.UNNECESSARY);
            BigDecimal askSize = BigDecimal.valueOf(500 + random.nextInt(3000)).setScale(6, RoundingMode.UNNECESSARY);
            marketMapper.insertVmmOrder(artworkId, "bid", bidPrice, bidSize);
            marketMapper.insertVmmOrder(artworkId, "ask", askPrice, askSize);
        }
    }
}
