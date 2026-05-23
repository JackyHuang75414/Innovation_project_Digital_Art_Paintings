package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class OrderCreateVO {
    private Long id;
    private String orderNo;
    private String status;
    private BigDecimal subtotal;
    private BigDecimal shippingFee;
    private BigDecimal total;
    private LocalDateTime createdAt;
}
