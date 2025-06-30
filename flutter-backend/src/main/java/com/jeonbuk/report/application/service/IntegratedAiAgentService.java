package com.jeonbuk.report.application.service;

import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterApiClient;
import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterDto;
import com.jeonbuk.report.infrastructure.external.roboflow.RoboflowApiClient;
import com.jeonbuk.report.infrastructure.external.roboflow.RoboflowDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CompletableFuture;

/**
 * 통합 AI 에이전트 서비스
 * 
 * 기능:
 * - 입력 데이터 파싱 및 분석
 * - OpenRouter AI를 이용한 의미 분석
 * - Roboflow 모델 라우팅 결정
 * - 멀티스레딩으로 UI 스레드 블로킹 방지
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class IntegratedAiAgentService {

  private final OpenRouterApiClient openRouterClient;
  private final RoboflowApiClient roboflowClient;
  private final ObjectMapper objectMapper;

  // 모델 라우팅 규칙 (확장 가능)
  private final Map<String, String> modelRoutingRules = Map.of(
      "pothole", "pothole-detection-v1",
      "traffic_sign", "traffic-sign-detection",
      "road_damage", "road-damage-assessment",
      "infrastructure", "infrastructure-monitoring",
      "general", "general-object-detection");

  /**
   * 비동기 입력 데이터 분석
   * UI 스레드를 블로킹하지 않습니다.
   */
  public CompletableFuture<AnalysisResult> analyzeInputAsync(InputData inputData) {
    return CompletableFuture.supplyAsync(() -> {
      try {
        log.info("Starting integrated AI analysis for input: {}", inputData.getId());

        // 1. 입력 데이터 파싱 및 분석
        AnalyzedData analyzedData = parseAndAnalyzeData(inputData);

        // 2. Roboflow 모델 라우팅 결정
        String selectedModel = determineRoboflowModel(analyzedData);

        // 3. 결과 반환
        return new AnalysisResult(
            inputData.getId(),
            analyzedData,
            selectedModel,
            true,
            null,
            System.currentTimeMillis());

      } catch (Exception e) {
        log.error("Error in integrated AI analysis: {}", e.getMessage(), e);
        return new AnalysisResult(
            inputData.getId(),
            null,
            null,
            false,
            e.getMessage(),
            System.currentTimeMillis());
      }
    });
  }

  /**
   * 배치 분석 (여러 입력 데이터 동시 처리)
   */
  public CompletableFuture<List<AnalysisResult>> analyzeBatchAsync(List<InputData> inputDataList) {
    List<CompletableFuture<AnalysisResult>> futures = inputDataList.stream()
        .map(this::analyzeInputAsync)
        .toList();

    return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
        .thenApply(v -> futures.stream()
            .map(CompletableFuture::join)
            .toList());
  }

  /**
   * 입력 데이터 파싱 및 분석
   */
  private AnalyzedData parseAndAnalyzeData(InputData inputData) {
    try {
      // OpenRouter AI를 이용한 데이터 분석 프롬프트 구성
      String analysisPrompt = buildAnalysisPrompt(inputData);

      List<OpenRouterDto.Message> messages = List.of(
          new OpenRouterDto.Message("system",
              "You are an expert AI assistant for analyzing report data and images. " +
                  "Analyze the provided data and extract key information in JSON format."),
          new OpenRouterDto.Message("user", analysisPrompt));

      // AI 분석 실행 (비동기 메서드 사용)
      String responseText = openRouterClient.chatCompletionAsync(messages).get();

      // AI 응답 파싱
      return parseAiResponse(responseText, inputData);

    } catch (Exception e) {
      log.error("Error parsing and analyzing data: {}", e.getMessage(), e);
      throw new RuntimeException("Data analysis failed", e);
    }
  }

  /**
   * 분석 프롬프트 구성
   */
  private String buildAnalysisPrompt(InputData inputData) {
    StringBuilder prompt = new StringBuilder();
    prompt.append("Analyze the following report data and extract key information:\n\n");

    if (inputData.getTitle() != null) {
      prompt.append("Title: ").append(inputData.getTitle()).append("\n");
    }

    if (inputData.getDescription() != null) {
      prompt.append("Description: ").append(inputData.getDescription()).append("\n");
    }

    if (inputData.getLocation() != null) {
      prompt.append("Location: ").append(inputData.getLocation()).append("\n");
    }

    if (inputData.getImageUrls() != null && !inputData.getImageUrls().isEmpty()) {
      prompt.append("Number of images: ").append(inputData.getImageUrls().size()).append("\n");
    }

    prompt.append("\nPlease extract and return the following information in JSON format:\n");
    prompt.append("{\n");
    prompt.append(
        "  \"objectType\": \"detected object type (pothole, traffic_sign, road_damage, infrastructure, general)\",\n");
    prompt.append("  \"damageType\": \"severity or type of damage (minor, moderate, severe, critical)\",\n");
    prompt.append("  \"environment\": \"environment context (urban, rural, highway, residential)\",\n");
    prompt.append("  \"priority\": \"priority level (low, medium, high, critical)\",\n");
    prompt.append("  \"category\": \"report category\",\n");
    prompt.append("  \"keywords\": [\"list\", \"of\", \"relevant\", \"keywords\"],\n");
    prompt.append("  \"confidence\": 0.85\n");
    prompt.append("}\n");

    return prompt.toString();
  }

  /**
   * AI 응답 파싱
   */
  private AnalyzedData parseAiResponse(String responseText, InputData inputData) {
    try {
      // JSON 부분 추출 (TODO: 더 정교한 JSON 파싱 로직 구현)
      String jsonContent = extractJsonFromContent(responseText);

      @SuppressWarnings("unchecked")
      Map<String, Object> analysisData = objectMapper.readValue(jsonContent, Map.class);

      @SuppressWarnings("unchecked")
      List<String> keywords = (List<String>) analysisData.get("keywords");

      return new AnalyzedData(
          inputData.getId(),
          (String) analysisData.get("objectType"),
          (String) analysisData.get("damageType"),
          (String) analysisData.get("environment"),
          (String) analysisData.get("priority"),
          (String) analysisData.get("category"),
          keywords,
          ((Number) analysisData.getOrDefault("confidence", 0.0)).doubleValue(),
          inputData);

    } catch (Exception e) {
      log.error("Error parsing AI response: {}", e.getMessage(), e);

      // 기본값 반환
      return new AnalyzedData(
          inputData.getId(),
          "general",
          "unknown",
          "urban",
          "medium",
          "기타",
          List.of("일반"),
          0.5,
          inputData);
    }
  }

  /**
   * 텍스트에서 JSON 부분 추출
   */
  private String extractJsonFromContent(String content) {
    // 간단한 JSON 추출 로직 (TODO: 더 정교하게 구현)
    int startIndex = content.indexOf("{");
    int endIndex = content.lastIndexOf("}");

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return content.substring(startIndex, endIndex + 1);
    }

    // JSON을 찾을 수 없으면 기본 JSON 반환
    return "{\"objectType\":\"general\",\"damageType\":\"unknown\",\"environment\":\"urban\",\"priority\":\"medium\",\"category\":\"기타\",\"keywords\":[\"일반\"],\"confidence\":0.5}";
  }

  /**
   * Roboflow 모델 라우팅 결정
   */
  public String determineRoboflowModel(AnalyzedData analyzedData) {
    String objectType = analyzedData.getObjectType();
    String selectedModel = modelRoutingRules.getOrDefault(objectType, "general-object-detection");

    log.debug("Selected Roboflow model: {} for object type: {}", selectedModel, objectType);
    return selectedModel;
  }

  /**
   * 라우팅 규칙 추가 (확장성을 위한 메서드)
   */
  public void addRoutingRule(String objectType, String modelId) {
    modelRoutingRules.put(objectType, modelId);
    log.info("Added new routing rule: {} -> {}", objectType, modelId);
  }

  /**
   * 입력 데이터 DTO
   */
  public static class InputData {
    private String id;
    private String title;
    private String description;
    private String location;
    private List<String> imageUrls;
    private Map<String, Object> metadata;

    // 생성자, getter, setter
    public InputData() {
    }

    public InputData(String id, String title, String description, String location,
        List<String> imageUrls, Map<String, Object> metadata) {
      this.id = id;
      this.title = title;
      this.description = description;
      this.location = location;
      this.imageUrls = imageUrls;
      this.metadata = metadata;
    }

    // getters and setters
    public String getId() {
      return id;
    }

    public void setId(String id) {
      this.id = id;
    }

    public String getTitle() {
      return title;
    }

    public void setTitle(String title) {
      this.title = title;
    }

    public String getDescription() {
      return description;
    }

    public void setDescription(String description) {
      this.description = description;
    }

    public String getLocation() {
      return location;
    }

    public void setLocation(String location) {
      this.location = location;
    }

    public List<String> getImageUrls() {
      return imageUrls;
    }

    public void setImageUrls(List<String> imageUrls) {
      this.imageUrls = imageUrls;
    }

    public Map<String, Object> getMetadata() {
      return metadata;
    }

    public void setMetadata(Map<String, Object> metadata) {
      this.metadata = metadata;
    }
  }

  /**
   * 분석 결과 DTO
   */
  public static class AnalyzedData {
    private String id;
    private String objectType;
    private String damageType;
    private String environment;
    private String priority;
    private String category;
    private List<String> keywords;
    private Double confidence;
    private InputData originalInput;

    public AnalyzedData() {
    }

    public AnalyzedData(String id, String objectType, String damageType, String environment,
        String priority, String category, List<String> keywords,
        Double confidence, InputData originalInput) {
      this.id = id;
      this.objectType = objectType;
      this.damageType = damageType;
      this.environment = environment;
      this.priority = priority;
      this.category = category;
      this.keywords = keywords;
      this.confidence = confidence;
      this.originalInput = originalInput;
    }

    // getters and setters
    public String getId() {
      return id;
    }

    public void setId(String id) {
      this.id = id;
    }

    public String getObjectType() {
      return objectType;
    }

    public void setObjectType(String objectType) {
      this.objectType = objectType;
    }

    public String getDamageType() {
      return damageType;
    }

    public void setDamageType(String damageType) {
      this.damageType = damageType;
    }

    public String getEnvironment() {
      return environment;
    }

    public void setEnvironment(String environment) {
      this.environment = environment;
    }

    public String getPriority() {
      return priority;
    }

    public void setPriority(String priority) {
      this.priority = priority;
    }

    public String getCategory() {
      return category;
    }

    public void setCategory(String category) {
      this.category = category;
    }

    public List<String> getKeywords() {
      return keywords;
    }

    public void setKeywords(List<String> keywords) {
      this.keywords = keywords;
    }

    public Double getConfidence() {
      return confidence;
    }

    public void setConfidence(Double confidence) {
      this.confidence = confidence;
    }

    public InputData getOriginalInput() {
      return originalInput;
    }

    public void setOriginalInput(InputData originalInput) {
      this.originalInput = originalInput;
    }
  }

  /**
   * 최종 분석 결과 DTO
   */
  public static class AnalysisResult {
    private String id;
    private AnalyzedData analyzedData;
    private String selectedModel;
    private boolean success;
    private String errorMessage;
    private long timestamp;

    public AnalysisResult() {
    }

    public AnalysisResult(String id, AnalyzedData analyzedData, String selectedModel,
        boolean success, String errorMessage, long timestamp) {
      this.id = id;
      this.analyzedData = analyzedData;
      this.selectedModel = selectedModel;
      this.success = success;
      this.errorMessage = errorMessage;
      this.timestamp = timestamp;
    }

    // getters and setters
    public String getId() {
      return id;
    }

    public void setId(String id) {
      this.id = id;
    }

    public AnalyzedData getAnalyzedData() {
      return analyzedData;
    }

    public void setAnalyzedData(AnalyzedData analyzedData) {
      this.analyzedData = analyzedData;
    }

    public String getSelectedModel() {
      return selectedModel;
    }

    public void setSelectedModel(String selectedModel) {
      this.selectedModel = selectedModel;
    }

    public boolean isSuccess() {
      return success;
    }

    public void setSuccess(boolean success) {
      this.success = success;
    }

    public String getErrorMessage() {
      return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
      this.errorMessage = errorMessage;
    }

    public long getTimestamp() {
      return timestamp;
    }

    public void setTimestamp(long timestamp) {
      this.timestamp = timestamp;
    }
  }
}
