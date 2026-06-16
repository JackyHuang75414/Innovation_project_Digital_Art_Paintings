package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class MarketArtworkVO {
    private Long id;
    private BigDecimal initPrice;
    private BigDecimal price;
    private Long totalShares;
    private BigDecimal mcapUsd;
    private BigDecimal volume24h;
    private BigDecimal change24h;
    private String title;
    private String artist;
    private String artistBio;
    private String imageUrl;
    private String imageLarge;
    private String description;
    private List<String> tags;
    private Integer year;
    private String medium;
    private String edition;
}
