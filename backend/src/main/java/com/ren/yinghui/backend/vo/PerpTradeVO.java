package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class PerpTradeVO {
    private Boolean ok;
    private String msg;
    private PerpPositionVO pos;
    private BigDecimal pnlUsd;
    private WalletVO wallet;
}
