package com.ren.yinghui.backend.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateBitcoinPaymentDTO {
    @NotNull
    private Long orderId;
}
