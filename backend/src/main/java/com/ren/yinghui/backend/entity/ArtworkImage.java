package com.ren.yinghui.backend.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ArtworkImage {
    private Long id;
    private Long artworkId;
    private String imageUrl;
    private String altText;
    private Integer sortOrder;
    private LocalDateTime createdAt;


}
