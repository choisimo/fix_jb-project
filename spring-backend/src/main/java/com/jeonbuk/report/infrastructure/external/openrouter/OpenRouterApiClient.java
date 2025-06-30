package com.jeonbuk.report.infrastructure.external.openrouter;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
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
 * OpenRouter AI API 클라이언트
 * 
 * 멀티스레딩 지원:
 * - 비동기 API 호출을 위한 CompletableFuture 사용
 * - UI 스레드 블로킹 방지
 * - 백그라운드 스레드풀에서 실행
 */
@Slf4j
@Service
public class OpenRouterApiClient {

  private static final String BASE_URL = "https://openrouter.ai/api/v1";
  private static final String CHAT_COMPLETIONS_ENDPOINT = "/chat/completions";
  private static final String DEFAULT_MODEL = "qwen/qwen2.5-vl-72b-instruct:free";

  // 백그라운드 스레드 풀 (UI 스레드 블로킹 방지)
  private final Executor executor = Executors.newFixedThreadPool(4);

  private final RestTemplate restTemplate;
  private final ObjectMapper objectMapper;
  private final String apiKey;

  public OpenRouterApiClient(
      RestTemplate restTemplate,
      ObjectMapper objectMapper,
      @Value("${openrouter.api.key:#{null}}") String apiKey) {
    this.restTemplate = restTemplate;
    this.objectMapper = objectMapper;
    this.apiKey = apiKey;

    if (apiKey == null || apiKey.trim().isEmpty()) {
      log.warn("OpenRouter API key is not configured. Some features may not work.");
    }
  }

  /**
   * 비동기 채팅 완성 요청 (UI 스레드 블로킹 방지)
   */
  public CompletableFuture<String> chatCompletionAsync(List<OpenRouterDto.Message> messages) {
    return CompletableFuture.supplyAsync(() -> {
      try {
        return chatCompletionSync(messages);
      } catch (Exception e) {
        log.error("Async chat completion failed", e);
        throw new RuntimeException("Async chat completion failed", e);
      }
    }, executor);
  }

  /**
   * 비동기 채팅 완성 요청 - 단일 메시지
   */
  public CompletableFuture<String> chatCompletionAsync(String userMessage) {
    return chatCompletionAsync(Arrays.asList(
        OpenRouterDto.Message.user(userMessage)));
  }

  /**
   * 비동기 채팅 완성 요청 - 시스템 프롬프트 포함
   */
  public CompletableFuture<String> chatCompletionAsync(String systemPrompt, String userMessage) {
    return chatCompletionAsync(Arrays.asList(
        OpenRouterDto.Message.system(systemPrompt),
        OpenRouterDto.Message.user(userMessage)));
  }

