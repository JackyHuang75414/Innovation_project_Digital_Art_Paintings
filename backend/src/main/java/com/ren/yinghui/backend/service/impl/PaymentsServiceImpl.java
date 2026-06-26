package com.ren.yinghui.backend.service.impl;

import com.ren.yinghui.backend.dto.CreateBitcoinPaymentDTO;
import com.ren.yinghui.backend.dto.DemoPaymentConfirmDTO;
import com.ren.yinghui.backend.mapper.PaymentsMapper;
import com.ren.yinghui.backend.service.PaymentsService;
import com.ren.yinghui.backend.utils.ThreadLocalUtil;
import com.ren.yinghui.backend.vo.BitcoinPaymentVO;
import com.ren.yinghui.backend.vo.PaymentConfirmVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
public class PaymentsServiceImpl implements PaymentsService {
    private static final String BLOCKCYPHER_BASE_URL = "https://api.blockcypher.com/v1/btc/test3";
    private static final BigDecimal EUR_TO_BTC = new BigDecimal("0.0000145");
    private static final BigDecimal SATOSHIS_PER_BTC = new BigDecimal("100000000");

    private final PaymentsMapper paymentsMapper;
    private final HttpClient httpClient;

    public PaymentsServiceImpl(PaymentsMapper paymentsMapper) {
        this.paymentsMapper = paymentsMapper;
        this.httpClient = HttpClient.newHttpClient();
    }

    @Override
    @Transactional
    public PaymentConfirmVO confirmDemoPayment(DemoPaymentConfirmDTO dto) {
        Long userId = currentUserId();
        PaymentsMapper.OrderPaymentRow order = paymentsMapper.findOrderForPayment(dto.getOrderId());
        if (order == null) {
            throw new IllegalArgumentException("order not found");
        }
        if (!userId.equals(order.getUserId())) {
            throw new IllegalArgumentException("order not found");
        }
        if (!"pending".equals(order.getStatus())) {
            throw new IllegalArgumentException("order is not pending");
        }

        int updated = paymentsMapper.markOrderPaid(order.getId(), userId);
        if (updated != 1) {
            throw new IllegalArgumentException("order is not pending");
        }

        PaymentsMapper.PaymentInsertRow payment = new PaymentsMapper.PaymentInsertRow();
        payment.setOrderId(order.getId());
        payment.setUserId(userId);
        payment.setProvider("demo_card");
        payment.setProviderPaymentId("demo_" + UUID.randomUUID());
        payment.setStatus("succeeded");
        payment.setAmount(order.getTotal());
        payment.setCurrency("EUR");
        payment.setRawResponse("""
                {"provider":"demo_card","message":"Demo payment confirmed by backend"}
                """);
        paymentsMapper.insertPayment(payment);

        PaymentConfirmVO vo = new PaymentConfirmVO();
        vo.setPaymentId(payment.getId());
        vo.setOrderId(order.getId());
        vo.setOrderNo(order.getOrderNo());
        vo.setOrderStatus("paid");
        vo.setProvider(payment.getProvider());
        vo.setStatus(payment.getStatus());
        vo.setAmount(payment.getAmount());
        vo.setCurrency(payment.getCurrency());
        vo.setPaidAt(LocalDateTime.now());
        return vo;
    }

    @Override
    @Transactional
    public BitcoinPaymentVO createBitcoinPayment(CreateBitcoinPaymentDTO dto) {
        Long userId = currentUserId();
        PaymentsMapper.OrderPaymentRow order = requirePendingOrder(dto.getOrderId(), userId);

        PaymentsMapper.BitcoinPaymentRow existing = paymentsMapper.findPendingBitcoinPaymentByOrder(order.getId(), userId);
        if (existing != null) {
            return toBitcoinPaymentVO(existing);
        }

        String address = createBlockCypherAddress();

        PaymentsMapper.PaymentInsertRow payment = new PaymentsMapper.PaymentInsertRow();
        payment.setOrderId(order.getId());
        payment.setUserId(userId);
        payment.setProvider("bitcoin_testnet");
        payment.setProviderPaymentId("bc_test3_" + UUID.randomUUID());
        payment.setStatus("pending");
        payment.setAmount(order.getTotal());
        payment.setCurrency("EUR");
        payment.setRawResponse("""
                {"provider":"blockcypher","network":"btc/test3","status":"address_created"}
                """);
        paymentsMapper.insertPayment(payment);

        PaymentsMapper.BitcoinAddressInsertRow bitcoin = new PaymentsMapper.BitcoinAddressInsertRow();
        bitcoin.setPaymentTransactionId(payment.getId());
        bitcoin.setOrderId(order.getId());
        bitcoin.setUserId(userId);
        bitcoin.setAddress(address);
        bitcoin.setExpectedBtc(order.getTotal().multiply(EUR_TO_BTC).setScale(8, RoundingMode.UP));
        bitcoin.setReceivedSatoshi(0L);
        bitcoin.setStatus("pending");
        bitcoin.setExpiresAt(LocalDateTime.now().plusMinutes(30));
        paymentsMapper.insertBitcoinAddress(bitcoin);

        PaymentsMapper.BitcoinPaymentRow row = paymentsMapper.findBitcoinPaymentByPaymentId(payment.getId());
        return toBitcoinPaymentVO(row);
    }

