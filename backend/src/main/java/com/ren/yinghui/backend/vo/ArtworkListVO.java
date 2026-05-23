package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ArtworkListVO {
    private Long id;
    private String imageUrl;
    private String title;
    private String artistName;
    private BigDecimal price;
    private String medium;
    private String badge;
}
