package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class PerpPositionVO {
    private Long id;
    private Long artworkId;
    private String side;
    private BigDecimal notional;
    private Integer leverage;
    private BigDecimal entryPrice;
    private BigDecimal marginBtc;
    private LocalDateTime openTime;
}
