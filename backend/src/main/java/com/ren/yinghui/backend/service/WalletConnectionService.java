package com.ren.yinghui.backend.service;

import com.ren.yinghui.backend.dto.WalletConnectionDTO;
import com.ren.yinghui.backend.vo.WalletConnectionVO;

import java.util.List;

public interface WalletConnectionService {
    List<WalletConnectionVO> listActiveConnections();

    WalletConnectionVO connect(WalletConnectionDTO dto);

    void disconnect(Long id);

    void disconnectActive();
}
