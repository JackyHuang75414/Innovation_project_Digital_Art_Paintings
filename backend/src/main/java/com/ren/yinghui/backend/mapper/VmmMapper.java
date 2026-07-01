package com.ren.yinghui.backend.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface VmmMapper {

    /** Fetch all tradable artwork IDs and their current prices for VMM initialisation. */
    List<Map<String, Object>> findTradableArtworkPrices();

    /** Update the live price in artwork_markets. */
    void updateCurrentPrice(@Param("artworkId") Long artworkId, @Param("price") double price);

    /** Append a point to artwork_price_history. */
    void insertPriceHistory(@Param("artworkId") Long artworkId, @Param("price") double price);

    /** Update 24h change percentage. */
    void updateChange24h(@Param("artworkId") Long artworkId, @Param("changePct") double changePct);

    /** Remove all VMM-generated orders for an artwork before refreshing. */
    void deleteVmmOrders(@Param("artworkId") Long artworkId);

    /** Insert a single VMM bid or ask level. */
    void insertVmmOrder(@Param("artworkId") Long artworkId,
                        @Param("side") String side,
                        @Param("price") double price,
                        @Param("size") double size);

    /** Insert a VMM trade into trade_executions for the Recent Trades feed. */
    void insertVmmTrade(@Param("artworkId") Long artworkId,
                        @Param("side") String side,
                        @Param("price") double price,
                        @Param("size") double size);
}
