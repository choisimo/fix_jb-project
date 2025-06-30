package com.jeonbuk.report.application.service;

import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterApiClient;
import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterDto;
import com.jeonbuk.report.application.service.IntegratedAiAgentService.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * 검증 AI 에이전트 서비스
 * 
 * 기능:
 * - 파싱된 데이터 검증
 * - Roboflow 모델 라우팅 결정 검증
 * - OpenRouter AI를 이용한 교차 검증
 * - 멀티스레딩으로 UI 스레드 블로킹 방지
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ValidationAiAgentService {

  private final OpenRouterApiClient openRouterClient;
  private final ObjectMapper objectMapper;

  /**
   * 비동기 데이터 검증
   * UI 스레드를 블로킹하지 않습니다.
   */
  public CompletableFuture<ValidationResult> validateDataAsync(AnalyzedData analyzedData) {
    return CompletableFuture.supplyAsync(() -> {
      try {
        log.info("Starting data validation for: {}", analyzedData.getId());
        return validateData(analyzedData);
      } catch (Exception e) {
        log.error("Error in async data validation: {}", e.getMessage(), e);
        return new ValidationResult(
            analyzedData.getId(),
            false,
            "Validation failed: " + e.getMessage(),
            List.of(e.getMessage()),
            0.0,
            System.currentTimeMillis());
      }
    });
  }

  /**
   * 비동기 라우팅 결정 검증
   */
  public CompletableFuture<ValidationResult> validateRoutingDecisionAsync(
      AnalyzedData analyzedData, String selectedModelId) {
    return CompletableFuture.supplyAsync(() -> {
      try {
        log.info("Starting routing validation for model: {} with data: {}",
            selectedModelId, analyzedData.getId());
        return validateRoutingDecision(analyzedData, selectedModelId);
      } catch (Exception e) {
        log.error("Error in async routing validation: {}", e.getMessage(), e);
        return new ValidationResult(
            analyzedData.getId(),
            false,
            "Routing validation failed: " + e.getMessage(),
            List.of(e.getMessage()),
            0.0,
            System.currentTimeMillis());
      }
    });
  }

  /**
   * 통합 검증 (데이터 + 라우팅 결정)
   */
  public CompletableFuture<ValidationResult> validateCompleteAsync(
      AnalyzedData analyzedData, String selectedModelId) {
    return CompletableFuture.supplyAsync(() -> {
      try {
        log.info("Starting complete validation for: {}", analyzedData.getId());

        // 데이터 검증
        ValidationResult dataValidation = validateData(analyzedData);
        if (!dataValidation.isValid()) {
          return dataValidation;
        }

        // 라우팅 결정 검증
        ValidationResult routingValidation = validateRoutingDecision(analyzedData, selectedModelId);

        // 종합 결과
        boolean overallValid = dataValidation.isValid() && routingValidation.isValid();
        double combinedScore = (dataValidation.getValidationScore() + routingValidation.getValidationScore()) / 2.0;

        List<String> allIssues = new java.util.ArrayList<>(dataValidation.getValidationIssues());
        allIssues.addAll(routingValidation.getValidationIssues());

        return new ValidationResult(
            analyzedData.getId(),
            overallValid,
            overallValid ? "Complete validation passed" : "Complete validation failed",
            allIssues,
            combinedScore,
            System.currentTimeMillis());

      } catch (Exception e) {
        log.error("Error in complete validation: {}", e.getMessage(), e);
        return new ValidationResult(
            analyzedData.getId(),
            false,
            "Complete validation failed: " + e.getMessage(),
            List.of(e.getMessage()),
            0.0,
            System.currentTimeMillis());
      }
    });
  }

  /**
   * 데이터 검증 (내부 메서드)
   */
  private ValidationResult validateData(AnalyzedData analyzedData) {
    try {
      String validationPrompt = buildDataValidationPrompt(analyzedData);

      List<OpenRouterDto.ChatMessage> messages = List.of(
          new OpenRouterDto.ChatMessage("system",
              "You are an expert data validation AI. Your job is to validate parsed data " +
                  "for consistency, accuracy, and logical coherence. Return validation results in JSON format."),
          new OpenRouterDto.ChatMessage("user", validationPrompt));

      OpenRouterDto.ChatRequest request = new OpenRouterDto.ChatRequest(
          "qwen/qwen2.5-vl-72b-instruct:free",
          messages,
          512,
          0.3, // 낮은 temperature로 일관된 검증 결과
          1.0,
          1.0);

      OpenRouterDto.ChatResponse response = openRouterClient.chatCompletion(request);
      return parseValidationResponse(response, analyzedData.getId(), "data");

    } catch (Exception e) {
      log.error("Error in data validation: {}", e.getMessage(), e);
      throw new RuntimeException("Data validation failed", e);
    }
  }

  /**
   * 라우팅 결정 검증 (내부 메서드)
   */
  private ValidationResult validateRoutingDecision(AnalyzedData analyzedData, String selectedModelId) {
    try {
      String routingPrompt = buildRoutingValidationPrompt(analyzedData, selectedModelId);

      List<OpenRouterDto.ChatMessage> messages = List.of(
          new OpenRouterDto.ChatMessage("system",
              "You are an expert AI model routing validator. Your job is to validate " +
                  "whether the selected AI model is appropriate for the given data context. " +
                  "Return validation results in JSON format."),
          new OpenRouterDto.ChatMessage("user", routingPrompt));

      OpenRouterDto.ChatRequest request = new OpenRouterDto.ChatRequest(
          "qwen/qwen2.5-vl-72b-instruct:free",
          messages,
          512,
          0.3,
          1.0,
          1.0);

      OpenRouterDto.ChatResponse response = openRouterClient.chatCompletion(request);
      return parseValidationResponse(response, analyzedData.getId(), "routing");

    } catch (Exception e) {
      log.error("Error in routing validation: {}", e.getMessage(), e);
      throw new RuntimeException("Routing validation failed", e);
    }
  }

  /**
   * 데이터 검증 프롬프트 구성
   */
  private String buildDataValidationPrompt(AnalyzedData analyzedData) {
    StringBuilder prompt = new StringBuilder();
    prompt.append("Please validate the following analyzed data for consistency and accuracy:\n\n");
    prompt.append("Original Input:\n");

    InputData originalInput = analyzedData.getOriginalInput();
    if (originalInput != null) {
      if (originalInput.getTitle() != null) {
        prompt.append("- Title: ").append(originalInput.getTitle()).append("\n");
      }
      if (originalInput.getDescription() != null) {
        prompt.append("- Description: ").append(originalInput.getDescription()).append("\n");
      }
      if (originalInput.getLocation() != null) {
        prompt.append("- Location: ").append(originalInput.getLocation()).append("\n");
      }
    }

    prompt.append("\nAnalyzed Data:\n");
    prompt.append("- Object Type: ").append(analyzedData.getObjectType()).append("\n");
    prompt.append("- Damage Type: ").append(analyzedData.getDamageType()).append("\n");
    prompt.append("- Environment: ").append(analyzedData.getEnvironment()).append("\n");
    prompt.append("- Priority: ").append(analyzedData.getPriority()).append("\n");
    prompt.append("- Category: ").append(analyzedData.getCategory()).append("\n");
    prompt.append("- Keywords: ").append(analyzedData.getKeywords()).append("\n");
    prompt.append("- Confidence: ").append(analyzedData.getConfidence()).append("\n");

    prompt.append("\nPlease validate and return results in JSON format:\n");
    prompt.append("{\n");
    prompt.append("  \"isValid\": true/false,\n");
    prompt.append("  \"validationScore\": 0.0-1.0,\n");
    prompt.append("  \"issues\": [\"list of issues found\"],\n");
    prompt.append("  \"reasoning\": \"explanation of validation decision\"\n");
    prompt.append("}\n");

    return prompt.toString();
  }

  /**
   * 라우팅 검증 프롬프트 구성
   */
  private String buildRoutingValidationPrompt(AnalyzedData analyzedData, String selectedModelId) {
    StringBuilder prompt = new StringBuilder();
    prompt.append("Please validate whether the selected AI model is appropriate for the analyzed data:\n\n");

    prompt.append("Analyzed Data:\n");
    prompt.append("- Object Type: ").append(analyzedData.getObjectType()).append("\n");
    prompt.append("- Damage Type: ").append(analyzedData.getDamageType()).append("\n");
    prompt.append("- Environment: ").append(analyzedData.getEnvironment()).append("\n");
    prompt.append("- Priority: ").append(analyzedData.getPriority()).append("\n");
    prompt.append("- Category: ").append(analyzedData.getCategory()).append("\n");

    prompt.append("\nSelected Model: ").append(selectedModelId).append("\n");

    prompt.append("\nAvailable Model Types:\n");
    prompt.append("- pothole-detection-v1: For pothole and road surface issues\n");
    prompt.append("- traffic-sign-detection: For traffic sign related problems\n");
    prompt.append("- road-damage-assessment: For general road damage assessment\n");
    prompt.append("- infrastructure-monitoring: For infrastructure monitoring\n");
    prompt.append("- general-object-detection: For general purpose detection\n");

    prompt.append("\nPlease validate the model selection and return results in JSON format:\n");
    prompt.append("{\n");
    prompt.append("  \"isValid\": true/false,\n");
    prompt.append("  \"validationScore\": 0.0-1.0,\n");
    prompt.append("  \"issues\": [\"list of issues found\"],\n");
    prompt.append("  \"reasoning\": \"explanation of routing validation decision\",\n");
    prompt.append("  \"suggestedModel\": \"alternative model if current is inappropriate\"\n");
    prompt.append("}\n");

    return prompt.toString();
  }

  /**
   * 검증 응답 파싱
   */
  private ValidationResult parseValidationResponse(OpenRouterDto.ChatResponse response, String id, String type) {
    try {
      String content = response.getChoices().get(0).getMessage().getContent();
      String jsonContent = extractJsonFromContent(content);

      Map<String, Object> validationData = objectMapper.readValue(jsonContent, Map.class);

      boolean isValid = (Boolean) validationData.getOrDefault("isValid", false);
      double score = ((Number) validationData.getOrDefault("validationScore", 0.0)).doubleValue();
      List<String> issues = (List<String>) validationData.getOrDefault("issues", List.of());
      String reasoning = (String) validationData.getOrDefault("reasoning", "No reasoning provided");

      return new ValidationResult(
          id,
          isValid,
          reasoning,
          issues,
          score,
          System.currentTimeMillis());

    } catch (Exception e) {
      log.error("Error parsing validation response for {}: {}", type, e.getMessage(), e);

      // 기본 실패 결과 반환
      return new ValidationResult(
          id,
          false,
          "Failed to parse validation response",
          List.of("Response parsing error: " + e.getMessage()),
          0.0,
          System.currentTimeMillis());
    }
  }

  /**
   * 텍스트에서 JSON 부분 추출
   */
  private String extractJsonFromContent(String content) {
    int startIndex = content.indexOf("{");
    int endIndex = content.lastIndexOf("}");

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return content.substring(startIndex, endIndex + 1);
    }

    // JSON을 찾을 수 없으면 기본 JSON 반환
    return "{\"isValid\":false,\"validationScore\":0.0,\"issues\":[\"Could not parse validation response\"],\"reasoning\":\"Response format error\"}";
  }

  /**
   * 검증 결과 DTO
   */
  public static class ValidationResult {
    private String id;
    private boolean valid;
    private String validationMessage;
    private List<String> validationIssues;
    private double validationScore;
    private long timestamp;

    public ValidationResult() {
    }

    public ValidationResult(String id, boolean valid, String validationMessage,
        List<String> validationIssues, double validationScore, long timestamp) {
      this.id = id;
      this.valid = valid;
      this.validationMessage = validationMessage;
      this.validationIssues = validationIssues;
      this.validationScore = validationScore;
      this.timestamp = timestamp;
    }

    // getters and setters
    public String getId() {
      return id;
    }

    public void setId(String id) {
      this.id = id;
    }

    public boolean isValid() {
      return valid;
    }

    public void setValid(boolean valid) {
      this.valid = valid;
    }

    public String getValidationMessage() {
      return validationMessage;
    }

    public void setValidationMessage(String validationMessage) {
      this.validationMessage = validationMessage;
    }

    public List<String> getValidationIssues() {
      return validationIssues;
    }

    public void setValidationIssues(List<String> validationIssues) {
      this.validationIssues = validationIssues;
    }

    public double getValidationScore() {
      return validationScore;
    }

    public void setValidationScore(double validationScore) {
      this.validationScore = validationScore;
    }

    public long getTimestamp() {
      return timestamp;
    }

    public void setTimestamp(long timestamp) {
      this.timestamp = timestamp;
    }
  }
}
