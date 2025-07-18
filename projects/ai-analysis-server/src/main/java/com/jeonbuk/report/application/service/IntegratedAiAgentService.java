package com.jeonbuk.report.application.service;

import com.jeonbuk.report.infrastructure.external.gemini.GeminiApiClient;
import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterApiClient;
import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterDto;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.Base64;

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

  private final GeminiApiClient geminiClient;
  private final OpenRouterApiClient openRouterClient;
  private final ObjectMapper objectMapper;

  // 모델 라우팅 규칙 (확장 가능)
  private final Map<String, String> modelRoutingRules = Map.of(
      "pothole", "pothole-detection-v1",
      "traffic_sign", "traffic-sign-detection",
      "road_damage", "road-damage-assessment",
      "infrastructure", "infrastructure-monitoring",
      "general", "general-object-detection");

    /**
     * 비동기 입력 분석
     */
    public CompletableFuture<AnalysisResult> analyzeInputAsync(InputData inputData) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("🔍 Starting comprehensive analysis for input: {}", inputData.getId());
                
                // 실제 AI 분석 수행
                AnalyzedData analyzedData = performActualAiAnalysis(inputData);
                
                String selectedModel = determineModel(analyzedData);
                
                return new AnalysisResult(
                    inputData.getId(),
                    analyzedData,
                    selectedModel,
                    true,
                    null,
                    System.currentTimeMillis()
                );
                
            } catch (Exception e) {
                log.error("❌ Analysis failed for input {}: {}", inputData.getId(), e.getMessage());
                return new AnalysisResult(
                    inputData.getId(),
                    null,
                    null,
                    false,
                    e.getMessage(),
                    System.currentTimeMillis()
                );
            }
        });
    }

    /**
     * 실제 AI 분석 수행
     */
    private AnalyzedData performActualAiAnalysis(InputData inputData) {
        try {
            log.info("🤖 Performing actual AI analysis for: {}", inputData.getId());
            
            // 텍스트 및 이미지 분석을 위한 프롬프트 구성
            StringBuilder analysisPrompt = new StringBuilder();
            analysisPrompt.append("다음 신고 내용을 분석하여 JSON 형태로 응답해주세요:\n\n");
            
            if (inputData.getTitle() != null) {
                analysisPrompt.append("제목: ").append(inputData.getTitle()).append("\n");
            }
            if (inputData.getDescription() != null) {
                analysisPrompt.append("설명: ").append(inputData.getDescription()).append("\n");
            }
            if (inputData.getLocation() != null) {
                analysisPrompt.append("위치: ").append(inputData.getLocation()).append("\n");
            }
            
            analysisPrompt.append("\n분석 결과를 다음 JSON 형식으로 반환해주세요:\n");
            analysisPrompt.append("{\n");
            analysisPrompt.append("  \"objectType\": \"도로 시설물의 유형 (road, traffic_light, sign, building 등)\",\n");
            analysisPrompt.append("  \"damageType\": \"손상 유형 (pothole, crack, broken, missing, normal 등)\",\n");
            analysisPrompt.append("  \"environment\": \"환경 (urban, rural, highway, residential 등)\",\n");
            analysisPrompt.append("  \"priority\": \"우선순위 (high, medium, low)\",\n");
            analysisPrompt.append("  \"category\": \"신고 카테고리 (pothole, traffic_sign, streetlight, litter 등)\",\n");
            analysisPrompt.append("  \"keywords\": [\"관련\", \"키워드\", \"목록\"],\n");
            analysisPrompt.append("  \"confidence\": 0.85\n");
            analysisPrompt.append("}\n");

            String analysisResult;
            
            // 이미지가 있는 경우 비전 모델 사용
            if (inputData.getImageUrls() != null && !inputData.getImageUrls().isEmpty()) {
                String firstImageUrl = inputData.getImageUrls().get(0);
                log.info("🖼️ Analyzing with image: {}", firstImageUrl);
                
                analysisResult = openRouterClient.analyzeImageWithUrlAsync(
                    firstImageUrl, 
                    analysisPrompt.toString()
                ).join();
            } else {
                // 텍스트만 분석
                log.info("📝 Analyzing text only");
                analysisResult = openRouterClient.chatCompletionAsync(
                    "당신은 도시 인프라 및 시설물 분석 전문가입니다.",
                    analysisPrompt.toString()
                ).join();
            }

            // JSON 파싱 및 AnalyzedData 객체 생성
            return parseAiAnalysisResult(analysisResult, inputData);
            
        } catch (Exception e) {
            log.error("❌ AI analysis failed: {}", e.getMessage());
            // Fallback으로 기본 분석 수행
            return createFallbackAnalysis(inputData);
        }
    }

    /**
     * AI 분석 결과 파싱
     */
    private AnalyzedData parseAiAnalysisResult(String analysisResult, InputData inputData) {
        try {
            // JSON 파싱
            Map<String, Object> resultMap = objectMapper.readValue(analysisResult, Map.class);
            
            return new AnalyzedData(
                inputData.getId(),
                (String) resultMap.getOrDefault("objectType", "unknown"),
                (String) resultMap.getOrDefault("damageType", "unknown"),
                (String) resultMap.getOrDefault("environment", "urban"),
                (String) resultMap.getOrDefault("priority", "medium"),
                (String) resultMap.getOrDefault("category", "general"),
                (List<String>) resultMap.getOrDefault("keywords", Arrays.asList("분석", "결과")),
                ((Number) resultMap.getOrDefault("confidence", 0.7)).doubleValue(),
                inputData
            );
            
        } catch (Exception e) {
            log.warn("⚠️ Failed to parse AI analysis result, using fallback: {}", e.getMessage());
            return createFallbackAnalysis(inputData);
        }
    }

    /**
     * Fallback 분석 (AI 분석 실패시)
     */
    private AnalyzedData createFallbackAnalysis(InputData inputData) {
        log.info("🔄 Creating fallback analysis for: {}", inputData.getId());
        
        String category = "general";
        String damageType = "unknown";
        String priority = "medium";
        List<String> keywords = new ArrayList<>();
        
        // 제목과 설명에서 키워드 추출
        String content = "";
        if (inputData.getTitle() != null) {
            content += inputData.getTitle() + " ";
        }
        if (inputData.getDescription() != null) {
            content += inputData.getDescription();
        }
        
        content = content.toLowerCase();
        
        // 카테고리 및 손상 유형 결정
        if (content.contains("포트홀") || content.contains("구멍") || content.contains("도로")) {
            category = "pothole";
            damageType = "pothole";
            keywords.addAll(Arrays.asList("도로", "포트홀", "구멍"));
            priority = "high";
        } else if (content.contains("표지판") || content.contains("신호등")) {
            category = "traffic_sign";
            damageType = "broken";
            keywords.addAll(Arrays.asList("표지판", "신호등", "교통"));
            priority = "medium";
        } else if (content.contains("가로등") || content.contains("조명")) {
            category = "streetlight";
            damageType = "broken";
            keywords.addAll(Arrays.asList("가로등", "조명", "불빛"));
            priority = "medium";
        } else if (content.contains("쓰레기") || content.contains("폐기물")) {
            category = "litter";
            damageType = "litter";
            keywords.addAll(Arrays.asList("쓰레기", "폐기물", "환경"));
            priority = "low";
        }
        
        return new AnalyzedData(
            inputData.getId(),
            "infrastructure",
            damageType,
            "urban",
            priority,
            category,
            keywords,
            0.6, // Lower confidence for fallback
            inputData
        );
    }
    
    /**
     * 분석된 데이터를 기반으로 적절한 Roboflow 모델 결정
     */
    private String determineModel(AnalyzedData analyzedData) {
        log.info("🎯 Determining model for category: {}", analyzedData.getCategory());
        
        String category = analyzedData.getCategory();
        String model = modelRoutingRules.getOrDefault(category, modelRoutingRules.get("general"));
        
        log.info("✅ Selected model: {} for category: {}", model, category);
        return model;
    }

    /**
     * 입력 데이터 기반 모델 결정 (Fallback 용도)
     */
    private String determineModel(InputData inputData) {
        if (inputData.getContent() != null) {
            String content = inputData.getContent().toLowerCase();
            if (content.contains("포트홀") || content.contains("도로") || content.contains("구멍")) {
                return modelRoutingRules.get("pothole");
            } else if (content.contains("표지판") || content.contains("신호등")) {
                return modelRoutingRules.get("traffic_sign");
            }
        }
        return modelRoutingRules.get("general");
    }

    /**
     * 이미지 URL에서 텍스트 추출 (OCR)
     */
    public String extractTextFromImageUrl(String imageUrl) {
        try {
            log.info("🔍 Extracting text from image URL: {}", imageUrl);
            
            String ocrPrompt = """
                이 이미지에서 모든 텍스트를 정확하게 추출해주세요.
                한국어와 영어를 모두 인식하고, 추출된 텍스트만 반환해주세요.
                추가 설명이나 코멘트는 포함하지 마세요.
                """;
            
            // OpenRouter 비전 모델로 OCR 수행
            return openRouterClient.analyzeImageWithUrlAsync(imageUrl, ocrPrompt).join();
            
        } catch (Exception e) {
            log.error("❌ Failed to extract text from image URL {}: {}", imageUrl, e.getMessage());
            return ""; // 빈 문자열 반환
        }
    }

    /**
     * 이미지에서 텍스트 추출 (OCR) - 바이트 배열 (기존 호환성)
     */
    public String extractTextFromImage(byte[] imageData) {
        try {
            log.info("🔍 Extracting text from image data");
            
            // Base64로 인코딩
            String base64Image = Base64.getEncoder().encodeToString(imageData);
            
            // OCR용 프롬프트
            List<OpenRouterDto.Message> messages = List.of(
                OpenRouterDto.Message.system(
                    "당신은 전문 OCR 도우미입니다. 이미지에서 모든 텍스트를 정확하게 추출하세요. " +
                    "추출된 텍스트만 반환하고, 추가 코멘트는 포함하지 마세요."
                ),
                OpenRouterDto.Message.userWithImage(
                    "이 이미지에서 모든 텍스트를 추출해주세요:",
                    "data:image/jpeg;base64," + base64Image
                )
            );
            
            // OpenRouter API 호출
            return openRouterClient.chatCompletionAsync(messages).join();
            
        } catch (Exception e) {
            log.error("❌ Failed to extract text from image: {}", e.getMessage());
            return ""; // 빈 문자열 반환
        }
    }

    @Getter
    public static class AnalysisResult {
        private final String id;
        private final AnalyzedData analyzedData;
        private final String selectedModel;
        private final boolean success;
        private final String errorMessage;
        private final long timestamp;

        public AnalysisResult(String id, AnalyzedData analyzedData, String selectedModel, 
                             boolean success, String errorMessage, long timestamp) {
            this.id = id;
            this.analyzedData = analyzedData;
            this.selectedModel = selectedModel;
            this.success = success;
            this.errorMessage = errorMessage;
            this.timestamp = timestamp;
        }
    }

    @Getter
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class InputData {    private String id;
    private String title;
    private String description;
    private String location;
    private List<String> imageUrls;
    private Map<String, Object> metadata;
    private String type;
    private String content;
    private String timestamp;

    // 생성자, getter, setter
    public InputData() {
    }

    public InputData(String id, String title, String description, String location,
        List<String> imageUrls, Map<String, Object> metadata, String type, String content, String timestamp) {
      this.id = id;
      this.title = title;
      this.description = description;
      this.location = location;
      this.imageUrls = imageUrls;
      this.metadata = metadata;
      this.type = type;
      this.content = content;
      this.timestamp = timestamp;
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

    public String getType() {
      return type;
    }

    public void setType(String type) {
      this.type = type;
    }

    public String getContent() {
      return content;
    }

    public void setContent(String content) {
      this.content = content;
    }

    public String getTimestamp() {
      return timestamp;
    }

    public void setTimestamp(String timestamp) {
      this.timestamp = timestamp;
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
}
