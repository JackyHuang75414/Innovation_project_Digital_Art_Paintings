package com.ren.yinghui.backend.pojo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class SizeOption {
    private Long id;
    private String name;
    private BigDecimal priceDelta;
    private Integer sortOrder;
    private LocalDateTime createdAt;

}
