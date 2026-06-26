package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class BitcoinPaymentVO {
    private Long paymentId;
    private Long orderId;
    private String orderNo;
    private String address;
    private BigDecimal expectedBtc;
    private Long receivedSatoshi;
    private String status;
    private String paymentStatus;
    private LocalDateTime expiresAt;
}
