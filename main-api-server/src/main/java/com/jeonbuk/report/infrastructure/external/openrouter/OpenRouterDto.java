package com.jeonbuk.report.infrastructure.external.openrouter;

import lombok.Data;

/**
 * OpenRouter API 요청/응답 DTO 클래스들
 */
public class OpenRouterDto {

  @Data
  public static class ChatMessage {
    private String role; // "system", "user", "assistant"
    private String content;

    public ChatMessage() {
    }

    public ChatMessage(String role, String content) {
      this.role = role;
      this.content = content;
    }
  }

  @Data
  public static class ChatRequest {
    private String model;
    private java.util.List<ChatMessage> messages;
    private Double temperature = 0.7;
    private Integer maxTokens = 1000;

    public ChatRequest() {
    }

    public ChatRequest(String model, java.util.List<ChatMessage> messages, Double temperature, Integer maxTokens) {
      this.model = model;
      this.messages = messages;
      this.temperature = temperature;
      this.maxTokens = maxTokens;
    }
  }

  @Data
  public static class ChatCompletionRequest {
    private String model;
    private java.util.List<Message> messages;
    private Double temperature = 0.7;
    private Integer maxTokens = 1000;
    private Boolean stream = false;
  }

  @Data
  public static class Message {
    private String role; // "system", "user", "assistant"
    private String content;

    public Message() {
    }

    public Message(String role, String content) {
      this.role = role;
      this.content = content;
    }

    public static Message system(String content) {
      return new Message("system", content);
    }

    public static Message user(String content) {
      return new Message("user", content);
    }

    public static Message assistant(String content) {
      return new Message("assistant", content);
    }
  }

  @Data
  public static class ChatResponse {
    private String id;
    private String object;
    private Long created;
    private String model;
    private java.util.List<Choice> choices;
    private Usage usage;
    
    public String getContent() {
      if (choices != null && !choices.isEmpty() && choices.get(0).getMessage() != null) {
        return choices.get(0).getMessage().getContent();
      }
      return null;
    }
  }

  @Data
  public static class ChatCompletionResponse {
    private String id;
    private String object;
    private Long created;
    private String model;
    private java.util.List<Choice> choices;
    private Usage usage;
  }

  @Data
  public static class Choice {
    private Integer index;
    private Message message;
    private String finishReason;
  }

  @Data
  public static class Usage {
    private Integer promptTokens;
    private Integer completionTokens;
    private Integer totalTokens;
  }

  @Data
  public static class ErrorResponse {
    private Error error;
  }

  @Data
  public static class Error {
    private String message;
    private String type;
    private String param;
    private String code;
  }
}
