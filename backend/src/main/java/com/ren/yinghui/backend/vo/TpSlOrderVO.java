package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class TpSlOrderVO {
    private Long id;
    private Long artworkId;
    private String type;
    private Long posId;
    private BigDecimal tpPrice;
    private BigDecimal slPrice;
    private BigDecimal qty;
    private String status;
    private LocalDateTime createdAt;
}
