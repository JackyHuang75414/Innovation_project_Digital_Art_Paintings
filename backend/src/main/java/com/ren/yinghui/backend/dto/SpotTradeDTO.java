package com.ren.yinghui.backend.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class SpotTradeDTO {
    @NotNull
    private Long artworkId;

    @NotBlank
    private String side;

    @NotNull
    @DecimalMin(value = "0.000001")
    private BigDecimal amount;
}
