package com.ren.yinghui.backend.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

@Data
public class CreateOrderDTO {
    @NotEmpty(message = "Order items are required")
    private List<@Valid CreateOrderItemDTO> items;

    @NotBlank(message = "Customer name is required")
    private String customerName;

    @NotBlank(message = "Customer email is required")
    private String customerEmail;

    private String customerPhone;

    @NotBlank(message = "Shipping country is required")
    private String shippingCountry;

    @NotBlank(message = "Shipping city is required")
    private String shippingCity;

    @NotBlank(message = "Shipping address line1 is required")
    private String shippingAddressLine1;

    private String shippingAddressLine2;

    @NotBlank(message = "Shipping postal code is required")
    private String shippingPostalCode;

    private String paymentMethod;
}
