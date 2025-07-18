package com.jeonbuk.report.infrastructure.external.gemini;

import lombok.Data;
import java.util.Base64;
import java.util.List;

/**
 * Google Gemini API 요청/응답 DTO 클래스들
 */
public class GeminiDto {

  @Data
  public static class GenerateContentRequest {
    private List<Content> contents;
    private GenerationConfig generationConfig;
  }

  @Data
  public static class Content {
    private List<Part> parts;
    private String role = "user";

    public static Content textContent(String text) {
      Content content = new Content();
      content.setParts(List.of(new Part(text)));
      return content;
    }

    public static Content multimodalContent(String text, byte[] imageData, String mimeType) {
      Content content = new Content();
      content.setParts(List.of(
          new Part(text),
          new Part(imageData, mimeType)
      ));
      return content;
    }
  }

  @Data
  public static class Part {
    private String text;
    private InlineData inlineData;

    public Part() {}

    public Part(String text) {
      this.text = text;
    }

    public Part(byte[] data, String mimeType) {
      this.inlineData = new InlineData(data, mimeType);
    }
  }

  @Data
  public static class InlineData {
    private String mimeType;
    private String data; // Base64 encoded

    public InlineData() {}

    public InlineData(byte[] imageData, String mimeType) {
      this.mimeType = mimeType;
      this.data = Base64.getEncoder().encodeToString(imageData);
    }
  }

  @Data
  public static class GenerationConfig {
    private Double temperature;
    private Integer maxOutputTokens;
    private Double topP;
    private Integer topK;

    public GenerationConfig() {}

    public GenerationConfig(Double temperature, Integer maxOutputTokens) {
      this.temperature = temperature;
      this.maxOutputTokens = maxOutputTokens;
    }
  }

  @Data
  public static class GenerateContentResponse {
    private List<Candidate> candidates;
    private PromptFeedback promptFeedback;
    private UsageMetadata usageMetadata;
    private String modelVersion;
    private String responseId;
  }

  @Data
  public static class Candidate {
    private Content content;
    private String finishReason;
    private Integer index;
    private List<SafetyRating> safetyRatings;
    private Double avgLogprobs;
  }

  @Data
  public static class SafetyRating {
    private String category;
    private String probability;
  }

  @Data
  public static class PromptFeedback {
    private List<SafetyRating> safetyRatings;
    private String blockReason;
  }

  @Data
  public static class UsageMetadata {
    private Integer promptTokenCount;
    private Integer candidatesTokenCount;
    private Integer totalTokenCount;
    private List<TokenDetails> promptTokensDetails;
    private List<TokenDetails> candidatesTokensDetails;
  }

  @Data
  public static class TokenDetails {
    private String modality;
    private Integer tokenCount;
  }

  @Data
  public static class ErrorResponse {
    private Error error;
  }

  @Data
  public static class Error {
    private Integer code;
    private String message;
    private String status;
    private List<ErrorDetail> details;
  }

  @Data
  public static class ErrorDetail {
    private String type;
    private String reason;
    private String domain;
    private Object metadata;
  }
}