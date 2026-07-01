package com.ren.yinghui.backend.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ArtworkQueryDTO {
    //search keyword
    private String q;

    //filter parameters
    private String category;
    private String medium;
    private String orientation;
    private String color;

    //price range
    private BigDecimal priceMin;
    private BigDecimal priceMax;

    //sorting
    private String sort;

    //paginated query
    private Integer offset;
    private Integer limit;
    private Integer page = 1;
    private Integer pageSize = 12;

    public int getOffset() {
        if (offset != null && offset >= 0) {
            return offset;
        }
        int currentPage = page == null || page < 1 ? 1 : page;
        int size = getLimit();
        return (currentPage - 1) * size;
    }

    public int getLimit() {
        if (limit != null && limit > 0) {
            return Math.min(limit, 50);
        }
        if (pageSize == null || pageSize < 1) {
            return 12;
        }
        return Math.min(pageSize, 50);
    }


}
