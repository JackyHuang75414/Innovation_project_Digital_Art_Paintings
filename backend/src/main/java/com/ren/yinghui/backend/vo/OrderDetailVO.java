package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class OrderDetailVO {
    private Long id;
    private String orderNo;
    private String status;
    private List<OrderDetailItemVO> items;
    private BigDecimal subtotal;
    private BigDecimal shippingFee;
    private BigDecimal total;
    private LocalDateTime createdAt;
}
