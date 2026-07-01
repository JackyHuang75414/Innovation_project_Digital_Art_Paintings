package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.dto.OpenPerpDTO;
import com.ren.yinghui.backend.dto.SpotTradeDTO;
import com.ren.yinghui.backend.service.MarketService;
import com.ren.yinghui.backend.vo.PerpTradeVO;
import com.ren.yinghui.backend.vo.Result;
import com.ren.yinghui.backend.vo.SpotTradeVO;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/trades")
public class TradingController {
    private final MarketService marketService;

    public TradingController(MarketService marketService) {
        this.marketService = marketService;
    }

    @PostMapping("/spot")
    public Result<SpotTradeVO> spot(@RequestBody @Valid SpotTradeDTO dto) {
        return Result.success(marketService.executeSpot(dto));
    }

    @PostMapping("/perp/open")
    public Result<PerpTradeVO> openPerp(@RequestBody @Valid OpenPerpDTO dto) {
        return Result.success(marketService.openPerp(dto));
    }

    @PostMapping("/perp/close/{posId}")
    public Result<PerpTradeVO> closePerp(@PathVariable Long posId) {
        return Result.success(marketService.closePerp(posId));
    }
}
