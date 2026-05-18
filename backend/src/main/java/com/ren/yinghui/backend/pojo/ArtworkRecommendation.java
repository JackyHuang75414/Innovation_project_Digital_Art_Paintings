package com.ren.yinghui.backend.pojo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class ArtworkRecommendation {
    private Long artworkId;
    private Long recommendedArtworkId;
    private BigDecimal score;
    private String reason;
    private LocalDateTime createdAt;


}
