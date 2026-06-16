package com.ren.yinghui.backend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class BackendApplicationTests {

    private final HttpClient httpClient = HttpClient.newHttpClient();

    @LocalServerPort
    private int port;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void contextLoads() {
    }

    @Test
    void artworksHttpMvcChainWorks() throws Exception {
        JsonNode list = getJson("/api/artworks", null);
        assertSuccess(list);
        assertTrue(list.path("data").size() > 0);
        assertFalse(list.path("data").get(0).path("imageUrl").asText().isBlank());
        assertFalse(list.path("data").get(0).path("artistName").asText().isBlank());

        JsonNode detail = getJson("/api/artworks/1", null);
        assertSuccess(detail);
        assertEquals(1L, detail.path("data").path("id").asLong());
        assertTrue(detail.path("data").path("tags").size() > 0);
        assertTrue(detail.path("data").path("availableSizes").size() > 0);

        JsonNode recommendations = getJson("/api/artworks/1/recommendations", null);
        assertSuccess(recommendations);
        assertTrue(recommendations.path("data").size() > 0);

        JsonNode search = getJson("/api/artworks/search?q=Everydays", null);
        assertSuccess(search);
        assertTrue(search.path("data").size() > 0);
    }

    @Test
    void marketAndTradingEndpointsUpdateDatabaseBackedState() throws Exception {
        JsonNode market = getJson("/api/market/artworks", null);
        assertSuccess(market);
        assertTrue(market.path("data").size() > 0);
        assertEquals("Everydays: The First 5000 Days", market.path("data").get(0).path("title").asText());

        JsonNode book = getJson("/api/market/artworks/1/order-book", null);
        assertSuccess(book);
        assertTrue(book.path("data").path("bids").size() > 0);
        assertTrue(book.path("data").path("asks").size() > 0);

        String token = loginAndGetToken();
        JsonNode before = getJson("/api/account/portfolio", token);
        assertSuccess(before);
        double usdBefore = before.path("data").path("usd").asDouble();
        double sharesBefore = before.path("data").path("shares").path("1").asDouble(0);

        JsonNode trade = postJson("/api/trades/spot", """
                {
                  "artworkId": 1,
                  "side": "buy",
                  "amount": 10
                }
                """, token);
        assertSuccess(trade);
        assertTrue(trade.path("data").path("ok").asBoolean());

        JsonNode after = getJson("/api/account/portfolio", token);
        assertSuccess(after);
        assertTrue(after.path("data").path("usd").asDouble() < usdBefore);
        assertTrue(after.path("data").path("shares").path("1").asDouble() > sharesBefore);

        JsonNode trades = getJson("/api/market/artworks/1/trades", null);
        assertSuccess(trades);
        assertEquals("buy", trades.path("data").get(0).path("side").asText());
    }

    @Test
    void userWishlistAndOrdersHttpMvcChainWorks() throws Exception {
        String token = loginAndGetToken();

        JsonNode me = getJson("/api/user/me", token);
        assertSuccess(me);
        assertEquals("demo", me.path("data").path("name").asText());

        JsonNode added = postForm("/api/wishlist", "artworkId=2", token);
        assertSuccess(added);
        assertTrue(added.path("data").path("wishlisted").asBoolean());

        JsonNode wishlist = getJson("/api/wishlist/me", token);
        assertSuccess(wishlist);
        assertTrue(wishlist.path("data").size() > 0);

        JsonNode removed = deleteJson("/api/wishlist?artworkId=2", token);
        assertSuccess(removed);
        assertFalse(removed.path("data").path("wishlisted").asBoolean());

        String orderPayload = """
                {
                  "customerName": "Demo Trader",
                  "customerEmail": "demo@example.com",
                  "customerPhone": "123456789",
                  "shippingCountry": "France",
                  "shippingCity": "Paris",
                  "shippingAddressLine1": "1 Rue de Rivoli",
                  "shippingAddressLine2": "Apt 2",
                  "shippingPostalCode": "75001",
                  "paymentMethod": "card",
                  "items": [
                    { "artworkId": 1, "size": "A3 Print", "quantity": 1 }
                  ]
                }
                """;

        JsonNode created = postJson("/api/orders", orderPayload, token);
        assertSuccess(created);
        long orderId = created.path("data").path("id").asLong();
        assertTrue(orderId > 0);
        assertFalse(created.path("data").path("orderNo").asText().isBlank());

        JsonNode detail = getJson("/api/orders/" + orderId, token);
        assertSuccess(detail);
        assertEquals(orderId, detail.path("data").path("id").asLong());
        assertTrue(detail.path("data").path("items").size() > 0);

        JsonNode myOrders = getJson("/api/orders/me", token);
        assertSuccess(myOrders);
        assertTrue(myOrders.path("data").size() > 0);
    }

    @Test
    void protectedEndpointsRejectMissingToken() throws Exception {
        HttpResponse<String> response = send(
                HttpRequest.newBuilder(uri("/api/user/me")).GET().build()
        );
        assertEquals(HttpStatus.UNAUTHORIZED.value(), response.statusCode());
    }

    private String loginAndGetToken() throws Exception {
        JsonNode login = postForm(
                "/api/user/login",
                "name=" + encode("demo") + "&password=" + encode("demo123"),
                null
        );
        assertSuccess(login);
        String token = login.path("data").asText();
        assertFalse(token.isBlank());
        return token;
    }

    private JsonNode getJson(String path, String token) throws Exception {
        HttpRequest.Builder builder = HttpRequest.newBuilder(uri(path)).GET();
        addToken(builder, token);
        return parseOk(send(builder.build()));
    }

    private JsonNode postForm(String path, String body, String token) throws Exception {
        HttpRequest.Builder builder = HttpRequest.newBuilder(uri(path))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(body));
        addToken(builder, token);
        return parseOk(send(builder.build()));
    }

    private JsonNode postJson(String path, String body, String token) throws Exception {
        HttpRequest.Builder builder = HttpRequest.newBuilder(uri(path))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body));
        addToken(builder, token);
        return parseOk(send(builder.build()));
    }

    private JsonNode deleteJson(String path, String token) throws Exception {
        HttpRequest.Builder builder = HttpRequest.newBuilder(uri(path)).DELETE();
        addToken(builder, token);
        return parseOk(send(builder.build()));
    }

    private HttpResponse<String> send(HttpRequest request) throws Exception {
        return httpClient.send(request, HttpResponse.BodyHandlers.ofString());
    }

    private JsonNode parseOk(HttpResponse<String> response) throws Exception {
        assertEquals(HttpStatus.OK.value(), response.statusCode(), response.body());
        return objectMapper.readTree(response.body());
    }

    private void assertSuccess(JsonNode node) {
        assertEquals(0, node.path("code").asInt(), node.toString());
    }

    private URI uri(String path) {
        return URI.create("http://localhost:" + port + path);
    }

    private void addToken(HttpRequest.Builder builder, String token) {
        if (token != null && !token.isBlank()) {
            builder.header("Authorization", token);
        }
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
