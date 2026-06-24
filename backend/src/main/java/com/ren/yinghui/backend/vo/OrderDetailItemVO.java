package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class OrderDetailItemVO {
    private Long artworkId;
    private String title;
    private String imageUrl;
    private String artistName;
    private String size;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal subtotal;
}
