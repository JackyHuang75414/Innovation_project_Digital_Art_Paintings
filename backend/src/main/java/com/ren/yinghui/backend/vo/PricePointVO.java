package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class PricePointVO {
    private LocalDateTime t;
    private BigDecimal p;
}
