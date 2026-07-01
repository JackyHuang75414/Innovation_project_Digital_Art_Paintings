package com.ren.yinghui.backend.service.impl;

import com.ren.yinghui.backend.dto.AiChatMessageDTO;
import com.ren.yinghui.backend.dto.AiChatRequestDTO;
import com.ren.yinghui.backend.service.AiChatService;
import com.ren.yinghui.backend.vo.AiChatVO;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@Service
public class AiChatServiceImpl implements AiChatService {
    private static final String DEFAULT_CHAT_URL = "https://api.deepseek.com/v1/chat/completions";
    private static final String DEFAULT_MODEL = "deepseek-chat";
    private static final int MAX_MESSAGES = 30;
    private static final int MAX_CONTENT_CHARS = 12_000;

    private final Environment environment;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient;

    public AiChatServiceImpl(Environment environment) {
        this.environment = environment;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    @Override
    public AiChatVO chat(AiChatRequestDTO dto) {
        validate(dto);

        String apiKey = firstNonBlank(
                environment.getProperty("ai.deepseek.api-key"),
                environment.getProperty("LLM_API_KEY"),
                environment.getProperty("DEEPSEEK_API_KEY")
        );
        if (apiKey == null) {
            throw new IllegalStateException("AI API key is not configured");
        }

        String chatUrl = firstNonBlank(environment.getProperty("ai.deepseek.chat-url"), DEFAULT_CHAT_URL);
        String model = firstNonBlank(dto.getModel(), environment.getProperty("ai.deepseek.model"), DEFAULT_MODEL);

        try {
            String payload = objectMapper.writeValueAsString(Map.of(
                    "model", model,
                    "stream", false,
                    "messages", dto.getMessages()
            ));
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(chatUrl))
                    .timeout(Duration.ofSeconds(45))
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new IllegalStateException("AI provider request failed: " + response.statusCode());
            }

            String reply = extractReply(response.body());
            AiChatVO vo = new AiChatVO();
            vo.setReply(reply);
            return vo;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("AI provider request interrupted", e);
        } catch (Exception e) {
            if (e instanceof IllegalStateException) {
                throw (IllegalStateException) e;
            }
            throw new IllegalStateException("AI provider request failed", e);
        }
    }

    private void validate(AiChatRequestDTO dto) {
        List<AiChatMessageDTO> messages = dto.getMessages();
        if (messages == null || messages.isEmpty()) {
            throw new IllegalArgumentException("messages cannot be empty");
        }
        if (messages.size() > MAX_MESSAGES) {
            throw new IllegalArgumentException("Too many messages");
        }
        int totalChars = messages.stream()
                .map(AiChatMessageDTO::getContent)
                .filter(content -> content != null)
                .mapToInt(String::length)
                .sum();
        if (totalChars > MAX_CONTENT_CHARS) {
            throw new IllegalArgumentException("AI prompt is too long");
        }
    }

    private String extractReply(String responseBody) throws Exception {
        JsonNode root = objectMapper.readTree(responseBody);
        JsonNode choices = root.path("choices");
        if (choices.isArray() && !choices.isEmpty()) {
            String content = choices.get(0).path("message").path("content").asText(null);
            if (content == null) {
                content = choices.get(0).path("delta").path("content").asText(null);
            }
            if (content != null && !content.trim().isEmpty()) {
                return content;
            }
        }

        String outputText = root.path("output").path("text").asText(null);
        if (outputText != null && !outputText.trim().isEmpty()) {
            return outputText;
        }
        throw new IllegalStateException("Cannot parse AI provider response");
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }
}
