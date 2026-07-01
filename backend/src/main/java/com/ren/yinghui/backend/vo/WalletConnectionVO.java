package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class WalletConnectionVO {
    private Long id;
    private Long userId;
    private String walletType;
    private String address;
    private String chainId;
    private BigDecimal balanceNative;
    private Boolean isActive;
    private LocalDateTime connectedAt;
    private LocalDateTime disconnectedAt;
}
