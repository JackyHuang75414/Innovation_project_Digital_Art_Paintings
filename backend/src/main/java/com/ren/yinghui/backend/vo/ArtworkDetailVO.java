package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class ArtworkDetailVO {
    private Long id;
    private String imageUrl;
    private String title;
    private String artistName;
    private String artistCountry;
    private BigDecimal price;
    private String medium;
    private String dimensions;
    private Integer year;
    private String description;
    private List<String> tags;
    private List<String> availableSizes;
}
