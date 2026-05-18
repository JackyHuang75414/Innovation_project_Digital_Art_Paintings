package com.ren.yinghui.backend.pojo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ArtworkSize {
    private Long artworkId;
    private Long sizeId;
    private BigDecimal priceOverride;
    private Boolean available;

}
