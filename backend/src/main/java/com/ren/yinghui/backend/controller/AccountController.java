package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.dto.TpSlDTO;
import com.ren.yinghui.backend.service.MarketService;
import com.ren.yinghui.backend.vo.Result;
import com.ren.yinghui.backend.vo.TpSlOrderVO;
import com.ren.yinghui.backend.vo.WalletVO;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/account")
public class AccountController {
    private final MarketService marketService;

    public AccountController(MarketService marketService) {
        this.marketService = marketService;
    }

    @GetMapping("/portfolio")
    public Result<WalletVO> portfolio() {
        return Result.success(marketService.getCurrentWallet());
    }

    @PostMapping("/tpsl")
    public Result<TpSlOrderVO> setTpSl(@RequestBody TpSlDTO dto) {
        return Result.success(marketService.setTpSl(dto));
    }

    @DeleteMapping("/tpsl/{id}")
    public Result<Void> cancelTpSl(@PathVariable Long id) {
        marketService.cancelTpSl(id);
        return Result.success();
    }
}