    @Override
    @Transactional
    public BitcoinPaymentVO getBitcoinPayment(Long paymentId) {
        Long userId = currentUserId();
        PaymentsMapper.BitcoinPaymentRow payment = paymentsMapper.findBitcoinPaymentByPaymentId(paymentId);
        if (payment == null || !userId.equals(payment.getUserId())) {
            throw new IllegalArgumentException("payment not found");
        }

        if ("paid".equals(payment.getStatus()) || "succeeded".equals(payment.getPaymentStatus())) {
            return toBitcoinPaymentVO(payment);
        }

        long receivedSatoshi = fetchReceivedSatoshi(payment.getAddress());
        long expectedSatoshi = payment.getExpectedBtc()
                .multiply(SATOSHIS_PER_BTC)
                .setScale(0, RoundingMode.CEILING)
                .longValue();

        if (receivedSatoshi >= expectedSatoshi) {
            paymentsMapper.updateBitcoinAddressStatus(paymentId, receivedSatoshi, "paid");
            paymentsMapper.updatePaymentStatus(paymentId, "succeeded", """
                    {"provider":"blockcypher","network":"btc/test3","status":"paid"}
                    """);
            paymentsMapper.markOrderPaid(payment.getOrderId(), userId);
        } else {
            paymentsMapper.updateBitcoinAddressStatus(paymentId, receivedSatoshi, "pending");
        }

        return toBitcoinPaymentVO(paymentsMapper.findBitcoinPaymentByPaymentId(paymentId));
    }

    private PaymentsMapper.OrderPaymentRow requirePendingOrder(Long orderId, Long userId) {
        PaymentsMapper.OrderPaymentRow order = paymentsMapper.findOrderForPayment(orderId);
        if (order == null || !userId.equals(order.getUserId())) {
            throw new IllegalArgumentException("order not found");
        }
        if (!"pending".equals(order.getStatus())) {
            throw new IllegalArgumentException("order is not pending");
        }
        return order;
    }

    private String createBlockCypherAddress() {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(BLOCKCYPHER_BASE_URL + "/addrs"))
                    .POST(HttpRequest.BodyPublishers.noBody())
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new RuntimeException("BlockCypher address error: " + response.statusCode());
            }
            String address = extractJsonString(response.body(), "address");
            if (address == null || address.isBlank()) {
                throw new RuntimeException("BlockCypher address response missing address");
            }
            return address;
        } catch (Exception exception) {
            throw new RuntimeException("Could not create bitcoin testnet address");
        }
    }

    private long fetchReceivedSatoshi(String address) {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(BLOCKCYPHER_BASE_URL + "/addrs/" + address + "/balance"))
                    .GET()
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new RuntimeException("BlockCypher balance error: " + response.statusCode());
            }
            return extractJsonLong(response.body(), "total_received");
        } catch (Exception exception) {
            throw new RuntimeException("Could not check bitcoin testnet payment");
        }
    }

    private String extractJsonString(String json, String field) {
        String marker = "\"" + field + "\"";
        int fieldIndex = json.indexOf(marker);
        if (fieldIndex < 0) return null;
        int colonIndex = json.indexOf(':', fieldIndex + marker.length());
        if (colonIndex < 0) return null;
        int firstQuote = json.indexOf('"', colonIndex + 1);
        if (firstQuote < 0) return null;
        int secondQuote = json.indexOf('"', firstQuote + 1);
        if (secondQuote < 0) return null;
        return json.substring(firstQuote + 1, secondQuote);
    }

    private long extractJsonLong(String json, String field) {
        String marker = "\"" + field + "\"";
        int fieldIndex = json.indexOf(marker);
        if (fieldIndex < 0) return 0L;
        int colonIndex = json.indexOf(':', fieldIndex + marker.length());
        if (colonIndex < 0) return 0L;
        int start = colonIndex + 1;
        while (start < json.length() && Character.isWhitespace(json.charAt(start))) start++;
        int end = start;
        while (end < json.length() && Character.isDigit(json.charAt(end))) end++;
        if (end == start) return 0L;
        return Long.parseLong(json.substring(start, end));
    }

    private BitcoinPaymentVO toBitcoinPaymentVO(PaymentsMapper.BitcoinPaymentRow row) {
        BitcoinPaymentVO vo = new BitcoinPaymentVO();
        vo.setPaymentId(row.getPaymentTransactionId());
        vo.setOrderId(row.getOrderId());
        vo.setOrderNo(row.getOrderNo());
        vo.setAddress(row.getAddress());
        vo.setExpectedBtc(row.getExpectedBtc());
        vo.setReceivedSatoshi(row.getReceivedSatoshi());
        vo.setStatus(row.getStatus());
        vo.setPaymentStatus(row.getPaymentStatus());
        vo.setExpiresAt(row.getExpiresAt());
        return vo;
    }

    private Long currentUserId() {
        Map<String, Object> claims = ThreadLocalUtil.get();
        Object userId = claims.get("id");
        if (userId instanceof Number number) {
            return number.longValue();
        }
        return Long.valueOf(userId.toString());
    }
}