  /**
   * 동기 채팅 완성 요청 (백그라운드 작업용)
   */
  @Retryable(value = { OpenRouterException.class }, maxAttempts = 3, backoff = @Backoff(delay = 1000, multiplier = 2))
  public String chatCompletionSync(List<OpenRouterDto.Message> messages) {
    if (apiKey == null || apiKey.trim().isEmpty()) {
      throw new OpenRouterException("OpenRouter API key is not configured");
    }

    log.info("🤖 OpenRouter API 호출 시작 - 메시지 수: {}", messages.size());

    try {
      // 요청 객체 생성
      OpenRouterDto.ChatCompletionRequest request = new OpenRouterDto.ChatCompletionRequest();
      request.setModel(DEFAULT_MODEL);
      request.setMessages(messages);
      request.setTemperature(0.7);
      request.setMaxTokens(1000);
      request.setStream(false);

      // HTTP 헤더 설정
      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.APPLICATION_JSON);
      headers.setBearerAuth(apiKey);
      headers.set("HTTP-Referer", "https://jeonbuk-report-platform.com");
      headers.set("X-Title", "전북 신고 플랫폼");

      HttpEntity<OpenRouterDto.ChatCompletionRequest> entity = new HttpEntity<>(request, headers);

      log.debug("📤 OpenRouter 요청: {} {}", BASE_URL + CHAT_COMPLETIONS_ENDPOINT, request.getModel());

      // API 호출 (백그라운드 스레드에서 실행)
      ResponseEntity<OpenRouterDto.ChatCompletionResponse> response = restTemplate.exchange(
          BASE_URL + CHAT_COMPLETIONS_ENDPOINT,
          HttpMethod.POST,
          entity,
          OpenRouterDto.ChatCompletionResponse.class);

      // 응답 처리
      if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
        OpenRouterDto.ChatCompletionResponse responseBody = response.getBody();

        if (responseBody.getChoices() != null && !responseBody.getChoices().isEmpty()) {
          String content = responseBody.getChoices().get(0).getMessage().getContent();

          log.info("✅ OpenRouter API 응답 성공 - 토큰 사용량: {}",
              responseBody.getUsage() != null ? responseBody.getUsage().getTotalTokens() : "unknown");

          return content;
        } else {
          log.warn("⚠️ OpenRouter API 응답에 choices가 없음");
          throw new OpenRouterException("No choices in response");
        }
      } else {
        log.error("❌ OpenRouter API 비정상 응답: {}", response.getStatusCode());
        throw new OpenRouterException("Unexpected response status: " + response.getStatusCode());
      }

    } catch (HttpClientErrorException e) {
      log.error("❌ OpenRouter API 클라이언트 오류: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());

      // 에러 응답 파싱 시도
      try {
        OpenRouterDto.ErrorResponse errorResponse = objectMapper.readValue(
            e.getResponseBodyAsString(), OpenRouterDto.ErrorResponse.class);

        throw new OpenRouterException(
            errorResponse.getError().getMessage(),
            e.getStatusCode().value(),
            errorResponse.getError().getCode(),
            errorResponse.getError().getType());
      } catch (Exception parseException) {
        throw new OpenRouterException(
            "Client error: " + e.getMessage(),
            e.getStatusCode().value());
      }

    } catch (HttpServerErrorException e) {
      log.error("❌ OpenRouter API 서버 오류: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
      throw new OpenRouterException(
          "Server error: " + e.getMessage(),
          e.getStatusCode().value());

    } catch (ResourceAccessException e) {
      log.error("❌ OpenRouter API 네트워크 오류: {}", e.getMessage());
      throw new OpenRouterException("Network error: " + e.getMessage(), e);

    } catch (Exception e) {
      log.error("❌ OpenRouter API 예상치 못한 오류", e);
      throw new OpenRouterException("Unexpected error: " + e.getMessage(), e);
    }
  }

  /**
   * 단순 텍스트 분석 (비동기)
   */
  public CompletableFuture<String> analyzeTextAsync(String text) {
    String systemPrompt = """
        당신은 텍스트 분석 전문가입니다.
        주어진 텍스트를 분석하여 다음 정보를 JSON 형태로 제공해주세요:
        - category: 텍스트의 주요 카테고리
        - sentiment: 감정 (positive, negative, neutral)
        - keywords: 주요 키워드 목록
        - summary: 요약
        """;

    return chatCompletionAsync(systemPrompt, "분석할 텍스트: " + text);
  }

  /**
   * 이미지 설명 분석 (비동기)
   */
  public CompletableFuture<String> analyzeImageDescriptionAsync(String imageDescription) {
    String systemPrompt = """
        당신은 이미지 분석 전문가입니다.
        이미지 설명을 바탕으로 다음 정보를 JSON 형태로 제공해주세요:
        - object_type: 주요 객체 유형
        - scene_type: 장면 유형 (indoor, outdoor, etc.)
        - potential_issues: 잠재적 문제점들
        - recommended_action: 권장 조치사항
        """;

    return chatCompletionAsync(systemPrompt, "이미지 설명: " + imageDescription);
  }

  /**
   * 재시도 실패 시 복구 메서드
   */
  @Recover
  public String recoverChatCompletion(OpenRouterException ex, List<OpenRouterDto.Message> messages) {
    log.error("🔄 OpenRouter API 재시도 실패 - 최종 복구: {}", ex.getMessage());

    if (ex.isAuthenticationError()) {
      return "ERROR: API 인증 실패. API 키를 확인해주세요.";
    } else if (ex.isRateLimitError()) {
      return "ERROR: API 사용량 제한 초과. 잠시 후 다시 시도해주세요.";
    } else {
      return "ERROR: AI 분석 서비스 일시 중단. 기본 분석 결과를 사용합니다.";
    }
  }

  /**
   * API 상태 확인
   */
  public boolean isApiAvailable() {
    if (apiKey == null || apiKey.trim().isEmpty()) {
      return false;
    }

    try {
      // 간단한 테스트 요청
      chatCompletionSync(Arrays.asList(
          OpenRouterDto.Message.user("Hello")));
      return true;
    } catch (Exception e) {
      log.warn("OpenRouter API 사용 불가: {}", e.getMessage());
      return false;
    }
  }
}
