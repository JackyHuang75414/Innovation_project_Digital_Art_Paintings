package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class SpotTradeVO {
    private Boolean ok;
    private String msg;
    private BigDecimal shares;
    private BigDecimal proceeds;
    private BigDecimal price;
    private WalletVO wallet;
}
