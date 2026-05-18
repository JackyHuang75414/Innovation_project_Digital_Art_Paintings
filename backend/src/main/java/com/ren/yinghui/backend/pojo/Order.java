package com.ren.yinghui.backend.pojo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class Order {
    private Long id;
    private String orderNo;
    private Long userId;
    private String status;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String shippingCountry;
    private String shippingCity;
    private String shippingAddressLine1;
    private String shippingAddressLine2;
    private String shippingPostalCode;
    private String paymentMethod;
    private BigDecimal subtotal;
    private BigDecimal shippingFee;
    private BigDecimal total;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;


}
