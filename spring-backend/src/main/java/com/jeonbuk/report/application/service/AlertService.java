package com.jeonbuk.report.application.service;

import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterApiClient;
import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.scheduling.annotation.Async;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * 알림 서비스 - AI 기반 자동 알림 생성
 * 
 * 멀티스레딩 최적화:
 * - @Async 어노테이션으로 비동기 처리
 * - CompletableFuture를 활용한 non-blocking 작업
 * - 백그라운드에서 AI 분석 및 알림 처리
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AlertService {

  private final OpenRouterApiClient openRouterApiClient;
  private final KafkaTemplate<String, Object> kafkaTemplate;

  /**
   * 비동기 알림 분석 및 처리 (UI 스레드 블로킹 방지)
   */
  @Async("alertProcessingExecutor")
  public CompletableFuture<AlertAnalysisResult> processAlertAsync(AlertRequest request) {
    log.info("🚨 알림 처리 시작 - ID: {}, 유형: {}", request.getId(), request.getType());

    return CompletableFuture
        .supplyAsync(() -> analyzeAlertData(request))
        .thenCompose(this::enhanceWithAiAnalysis)
        .thenApply(this::determineAlertPriority)
        .thenApply(result -> {
          // 카프카로 알림 이벤트 발송 (비동기)
          sendAlertToKafkaAsync(result);
          return result;
        })
        .whenComplete((result, throwable) -> {
          if (throwable != null) {
            log.error("❌ 알림 처리 실패 - ID: {}", request.getId(), throwable);
            // 실패한 알림도 카프카로 전송 (에러 추적용)
            sendFailedAlertToKafka(request, throwable);
          } else {
            log.info("✅ 알림 처리 완료 - ID: {}, 우선순위: {}",
                request.getId(), result.getPriority());
          }
        });
  }

  /**
   * 기본 알림 데이터 분석 (동기식, 빠른 처리)
   */
  private AlertAnalysisResult analyzeAlertData(AlertRequest request) {
    log.debug("🔍 기본 알림 분석 시작 - {}", request.getType());

    AlertAnalysisResult result = new AlertAnalysisResult();
    result.setId(request.getId());
    result.setOriginalRequest(request);
    result.setAnalysisStartTime(LocalDateTime.now());

    // 키워드 기반 초기 분석
    String content = request.getContent().toLowerCase();

    // 긴급도 키워드 검사
    if (containsUrgentKeywords(content)) {
      result.setUrgencyScore(0.8);
      result.addAnalysisNote("긴급 키워드 감지");
    } else if (containsImportantKeywords(content)) {
      result.setUrgencyScore(0.6);
      result.addAnalysisNote("중요 키워드 감지");
    } else {
      result.setUrgencyScore(0.3);
      result.addAnalysisNote("일반 알림");
    }

    // 카테고리 초기 분류
    result.setCategory(classifyByKeywords(content));

    log.debug("📊 기본 분석 완료 - 긴급도: {}, 카테고리: {}",
        result.getUrgencyScore(), result.getCategory());

    return result;
  }

  /**
   * AI 분석으로 결과 개선 (비동기, 무거운 작업)
   */
  private CompletableFuture<AlertAnalysisResult> enhanceWithAiAnalysis(AlertAnalysisResult result) {
    log.debug("🤖 AI 분석 강화 시작");

    if (!openRouterApiClient.isApiAvailable()) {
      log.warn("⚠️ OpenRouter API 사용 불가 - 기본 분석 결과 사용");
      result.setAiAnalysisAvailable(false);
      return CompletableFuture.completedFuture(result);
    }

    String systemPrompt = createAlertAnalysisPrompt();
    String userPrompt = createUserPromptForAlert(result.getOriginalRequest());

    return openRouterApiClient
        .chatCompletionAsync(systemPrompt, userPrompt)
        .thenApply(aiResponse -> {
          try {
            // AI 응답 파싱 및 결과 업데이트
            parseAiAnalysisResponse(result, aiResponse);
            result.setAiAnalysisAvailable(true);
            log.debug("✅ AI 분석 완료 - 향상된 긴급도: {}", result.getUrgencyScore());
          } catch (Exception e) {
            log.warn("⚠️ AI 응답 파싱 실패 - 기본 분석 사용: {}", e.getMessage());
            result.setAiAnalysisAvailable(false);
          }
          return result;
        })
        .exceptionally(throwable -> {
          log.warn("⚠️ AI 분석 실패 - 기본 분석 사용: {}", throwable.getMessage());
          result.setAiAnalysisAvailable(false);
          return result;
        });
  }

  /**
   * 알림 우선순위 결정 (최종 단계)
   */
  private AlertAnalysisResult determineAlertPriority(AlertAnalysisResult result) {
    log.debug("⚖️ 우선순위 결정 시작");

    double finalScore = result.getUrgencyScore();

    // 시간 요소 고려 (야간/주말 가중치)
    LocalDateTime now = LocalDateTime.now();
    if (isOffHours(now)) {
      finalScore *= 1.2; // 20% 가중치
      result.addAnalysisNote("시간외 가중치 적용");
    }

    // 최종 우선순위 결정
    AlertPriority priority;
    if (finalScore >= 0.8) {
      priority = AlertPriority.CRITICAL;
    } else if (finalScore >= 0.6) {
      priority = AlertPriority.HIGH;
    } else if (finalScore >= 0.4) {
      priority = AlertPriority.MEDIUM;
    } else {
      priority = AlertPriority.LOW;
    }

    result.setPriority(priority);
    result.setFinalScore(finalScore);
    result.setAnalysisEndTime(LocalDateTime.now());

    log.debug("📋 최종 우선순위: {} (점수: {})", priority, finalScore);
    return result;
  }

  /**
   * 카프카로 알림 이벤트 전송 (비동기)
   */
  @Async("kafkaPublishingExecutor")
  public void sendAlertToKafkaAsync(AlertAnalysisResult result) {
    try {
      Map<String, Object> alertEvent = Map.of(
          "eventType", "ALERT_PROCESSED",
          "alertId", result.getId(),
          "priority", result.getPriority().name(),
          "category", result.getCategory(),
          "urgencyScore", result.getFinalScore(),
          "aiAnalysisUsed", result.isAiAnalysisAvailable(),
          "processedAt", result.getAnalysisEndTime().toString(),
          "processingTime", java.time.Duration.between(
              result.getAnalysisStartTime(),
              result.getAnalysisEndTime()).toMillis());

      kafkaTemplate.send("alert-events", result.getId(), alertEvent);
      log.debug("📤 카프카 알림 이벤트 전송 완료 - ID: {}", result.getId());

    } catch (Exception e) {
      log.error("❌ 카프카 알림 이벤트 전송 실패 - ID: {}", result.getId(), e);
    }
  }

  /**
   * 실패한 알림 카프카 전송
   */
  private void sendFailedAlertToKafka(AlertRequest request, Throwable error) {
    try {
      Map<String, Object> errorEvent = Map.of(
          "eventType", "ALERT_PROCESSING_FAILED",
          "alertId", request.getId(),
          "errorMessage", error.getMessage(),
          "errorType", error.getClass().getSimpleName(),
          "failedAt", LocalDateTime.now().toString());

      kafkaTemplate.send("alert-errors", request.getId(), errorEvent);
      log.debug("📤 카프카 에러 이벤트 전송 완료 - ID: {}", request.getId());

    } catch (Exception e) {
      log.error("❌ 카프카 에러 이벤트 전송 실패 - ID: {}", request.getId(), e);
    }
  }

  // === 유틸리티 메서드들 ===

  private boolean containsUrgentKeywords(String content) {
    String[] urgentKeywords = {
        "긴급", "응급", "위험", "사고", "화재", "폭발", "붕괴", "침수",
        "urgent", "emergency", "critical", "danger"
    };
    return Arrays.stream(urgentKeywords)
        .anyMatch(content::contains);
  }

  private boolean containsImportantKeywords(String content) {
    String[] importantKeywords = {
        "중요", "주의", "경고", "문제", "고장", "누수", "파손",
        "important", "warning", "issue", "problem"
    };
    return Arrays.stream(importantKeywords)
        .anyMatch(content::contains);
  }

  private String classifyByKeywords(String content) {
    if (content.contains("화재") || content.contains("fire"))
      return "FIRE";
    if (content.contains("침수") || content.contains("flood"))
      return "FLOOD";
    if (content.contains("전기") || content.contains("electric"))
      return "ELECTRICAL";
    if (content.contains("가스") || content.contains("gas"))
      return "GAS";
    if (content.contains("도로") || content.contains("traffic"))
      return "TRAFFIC";
    return "GENERAL";
  }

  private boolean isOffHours(LocalDateTime dateTime) {
    int hour = dateTime.getHour();
    int dayOfWeek = dateTime.getDayOfWeek().getValue();

    // 야간 (22시-06시) 또는 주말
    return hour >= 22 || hour <= 6 || dayOfWeek >= 6;
  }

  private String createAlertAnalysisPrompt() {
    return """
        당신은 전문적인 알림 분석 시스템입니다.
        다음 정보를 JSON 형태로 분석해주세요:

        분석할 항목:
        1. urgency_score: 0.0-1.0 사이의 긴급도 점수
        2. category: 알림 카테고리 (FIRE, FLOOD, ELECTRICAL, GAS, TRAFFIC, GENERAL)
        3. risk_level: 위험도 (LOW, MEDIUM, HIGH, CRITICAL)
        4. recommended_action: 권장 조치사항
        5. estimated_impact: 예상 영향도

        응답 형식:
        {
          "urgency_score": 0.0,
          "category": "CATEGORY",
          "risk_level": "LEVEL",
          "recommended_action": "조치사항",
          "estimated_impact": "영향도"
        }
        """;
  }

  private String createUserPromptForAlert(AlertRequest request) {
    return String.format("""
        알림 분석 요청:

        유형: %s
        제목: %s
        내용: %s
        위치: %s
        시간: %s
        추가정보: %s
        """,
        request.getType(),
        request.getTitle(),
        request.getContent(),
        request.getLocation(),
        request.getTimestamp(),
        request.getMetadata());
  }

  private void parseAiAnalysisResponse(AlertAnalysisResult result, String aiResponse) {
    // TODO: JSON 파싱 구현
    // 실제 구현에서는 Jackson을 사용하여 JSON 파싱
    log.debug("AI 응답 파싱: {}", aiResponse);

    // 임시 구현 - 실제로는 JSON 파싱 필요
    if (aiResponse.contains("CRITICAL") || aiResponse.contains("urgency_score\": 0.9")) {
      result.setUrgencyScore(0.9);
    } else if (aiResponse.contains("HIGH") || aiResponse.contains("urgency_score\": 0.7")) {
      result.setUrgencyScore(0.7);
    }
  }

  // === 내부 클래스들 ===

  public static class AlertRequest {
    private String id;
    private String type;
    private String title;
    private String content;
    private String location;
    private LocalDateTime timestamp;
    private Map<String, Object> metadata;

    // Getters and setters
    public String getId() {
      return id;
    }

    public void setId(String id) {
      this.id = id;
    }

    public String getType() {
      return type;
    }

    public void setType(String type) {
      this.type = type;
    }

    public String getTitle() {
      return title;
    }

    public void setTitle(String title) {
      this.title = title;
    }

    public String getContent() {
      return content;
    }

    public void setContent(String content) {
      this.content = content;
    }

    public String getLocation() {
      return location;
    }

    public void setLocation(String location) {
      this.location = location;
    }

    public LocalDateTime getTimestamp() {
      return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
      this.timestamp = timestamp;
    }

    public Map<String, Object> getMetadata() {
      return metadata;
    }

    public void setMetadata(Map<String, Object> metadata) {
      this.metadata = metadata;
    }
  }

  public static class AlertAnalysisResult {
    private String id;
    private AlertRequest originalRequest;
    private double urgencyScore;
    private double finalScore;
    private String category;
    private AlertPriority priority;
    private boolean aiAnalysisAvailable;
    private LocalDateTime analysisStartTime;
    private LocalDateTime analysisEndTime;
    private List<String> analysisNotes = new java.util.ArrayList<>();

    // Getters and setters
    public String getId() {
      return id;
    }

    public void setId(String id) {
      this.id = id;
    }

    public AlertRequest getOriginalRequest() {
      return originalRequest;
    }

    public void setOriginalRequest(AlertRequest originalRequest) {
      this.originalRequest = originalRequest;
    }

    public double getUrgencyScore() {
      return urgencyScore;
    }

    public void setUrgencyScore(double urgencyScore) {
      this.urgencyScore = urgencyScore;
    }

    public double getFinalScore() {
      return finalScore;
    }

    public void setFinalScore(double finalScore) {
      this.finalScore = finalScore;
    }

    public String getCategory() {
      return category;
    }

    public void setCategory(String category) {
      this.category = category;
    }

    public AlertPriority getPriority() {
      return priority;
    }

    public void setPriority(AlertPriority priority) {
      this.priority = priority;
    }

    public boolean isAiAnalysisAvailable() {
      return aiAnalysisAvailable;
    }

    public void setAiAnalysisAvailable(boolean aiAnalysisAvailable) {
      this.aiAnalysisAvailable = aiAnalysisAvailable;
    }

    public LocalDateTime getAnalysisStartTime() {
      return analysisStartTime;
    }

    public void setAnalysisStartTime(LocalDateTime analysisStartTime) {
      this.analysisStartTime = analysisStartTime;
    }

    public LocalDateTime getAnalysisEndTime() {
      return analysisEndTime;
    }

    public void setAnalysisEndTime(LocalDateTime analysisEndTime) {
      this.analysisEndTime = analysisEndTime;
    }

    public List<String> getAnalysisNotes() {
      return analysisNotes;
    }

    public void setAnalysisNotes(List<String> analysisNotes) {
      this.analysisNotes = analysisNotes;
    }

    public void addAnalysisNote(String note) {
      this.analysisNotes.add(note);
    }
  }

  public enum AlertPriority {
    LOW, MEDIUM, HIGH, CRITICAL
  }
}
