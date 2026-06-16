package com.ren.yinghui.backend.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class TpSlDTO {
    private Long artworkId;
    private String type = "spot";
    private Long posId;
    private BigDecimal tpPrice;
    private BigDecimal slPrice;
    private BigDecimal qty;
}
