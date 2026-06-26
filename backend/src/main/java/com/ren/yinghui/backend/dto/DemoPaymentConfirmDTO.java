package com.ren.yinghui.backend.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DemoPaymentConfirmDTO {
    @NotNull
    private Long orderId;

    private String paymentMethod;
}
