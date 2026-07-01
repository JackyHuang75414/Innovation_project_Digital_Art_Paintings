package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.service.MarketService;
import com.ren.yinghui.backend.vo.*;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/market/artworks")
public class MarketController {
    private final MarketService marketService;

    public MarketController(MarketService marketService) {
        this.marketService = marketService;
    }

    @GetMapping
    public Result<List<MarketArtworkVO>> list() {
        return Result.success(marketService.listArtworks());
    }

    @GetMapping("/{id}")
    public Result<MarketArtworkVO> detail(@PathVariable Long id) {
        MarketArtworkVO artwork = marketService.getArtwork(id);
        return artwork == null ? Result.error("market artwork not found") : Result.success(artwork);
    }

    @GetMapping("/{id}/order-book")
    public Result<OrderBookVO> orderBook(@PathVariable Long id) {
        return Result.success(marketService.getOrderBook(id));
    }

    @GetMapping("/{id}/trades")
    public Result<List<TradeExecutionVO>> trades(@PathVariable Long id) {
        return Result.success(marketService.getTrades(id));
    }

    @GetMapping("/{id}/price-history")
    public Result<List<PricePointVO>> history(@PathVariable Long id) {
        return Result.success(marketService.getPriceHistory(id));
    }
}
