package com.ren.yinghui.backend.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
public class WalletVO {
    private BigDecimal usd;
    private BigDecimal btc;
    private Map<Long, BigDecimal> shares;
    private List<PerpPositionVO> perpPositions;
    private List<TpSlOrderVO> tpslOrders;
}
