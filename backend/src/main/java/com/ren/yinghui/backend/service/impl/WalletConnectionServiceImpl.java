package com.ren.yinghui.backend.service.impl;

import com.ren.yinghui.backend.dto.WalletConnectionDTO;
import com.ren.yinghui.backend.mapper.WalletConnectionMapper;
import com.ren.yinghui.backend.service.WalletConnectionService;
import com.ren.yinghui.backend.utils.ThreadLocalUtil;
import com.ren.yinghui.backend.vo.WalletConnectionVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class WalletConnectionServiceImpl implements WalletConnectionService {
    private static final Set<String> SUPPORTED_WALLETS = Set.of(
            "testwallet", "metamask", "coinbase", "walletconnect", "phantom"
    );

    private final WalletConnectionMapper walletConnectionMapper;

    public WalletConnectionServiceImpl(WalletConnectionMapper walletConnectionMapper) {
        this.walletConnectionMapper = walletConnectionMapper;
    }

    @Override
    public List<WalletConnectionVO> listActiveConnections() {
        return walletConnectionMapper.findActiveByUserId(currentUserId());
    }

    @Override
    @Transactional
    public WalletConnectionVO connect(WalletConnectionDTO dto) {
        Long userId = currentUserId();
        String walletType = normalize(dto.getWalletType());
        if (!SUPPORTED_WALLETS.contains(walletType)) {
            throw new IllegalArgumentException("Unsupported wallet type");
        }
        if (dto.getBalanceNative() != null && dto.getBalanceNative().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Wallet balance cannot be negative");
        }

        walletConnectionMapper.deactivateActiveByUserId(userId);

        WalletConnectionMapper.WalletConnectionInsertRow row = new WalletConnectionMapper.WalletConnectionInsertRow();
        row.userId = userId;
        row.walletType = walletType;
        row.address = dto.getAddress().trim();
        row.chainId = dto.getChainId() == null ? null : dto.getChainId().trim();
        row.balanceNative = dto.getBalanceNative();
        walletConnectionMapper.insert(row);

        return walletConnectionMapper.findByIdForUser(row.id, userId);
    }

    @Override
    public void disconnect(Long id) {
        walletConnectionMapper.deactivateById(id, currentUserId());
    }

    @Override
    public void disconnectActive() {
        walletConnectionMapper.deactivateActiveByUserId(currentUserId());
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }

    private Long currentUserId() {
        Map<String, Object> claims = ThreadLocalUtil.get();
        Object userId = claims.get("id");
        return userId instanceof Number number ? number.longValue() : Long.valueOf(userId.toString());
    }
}
