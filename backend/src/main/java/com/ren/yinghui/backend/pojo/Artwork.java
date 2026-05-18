package com.ren.yinghui.backend.pojo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class Artwork {
    private Long id;
    private Long artistId;
    private Long categoryId;
    private String title;
    private String imageUrl;
    private BigDecimal price;
    private String medium;
    private String orientation;
    private String dominantColor;
    private String dimensions;
    private Integer year;
    private String description;
    private String badge;
    private Integer stockQuantity;
    private Integer viewCount;
    private Integer soldCount;
    private Boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;


}
