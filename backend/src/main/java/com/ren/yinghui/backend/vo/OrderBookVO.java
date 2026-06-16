package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.util.List;

@Data
public class OrderBookVO {
    private List<OrderBookLevelVO> bids;
    private List<OrderBookLevelVO> asks;
}
