package com.ren.yinghui.backend.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class OpenPerpDTO {
    @NotNull
    private Long artworkId;

    @NotBlank
    private String side;

    @NotNull
    @Min(1)
    private Integer leverage;

    @NotNull
    @DecimalMin(value = "0.00000001")
    private BigDecimal marginBtc;
}
