package com.ren.yinghui.backend.mapper;

import com.ren.yinghui.backend.vo.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;
import java.util.List;

@Mapper
public interface MarketMapper {
    List<MarketArtworkVO> findMarketArtworks();

    MarketArtworkVO findMarketArtworkById(Long id);

    List<String> findTagsByArtworkId(Long artworkId);

    List<OrderBookLevelVO> findOrderBookSide(@Param("artworkId") Long artworkId, @Param("side") String side);

    List<TradeExecutionVO> findTrades(Long artworkId);

    List<PricePointVO> findPriceHistory(Long artworkId);

    WalletVO findWallet(Long userId);

    List<PerpPositionVO> findOpenPerpPositions(Long userId);

    List<TpSlOrderVO> findActiveTpSlOrders(Long userId);

    List<PortfolioShareRow> findShareRows(Long userId);

    BigDecimal findCurrentPrice(Long artworkId);

    List<VmmMarketRow> findTradableMarketRows();

    int updateMarketPrice(@Param("artworkId") Long artworkId, @Param("currentPrice") BigDecimal currentPrice,
                          @Param("change24hPct") BigDecimal change24hPct, @Param("volumeDelta") BigDecimal volumeDelta);

    int insertPriceHistory(@Param("artworkId") Long artworkId, @Param("price") BigDecimal price);

    int deleteOldPriceHistory(@Param("artworkId") Long artworkId, @Param("keepRows") Integer keepRows);

    int deleteOpenVmmOrders(Long artworkId);

    int insertVmmOrder(@Param("artworkId") Long artworkId, @Param("side") String side,
                       @Param("price") BigDecimal price, @Param("size") BigDecimal size);

    int deleteOldVmmTrades(@Param("artworkId") Long artworkId, @Param("keepRows") Integer keepRows);

    int updateUsdBalance(@Param("userId") Long userId, @Param("delta") BigDecimal delta);

    int updateBtcBalance(@Param("userId") Long userId, @Param("delta") BigDecimal delta);

    int upsertHolding(@Param("userId") Long userId, @Param("artworkId") Long artworkId,
                      @Param("quantityDelta") BigDecimal quantityDelta, @Param("price") BigDecimal price);

    BigDecimal findHoldingQuantity(@Param("userId") Long userId, @Param("artworkId") Long artworkId);

    int insertTrade(@Param("artworkId") Long artworkId, @Param("buyerUserId") Long buyerUserId,
                    @Param("sellerUserId") Long sellerUserId, @Param("side") String side,
                    @Param("price") BigDecimal price, @Param("size") BigDecimal size,
                    @Param("notional") BigDecimal notional, @Param("source") String source);

    int insertPerpPosition(@Param("userId") Long userId, @Param("artworkId") Long artworkId,
                           @Param("side") String side, @Param("notional") BigDecimal notional,
                           @Param("leverage") Integer leverage, @Param("entryPrice") BigDecimal entryPrice,
                           @Param("marginBtc") BigDecimal marginBtc);

    PerpPositionVO findOpenPerpPositionById(@Param("userId") Long userId, @Param("posId") Long posId);

    int closePerpPosition(@Param("userId") Long userId, @Param("posId") Long posId);

    int insertTpSl(@Param("userId") Long userId, @Param("artworkId") Long artworkId,
                   @Param("type") String type, @Param("posId") Long posId,
                   @Param("tpPrice") BigDecimal tpPrice, @Param("slPrice") BigDecimal slPrice,
                   @Param("qty") BigDecimal qty);

    int cancelTpSl(@Param("userId") Long userId, @Param("id") Long id);

    class PortfolioShareRow {
        public Long artworkId;
        public BigDecimal quantity;
    }

    class VmmMarketRow {
        public Long artworkId;
        public BigDecimal initialSharePrice;
        public BigDecimal currentSharePrice;
    }
}
