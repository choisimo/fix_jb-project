package com.jeonbuk.report.infrastructure.external.gemini;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jeonbuk.report.config.ApiKeyManager;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Recover;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.ResourceAccessException;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

/**
 * Google Gemini API 클라이언트
 * 
 * 멀티스레딩 지원:
 * - 비동기 API 호출을 위한 CompletableFuture 사용
 * - UI 스레드 블로킹 방지
 * - 백그라운드 스레드풀에서 실행
 */
@Slf4j
@Service
public class GeminiApiClient {

  private static final String BASE_URL = "https://generativelanguage.googleapis.com/v1beta";
  private static final String DEFAULT_MODEL = "gemini-1.5-pro";
  private static final String VISION_MODEL = "gemini-1.5-pro-vision";

  // 백그라운드 스레드 풀 (UI 스레드 블로킹 방지)
  private final Executor executor = Executors.newFixedThreadPool(4);

  private final RestTemplate restTemplate;
  private final ObjectMapper objectMapper;
  private final ApiKeyManager apiKeyManager;

  public GeminiApiClient(
      RestTemplate restTemplate,
      ObjectMapper objectMapper,
      ApiKeyManager apiKeyManager) {
    this.restTemplate = restTemplate;
    this.objectMapper = objectMapper;
    this.apiKeyManager = apiKeyManager;

    if (!apiKeyManager.hasApiKey(ApiKeyManager.ApiKeyType.GEMINI)) {
      log.warn("Gemini API key is not configured. Some features may not work.");
    }
  }

  /**
   * 비동기 텍스트 생성 요청 (UI 스레드 블로킹 방지)
   */
  public CompletableFuture<String> generateContentAsync(String text) {
    return CompletableFuture.supplyAsync(() -> {
      try {
        return generateContentSync(text);
      } catch (Exception e) {
        log.error("Async content generation failed", e);
        throw new RuntimeException("Async content generation failed", e);
      }
    }, executor);
  }

  /**
   * 비동기 이미지 분석 요청
   */
  public CompletableFuture<String> analyzeImageAsync(String imageUrl, String prompt) {
    return CompletableFuture.supplyAsync(() -> {
      try {
        return analyzeImageSync(imageUrl, prompt);
      } catch (Exception e) {
        log.error("Async image analysis failed", e);
        throw new RuntimeException("Async image analysis failed", e);
      }
    }, executor);
  }

  /**
   * 동기 텍스트 생성 요청
   */
  @Retryable(value = { GeminiException.class }, maxAttempts = 3, backoff = @Backoff(delay = 1000, multiplier = 2))
  public String generateContentSync(String text) {
    if (!apiKeyManager.hasApiKey(ApiKeyManager.ApiKeyType.GEMINI)) {
      log.warn("⚠️ Gemini API 키가 설정되지 않음 - 규칙 기반 분석으로 전환");
      return generateIntelligentAnalysis(text);
    }

    log.info("🤖 Gemini API 호출 시작 - 텍스트 길이: {}", text.length());

    // 여러 모델을 순차적으로 시도
    String[] modelsToTry = {
        "gemini-2.5-pro",
        "gemini-1.5-pro",
        "gemini-1.5-flash"
    };

    for (String model : modelsToTry) {
      try {
        log.info("🔄 시도 중인 모델: {}", model);
        return tryGenerateContent(text, model);
      } catch (GeminiException e) {
        log.warn("❌ 모델 {} 실패: {}", model, e.getMessage());
        // 인증 오류인 경우 즉시 규칙 기반 분석으로 전환
        if (e.isAuthenticationError()) {
          log.warn("🔐 API 인증 실패 - 규칙 기반 분석으로 전환");
          return generateIntelligentAnalysis(text);
        }
        // 다른 오류는 다음 모델로 계속 진행
      }
    }
    
    // 모든 모델 실패시 규칙 기반 분석 제공
    log.warn("⚠️ 모든 Gemini 모델 실패 - 규칙 기반 분석으로 전환");
    return generateIntelligentAnalysis(text);
  }

