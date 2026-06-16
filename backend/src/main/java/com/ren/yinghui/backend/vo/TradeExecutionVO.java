package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class TradeExecutionVO {
    private Long id;
    private Long artworkId;
    private BigDecimal price;
    private BigDecimal size;
    private String side;
    private String user;
    private LocalDateTime time;
}
