package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class TradeExecutionVO {
    private Long id;
    private Long artworkId;
    private BigDecimal price;
    private BigDecimal size;
    private String side;
    private String user;
    /** Unix epoch milliseconds — avoids LocalDateTime serialization array bug */
    private Long time;
}
