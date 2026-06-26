package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.dto.TpSlDTO;
import com.ren.yinghui.backend.dto.WalletConnectionDTO;
import com.ren.yinghui.backend.service.MarketService;
import com.ren.yinghui.backend.service.WalletConnectionService;
import com.ren.yinghui.backend.vo.Result;
import com.ren.yinghui.backend.vo.TpSlOrderVO;
import com.ren.yinghui.backend.vo.WalletConnectionVO;
import com.ren.yinghui.backend.vo.WalletVO;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/account")
public class AccountController {
    private final MarketService marketService;
    private final WalletConnectionService walletConnectionService;

    public AccountController(MarketService marketService, WalletConnectionService walletConnectionService) {
        this.marketService = marketService;
        this.walletConnectionService = walletConnectionService;
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

    @GetMapping("/wallet-connections")
    public Result<List<WalletConnectionVO>> walletConnections() {
        return Result.success(walletConnectionService.listActiveConnections());
    }

    @PostMapping("/wallet-connections")
    public Result<WalletConnectionVO> connectWallet(@RequestBody @Valid WalletConnectionDTO dto) {
        return Result.success(walletConnectionService.connect(dto));
    }

    @DeleteMapping("/wallet-connections/active")
    public Result<Void> disconnectActiveWallet() {
        walletConnectionService.disconnectActive();
        return Result.success();
    }

    @DeleteMapping("/wallet-connections/{id}")
    public Result<Void> disconnectWallet(@PathVariable Long id) {
        walletConnectionService.disconnect(id);
        return Result.success();
    }
}
