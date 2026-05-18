package com.ren.yinghui.backend.pojo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ArtworkQueryDTO {
    //filter parameters
    private String category;
    private String medium;
    private String orientation;
    private String dominantColor;

    //price range
    private BigDecimal minPrice;
    private BigDecimal maxPrice;

    //sorting
    private String sortBy;

    //paginated query
    private int offset = 0;
    private int limit = 12;


}