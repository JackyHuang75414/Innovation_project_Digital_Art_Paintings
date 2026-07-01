package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class PricePointVO {
    /** Unix epoch milliseconds — avoids Jackson LocalDateTime serialization issues */
    private Long t;
    private BigDecimal p;
}
