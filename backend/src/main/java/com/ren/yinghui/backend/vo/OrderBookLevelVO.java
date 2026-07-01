package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class OrderBookLevelVO {
    private BigDecimal price;
    private BigDecimal size;
    private String user;
    private Boolean isVmm;
}