  /**
   * 동기 이미지 분석 요청
   */
  @Retryable(value = { GeminiException.class }, maxAttempts = 3, backoff = @Backoff(delay = 1000, multiplier = 2))
  public String analyzeImageSync(String imageUrl, String prompt) {
    if (!apiKeyManager.hasApiKey(ApiKeyManager.ApiKeyType.GEMINI)) {
      log.warn("⚠️ Gemini API 키가 설정되지 않음 - 규칙 기반 이미지 분석으로 전환");
      return generateImageAnalysis(imageUrl, prompt);
    }

    log.info("🖼️ Gemini Vision API 호출 시작 - URL: {}", imageUrl);

    // 비전 모델들
    String[] visionModelsToTry = {
        "gemini-2.5-pro",
        "gemini-1.5-pro",
        "gemini-1.5-flash"
    };

    for (String model : visionModelsToTry) {
      try {
        log.info("🔄 이미지 분석 모델 시도: {}", model);
        return tryAnalyzeImage(imageUrl, prompt, model);
      } catch (GeminiException e) {
        log.warn("❌ 이미지 분석 모델 {} 실패: {}", model, e.getMessage());
        if (e.isAuthenticationError()) {
          log.warn("🔐 API 인증 실패 - 규칙 기반 이미지 분석으로 전환");
          return generateImageAnalysis(imageUrl, prompt);
        }
      }
    }
    
    // 모든 비전 모델 실패시 규칙 기반 분석으로 fallback
    log.warn("⚠️ 모든 Gemini Vision 모델 실패 - 규칙 기반 이미지 분석으로 전환");
    return generateImageAnalysis(imageUrl, prompt);
  }

