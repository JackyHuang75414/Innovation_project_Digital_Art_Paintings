package com.ren.yinghui.backend.mapper;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import lombok.Data;

import java.math.BigDecimal;

@Mapper
public interface PaymentsMapper {
    @Select("""
            SELECT id, order_no, user_id, status, total
            FROM orders
            WHERE id = #{orderId}
            """)
    OrderPaymentRow findOrderForPayment(Long orderId);

    @Update("""
            UPDATE orders
            SET status = 'paid',
                updated_at = NOW()
            WHERE id = #{orderId}
              AND user_id = #{userId}
              AND status = 'pending'
            """)
    int markOrderPaid(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Insert("""
            INSERT INTO payment_transactions (
                order_id,
                user_id,
                provider,
                provider_payment_id,
                status,
                amount,
                currency,
                raw_response
            ) VALUES (
                #{orderId},
                #{userId},
                #{provider},
                #{providerPaymentId},
                #{status},
                #{amount},
                #{currency},
                #{rawResponse}
            )
            """)
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertPayment(PaymentInsertRow payment);

    @Insert("""
            INSERT INTO bitcoin_payment_addresses (
                payment_transaction_id,
                order_id,
                user_id,
                address,
                expected_btc,
                received_satoshi,
                status,
                expires_at
            ) VALUES (
                #{paymentTransactionId},
                #{orderId},
                #{userId},
                #{address},
                #{expectedBtc},
                #{receivedSatoshi},
                #{status},
                #{expiresAt}
            )
            """)
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertBitcoinAddress(BitcoinAddressInsertRow row);

    @Select("""
            SELECT
                b.id,
                b.payment_transaction_id,
                b.order_id,
                o.order_no,
                b.user_id,
                b.address,
                b.expected_btc,
                b.received_satoshi,
                b.status,
                b.expires_at,
                p.status AS payment_status,
                o.status AS order_status
            FROM bitcoin_payment_addresses b
            JOIN payment_transactions p ON b.payment_transaction_id = p.id
            JOIN orders o ON b.order_id = o.id
            WHERE b.payment_transaction_id = #{paymentId}
            """)
    BitcoinPaymentRow findBitcoinPaymentByPaymentId(Long paymentId);

    @Select("""
            SELECT
                b.id,
                b.payment_transaction_id,
                b.order_id,
                o.order_no,
                b.user_id,
                b.address,
                b.expected_btc,
                b.received_satoshi,
                b.status,
                b.expires_at,
                p.status AS payment_status,
                o.status AS order_status
            FROM bitcoin_payment_addresses b
            JOIN payment_transactions p ON b.payment_transaction_id = p.id
            JOIN orders o ON b.order_id = o.id
            WHERE b.order_id = #{orderId}
              AND b.user_id = #{userId}
              AND b.status = 'pending'
              AND p.status = 'pending'
            ORDER BY b.id DESC
            LIMIT 1
            """)
    BitcoinPaymentRow findPendingBitcoinPaymentByOrder(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("""
            UPDATE bitcoin_payment_addresses
            SET received_satoshi = #{receivedSatoshi},
                status = #{status},
                updated_at = NOW()
            WHERE payment_transaction_id = #{paymentId}
            """)
    int updateBitcoinAddressStatus(@Param("paymentId") Long paymentId,
                                   @Param("receivedSatoshi") Long receivedSatoshi,
                                   @Param("status") String status);

    @Update("""
            UPDATE payment_transactions
            SET status = #{status},
                raw_response = #{rawResponse},
                updated_at = NOW()
            WHERE id = #{paymentId}
            """)
    int updatePaymentStatus(@Param("paymentId") Long paymentId,
                            @Param("status") String status,
                            @Param("rawResponse") String rawResponse);

    @Data
    class OrderPaymentRow {
        private Long id;
        private String orderNo;
        private Long userId;
        private String status;
        private BigDecimal total;
    }

    @Data
    class PaymentInsertRow {
        private Long id;
        private Long orderId;
        private Long userId;
        private String provider;
        private String providerPaymentId;
        private String status;
        private BigDecimal amount;
        private String currency;
        private String rawResponse;
    }

    @Data
    class BitcoinAddressInsertRow {
        private Long id;
        private Long paymentTransactionId;
        private Long orderId;
        private Long userId;
        private String address;
        private BigDecimal expectedBtc;
        private Long receivedSatoshi;
        private String status;
        private java.time.LocalDateTime expiresAt;
    }

    @Data
    class BitcoinPaymentRow {
        private Long id;
        private Long paymentTransactionId;
        private Long orderId;
        private String orderNo;
        private Long userId;
        private String address;
        private BigDecimal expectedBtc;
        private Long receivedSatoshi;
        private String status;
        private java.time.LocalDateTime expiresAt;
        private String paymentStatus;
        private String orderStatus;
    }
}
