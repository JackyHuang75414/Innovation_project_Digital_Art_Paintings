package com.ren.yinghui.backend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class WalletConnectionDTO {
    @NotBlank
    private String walletType;

    @NotBlank
    private String address;

    private String chainId;

    private BigDecimal balanceNative;
}