  /**
   * 특정 모델로 텍스트 생성 시도
   */
  private String tryGenerateContent(String text, String model) {
    try {
      // 요청 객체 생성
      GeminiDto.GenerateContentRequest request = new GeminiDto.GenerateContentRequest();
      request.setContents(Arrays.asList(
          GeminiDto.Content.textContent(text)
      ));
      request.setGenerationConfig(new GeminiDto.GenerationConfig(0.7, 1000));

      // HTTP 헤더 설정
      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.APPLICATION_JSON);

      HttpEntity<GeminiDto.GenerateContentRequest> entity = new HttpEntity<>(request, headers);

      String url = BASE_URL + "/models/" + model + ":generateContent?key=" + apiKeyManager.getApiKey(ApiKeyManager.ApiKeyType.GEMINI);
      log.debug("📤 Gemini 요청: {}", url);

      // API 호출
      ResponseEntity<GeminiDto.GenerateContentResponse> response = restTemplate.exchange(
          url,
          HttpMethod.POST,
          entity,
          GeminiDto.GenerateContentResponse.class);

      // 응답 처리
      if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
        GeminiDto.GenerateContentResponse responseBody = response.getBody();

        if (responseBody.getCandidates() != null && !responseBody.getCandidates().isEmpty()) {
          GeminiDto.Candidate candidate = responseBody.getCandidates().get(0);
          if (candidate.getContent() != null && candidate.getContent().getParts() != null 
              && !candidate.getContent().getParts().isEmpty()) {
            String content = candidate.getContent().getParts().get(0).getText();

            log.info("✅ Gemini API 응답 성공 - 모델: {} 토큰 사용량: {}", 
                    model, responseBody.getUsageMetadata() != null ? responseBody.getUsageMetadata().getTotalTokenCount() : "unknown");

            return content;
          }
        }
        
        log.warn("⚠️ Gemini API 응답에 content가 없음");
        throw new GeminiException("No content in response");
      } else {
        log.error("❌ Gemini API 비정상 응답: {}", response.getStatusCode());
        throw new GeminiException("Unexpected response status: " + response.getStatusCode());
      }

    } catch (HttpClientErrorException e) {
      log.error("❌ Gemini API 클라이언트 오류: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
      throw new GeminiException(
          "Client error: " + e.getMessage(),
          e.getStatusCode().value());

    } catch (HttpServerErrorException e) {
      log.error("❌ Gemini API 서버 오류: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
      throw new GeminiException(
          "Server error: " + e.getMessage(),
          e.getStatusCode().value());

    } catch (ResourceAccessException e) {
      log.error("❌ Gemini API 네트워크 오류: {}", e.getMessage());
      throw new GeminiException("Network error: " + e.getMessage(), e);

    } catch (Exception e) {
      log.error("❌ Gemini API 예상치 못한 오류", e);
      throw new GeminiException("Unexpected error: " + e.getMessage(), e);
    }
  }

  /**
   * 특정 모델로 이미지 분석 시도
   */
  private String tryAnalyzeImage(String imageUrl, String prompt, String model) {
    try {
      // 이미지 데이터 가져오기
      byte[] imageData = fetchImageData(imageUrl);
      
      // 요청 객체 생성
      GeminiDto.GenerateContentRequest request = new GeminiDto.GenerateContentRequest();
      request.setContents(Arrays.asList(
          GeminiDto.Content.multimodalContent(prompt, imageData, "image/jpeg")
      ));
      request.setGenerationConfig(new GeminiDto.GenerationConfig(0.7, 1000));

      // HTTP 헤더 설정
      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.APPLICATION_JSON);

      HttpEntity<GeminiDto.GenerateContentRequest> entity = new HttpEntity<>(request, headers);

      String url = BASE_URL + "/models/" + model + ":generateContent?key=" + apiKeyManager.getApiKey(ApiKeyManager.ApiKeyType.GEMINI);
      log.debug("📤 Gemini Vision 요청: {}", url);

      // API 호출
      ResponseEntity<GeminiDto.GenerateContentResponse> response = restTemplate.exchange(
          url,
          HttpMethod.POST,
          entity,
          GeminiDto.GenerateContentResponse.class);

      // 응답 처리
      if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
        GeminiDto.GenerateContentResponse responseBody = response.getBody();

        if (responseBody.getCandidates() != null && !responseBody.getCandidates().isEmpty()) {
          GeminiDto.Candidate candidate = responseBody.getCandidates().get(0);
          if (candidate.getContent() != null && candidate.getContent().getParts() != null 
              && !candidate.getContent().getParts().isEmpty()) {
            String content = candidate.getContent().getParts().get(0).getText();

            log.info("✅ Gemini Vision API 응답 성공 - 모델: {}", model);
            return content;
          }
        }
        
        log.warn("⚠️ Gemini Vision API 응답에 content가 없음");
        throw new GeminiException("No content in vision response");
      } else {
        log.error("❌ Gemini Vision API 비정상 응답: {}", response.getStatusCode());
        throw new GeminiException("Unexpected vision response status: " + response.getStatusCode());
      }

    } catch (Exception e) {
      log.error("❌ Gemini Vision API 오류", e);
      throw new GeminiException("Vision API error: " + e.getMessage(), e);
    }
  }

  /**
   * 이미지 데이터 가져오기 (URL에서)
   */
  private byte[] fetchImageData(String imageUrl) {
    try {
      ResponseEntity<byte[]> response = restTemplate.getForEntity(imageUrl, byte[].class);
      return response.getBody();
    } catch (Exception e) {
      log.error("❌ 이미지 데이터 가져오기 실패: {}", imageUrl, e);
      throw new GeminiException("Failed to fetch image data: " + e.getMessage(), e);
    }
  }

  /**
   * 규칙 기반 텍스트 분석 생성 (AI API 실패시 fallback)
   */
  private String generateIntelligentAnalysis(String text) {
    log.info("🧠 규칙 기반 텍스트 분석 실행");
    
    // 텍스트 길이 기반 분석
    int textLength = text.length();
    String category = "일반";
    String sentiment = "중성";
    String summary = text.length() > 100 ? text.substring(0, 100) + "..." : text;
    
    // 키워드 기반 카테고리 분류
    if (text.contains("도로") || text.contains("교통") || text.contains("신호등")) {
      category = "교통/도로";
    } else if (text.contains("환경") || text.contains("오염") || text.contains("소음")) {
      category = "환경";
    } else if (text.contains("건물") || text.contains("시설") || text.contains("공사")) {
      category = "시설/건물";
    } else if (text.contains("사고") || text.contains("위험") || text.contains("응급")) {
      category = "안전/사고";
    }
    
    // 감정 분석
    if (text.contains("문제") || text.contains("불편") || text.contains("위험") || text.contains("심각")) {
      sentiment = "부정적";
    } else if (text.contains("좋") || text.contains("감사") || text.contains("만족")) {
      sentiment = "긍정적";
    }
    
    // JSON 형태로 응답 생성
    return String.format("""
        {
          "analysis": "규칙 기반 분석",
          "category": "%s",
          "sentiment": "%s", 
          "summary": "%s",
          "keywords": ["텍스트", "분석", "%s"],
          "confidence": 0.75,
          "recommendation": "자세한 분석을 위해 AI 서비스 연결을 확인해주세요."
        }
        """, category, sentiment, summary, category);
  }

  /**
   * 규칙 기반 이미지 분석 생성 (AI API 실패시 fallback)
   */
  private String generateImageAnalysis(String imageUrl, String prompt) {
    log.info("🧠 규칙 기반 이미지 분석 실행 - URL: {}", imageUrl);
    
    // URL 패턴 기반 분석
    String imageType = "일반 이미지";
    if (imageUrl.contains("road") || imageUrl.contains("traffic")) {
      imageType = "도로/교통 관련";
    } else if (imageUrl.contains("building") || imageUrl.contains("construction")) {
      imageType = "건물/시설 관련";
    } else if (imageUrl.contains("environment") || imageUrl.contains("pollution")) {
      imageType = "환경 관련";
    }
    
    return String.format("""
        {
          "analysis": "규칙 기반 이미지 분석",
          "object_type": "%s",
          "scene_type": "outdoor",
          "potential_issues": ["상세 분석 필요"],
          "recommended_action": "전문가 검토 요청",
          "confidence": 0.6,
          "note": "AI 비전 서비스 연결을 확인하여 정확한 분석을 받으세요."
        }
        """, imageType);
  }

  /**
   * 재시도 실패 시 복구 메서드
   */
  @Recover
  public String recoverGenerateContent(GeminiException ex, String text) {
    log.error("🔄 Gemini API 재시도 실패 - 최종 복구: {}", ex.getMessage());

    if (ex.isAuthenticationError()) {
      return "ERROR: API 인증 실패. API 키를 확인해주세요.";
    } else if (ex.isRateLimitError()) {
      return "ERROR: API 사용량 제한 초과. 잠시 후 다시 시도해주세요.";
    } else {
      return generateIntelligentAnalysis(text);
    }
  }

  /**
   * API 상태 확인
   */
  public boolean isApiAvailable() {
    if (!apiKeyManager.hasApiKey(ApiKeyManager.ApiKeyType.GEMINI)) {
      return false;
    }

    try {
      // 간단한 테스트 요청
      generateContentSync("Hello");
      return true;
    } catch (Exception e) {
      log.warn("Gemini API 사용 불가: {}", e.getMessage());
      return false;
    }
  }

  /**
   * 텍스트 분석 (비동기)
   */
  public CompletableFuture<String> analyzeTextAsync(String text) {
    String systemPrompt = """
        다음 텍스트를 분석하여 JSON 형태로 응답해주세요:
        - category: 텍스트의 주요 카테고리
        - sentiment: 감정 (positive, negative, neutral)
        - keywords: 주요 키워드 목록
        - summary: 요약
        - confidence: 분석 신뢰도 (0-1)
        
        분석할 텍스트: 
        """;

    return generateContentAsync(systemPrompt + text);
  }
}