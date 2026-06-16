package com.ren.yinghui.backend.service;

import com.ren.yinghui.backend.dto.OpenPerpDTO;
import com.ren.yinghui.backend.dto.SpotTradeDTO;
import com.ren.yinghui.backend.dto.TpSlDTO;
import com.ren.yinghui.backend.vo.*;

import java.util.List;

public interface MarketService {
    List<MarketArtworkVO> listArtworks();

    MarketArtworkVO getArtwork(Long id);

    OrderBookVO getOrderBook(Long id);

    List<TradeExecutionVO> getTrades(Long id);

    List<PricePointVO> getPriceHistory(Long id);

    WalletVO getCurrentWallet();

    SpotTradeVO executeSpot(SpotTradeDTO dto);

    PerpTradeVO openPerp(OpenPerpDTO dto);

    PerpTradeVO closePerp(Long posId);

    TpSlOrderVO setTpSl(TpSlDTO dto);

    void cancelTpSl(Long id);
}
