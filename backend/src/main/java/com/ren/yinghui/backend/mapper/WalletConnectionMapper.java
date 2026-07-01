package com.ren.yinghui.backend.mapper;

import com.ren.yinghui.backend.vo.WalletConnectionVO;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.math.BigDecimal;
import java.util.List;

@Mapper
public interface WalletConnectionMapper {
    @Select("""
            SELECT id, user_id, wallet_type, address, chain_id, balance_native, is_active, connected_at, disconnected_at
            FROM wallet_connections
            WHERE user_id = #{userId}
              AND is_active = 1
            ORDER BY connected_at DESC, id DESC
            """)
    List<WalletConnectionVO> findActiveByUserId(Long userId);

    @Select("""
            SELECT id, user_id, wallet_type, address, chain_id, balance_native, is_active, connected_at, disconnected_at
            FROM wallet_connections
            WHERE id = #{id}
              AND user_id = #{userId}
            """)
    WalletConnectionVO findByIdForUser(@Param("id") Long id, @Param("userId") Long userId);

    @Update("""
            UPDATE wallet_connections
            SET is_active = 0,
                disconnected_at = NOW()
            WHERE user_id = #{userId}
              AND is_active = 1
            """)
    int deactivateActiveByUserId(Long userId);

    @Update("""
            UPDATE wallet_connections
            SET is_active = 0,
                disconnected_at = NOW()
            WHERE id = #{id}
              AND user_id = #{userId}
            """)
    int deactivateById(@Param("id") Long id, @Param("userId") Long userId);

    @Insert("""
            INSERT INTO wallet_connections(user_id, wallet_type, address, chain_id, balance_native, is_active)
            VALUES(#{userId}, #{walletType}, #{address}, #{chainId}, #{balanceNative}, 1)
            """)
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(WalletConnectionInsertRow row);

    class WalletConnectionInsertRow {
        public Long id;
        public Long userId;
        public String walletType;
        public String address;
        public String chainId;
        public BigDecimal balanceNative;
    }
}
