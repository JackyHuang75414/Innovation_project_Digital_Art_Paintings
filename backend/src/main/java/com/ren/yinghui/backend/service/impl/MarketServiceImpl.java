package com.ren.yinghui.backend.service.impl;

import com.ren.yinghui.backend.dto.OpenPerpDTO;
import com.ren.yinghui.backend.dto.SpotTradeDTO;
import com.ren.yinghui.backend.dto.TpSlDTO;
import com.ren.yinghui.backend.mapper.MarketMapper;
import com.ren.yinghui.backend.service.MarketService;
import com.ren.yinghui.backend.utils.ThreadLocalUtil;
import com.ren.yinghui.backend.vo.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class MarketServiceImpl implements MarketService {
    private static final BigDecimal BTC_PRICE = new BigDecimal("64800.00");

    private final MarketMapper marketMapper;

    public MarketServiceImpl(MarketMapper marketMapper) {
        this.marketMapper = marketMapper;
    }

    @Override
    public List<MarketArtworkVO> listArtworks() {
        List<MarketArtworkVO> list = marketMapper.findMarketArtworks();
        list.forEach(this::attachTags);
        return list;
    }

    @Override
    public MarketArtworkVO getArtwork(Long id) {
        MarketArtworkVO artwork = marketMapper.findMarketArtworkById(id);
        if (artwork != null) {
            attachTags(artwork);
        }
        return artwork;
    }

    @Override
    public OrderBookVO getOrderBook(Long id) {
        OrderBookVO vo = new OrderBookVO();
        vo.setBids(marketMapper.findOrderBookSide(id, "bid"));
        vo.setAsks(marketMapper.findOrderBookSide(id, "ask"));
        return vo;
    }

    @Override
    public List<TradeExecutionVO> getTrades(Long id) {
        return marketMapper.findTrades(id);
    }

    @Override
    public List<PricePointVO> getPriceHistory(Long id) {
        return marketMapper.findPriceHistory(id);
    }

    @Override
    public WalletVO getCurrentWallet() {
        return walletForUser(currentUserId());
    }

    @Override
    @Transactional
    public SpotTradeVO executeSpot(SpotTradeDTO dto) {
        Long userId = currentUserId();
        Long artworkId = dto.getArtworkId();
        BigDecimal price = currentPrice(artworkId);
        SpotTradeVO vo = new SpotTradeVO();
        vo.setOk(false);
        vo.setPrice(price);

        if ("buy".equalsIgnoreCase(dto.getSide())) {
            BigDecimal usdAmount = dto.getAmount();
            BigDecimal shares = usdAmount.divide(price, 6, RoundingMode.DOWN);
            if (marketMapper.updateUsdBalance(userId, usdAmount.negate()) == 0) {
                vo.setMsg("Insufficient USD balance");
                vo.setWallet(walletForUser(userId));
                return vo;
            }
            marketMapper.upsertHolding(userId, artworkId, shares, price);
            marketMapper.insertTrade(artworkId, userId, null, "buy", price, shares, usdAmount, "spot");
            vo.setOk(true);
            vo.setShares(shares);
        } else if ("sell".equalsIgnoreCase(dto.getSide())) {
            BigDecimal shares = dto.getAmount();
            BigDecimal held = marketMapper.findHoldingQuantity(userId, artworkId);
            if (held == null || held.compareTo(shares) < 0) {
                vo.setMsg("Insufficient shares");
                vo.setWallet(walletForUser(userId));
                return vo;
            }
            BigDecimal proceeds = shares.multiply(price).setScale(2, RoundingMode.HALF_UP);
            marketMapper.upsertHolding(userId, artworkId, shares.negate(), price);
            marketMapper.updateUsdBalance(userId, proceeds);
            marketMapper.insertTrade(artworkId, null, userId, "sell", price, shares, proceeds, "spot");
            vo.setOk(true);
            vo.setProceeds(proceeds);
        } else {
            throw new IllegalArgumentException("side must be buy or sell");
        }

        vo.setWallet(walletForUser(userId));
        return vo;
    }

    @Override
    @Transactional
    public PerpTradeVO openPerp(OpenPerpDTO dto) {
        Long userId = currentUserId();
        BigDecimal price = currentPrice(dto.getArtworkId());
        BigDecimal notional = dto.getMarginBtc()
                .multiply(BTC_PRICE)
                .multiply(BigDecimal.valueOf(dto.getLeverage()))
                .setScale(2, RoundingMode.HALF_UP);
        if (marketMapper.updateBtcBalance(userId, dto.getMarginBtc().negate()) == 0) {
            PerpTradeVO failed = new PerpTradeVO();
            failed.setOk(false);
            failed.setMsg("Insufficient BTC collateral");
            failed.setWallet(walletForUser(userId));
            return failed;
        }
        marketMapper.insertPerpPosition(userId, dto.getArtworkId(), dto.getSide(), notional, dto.getLeverage(), price, dto.getMarginBtc());
        marketMapper.insertTrade(dto.getArtworkId(), userId, null, dto.getSide().equals("long") ? "buy" : "sell", price,
                notional.divide(price, 6, RoundingMode.DOWN), notional, "perp");

        PerpTradeVO vo = new PerpTradeVO();
        vo.setOk(true);
        vo.setWallet(walletForUser(userId));
        return vo;
    }

    @Override
    @Transactional
    public PerpTradeVO closePerp(Long posId) {
        Long userId = currentUserId();
        PerpPositionVO pos = marketMapper.findOpenPerpPositionById(userId, posId);
        if (pos == null) {
            PerpTradeVO failed = new PerpTradeVO();
            failed.setOk(false);
            failed.setMsg("Position not found");
            failed.setWallet(walletForUser(userId));
            return failed;
        }
        BigDecimal current = currentPrice(pos.getArtworkId());
        BigDecimal direction = "long".equals(pos.getSide()) ? BigDecimal.ONE : BigDecimal.ONE.negate();
        BigDecimal pnlUsd = current.subtract(pos.getEntryPrice())
                .divide(pos.getEntryPrice(), 8, RoundingMode.HALF_UP)
                .multiply(pos.getNotional())
                .multiply(direction)
                .setScale(2, RoundingMode.HALF_UP);
        BigDecimal returnBtc = pos.getMarginBtc().add(pnlUsd.divide(BTC_PRICE, 8, RoundingMode.HALF_UP));
        if (returnBtc.compareTo(BigDecimal.ZERO) > 0) {
            marketMapper.updateBtcBalance(userId, returnBtc);
        }
        marketMapper.closePerpPosition(userId, posId);

        PerpTradeVO vo = new PerpTradeVO();
        vo.setOk(true);
        vo.setPnlUsd(pnlUsd);
        vo.setWallet(walletForUser(userId));
        return vo;
    }

    @Override
    @Transactional
    public TpSlOrderVO setTpSl(TpSlDTO dto) {
        Long userId = currentUserId();
        marketMapper.insertTpSl(userId, dto.getArtworkId(), dto.getType(), dto.getPosId(),
                dto.getTpPrice(), dto.getSlPrice(), dto.getQty());
        List<TpSlOrderVO> orders = marketMapper.findActiveTpSlOrders(userId);
        return orders.isEmpty() ? null : orders.get(0);
    }

    @Override
    public void cancelTpSl(Long id) {
        marketMapper.cancelTpSl(currentUserId(), id);
    }

    private void attachTags(MarketArtworkVO artwork) {
        artwork.setTags(marketMapper.findTagsByArtworkId(artwork.getId()));
    }

    private BigDecimal currentPrice(Long artworkId) {
        BigDecimal price = marketMapper.findCurrentPrice(artworkId);
        if (price == null) {
            throw new IllegalArgumentException("Market not found");
        }
        return price;
    }

    private WalletVO walletForUser(Long userId) {
        WalletVO wallet = marketMapper.findWallet(userId);
        if (wallet == null) {
            wallet = new WalletVO();
            wallet.setUsd(BigDecimal.ZERO);
            wallet.setBtc(BigDecimal.ZERO);
        }
        Map<Long, BigDecimal> shares = new HashMap<>();
        for (MarketMapper.PortfolioShareRow row : marketMapper.findShareRows(userId)) {
            shares.put(row.artworkId, row.quantity);
        }
        wallet.setShares(shares);
        wallet.setPerpPositions(marketMapper.findOpenPerpPositions(userId));
        wallet.setTpslOrders(marketMapper.findActiveTpSlOrders(userId));
        return wallet;
    }

    private Long currentUserId() {
        Map<String, Object> claims = ThreadLocalUtil.get();
        Object userId = claims.get("id");
        return userId instanceof Number number ? number.longValue() : Long.valueOf(userId.toString());
    }
}
