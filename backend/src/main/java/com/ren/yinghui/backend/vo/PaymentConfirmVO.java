package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class PaymentConfirmVO {
    private Long paymentId;
    private Long orderId;
    private String orderNo;
    private String orderStatus;
    private String provider;
    private String status;
    private BigDecimal amount;
    private String currency;
    private LocalDateTime paidAt;
}
