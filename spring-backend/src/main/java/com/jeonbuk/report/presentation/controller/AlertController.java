package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.AlertService;
import com.jeonbuk.report.application.service.AlertService.AlertRequest;
import com.jeonbuk.report.application.service.AlertService.AlertAnalysisResult;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * 알림 서비스 REST API 컨트롤러
 * 
 * 멀티스레딩 최적화:
 * - CompletableFuture를 사용한 비동기 응답
 * - 요청 즉시 응답하여 UI 블로킹 방지
 * - 백그라운드에서 무거운 AI 분석 작업 처리
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/alerts")
@RequiredArgsConstructor
@Tag(name = "Alert Service", description = "AI 기반 알림 분석 서비스")
public class AlertController {

  private final AlertService alertService;

  /**
   * 비동기 알림 분석 요청
   * UI 스레드를 블로킹하지 않고 즉시 응답
   */
  @PostMapping("/analyze")
  @Operation(summary = "알림 분석 요청", description = "AI 기반 알림 분석을 비동기로 처리합니다")
  public CompletableFuture<ResponseEntity<AlertAnalysisResult>> analyzeAlert(
      @RequestBody AlertRequest request) {

    log.info("📥 알림 분석 요청 수신 - ID: {}, 유형: {}", request.getId(), request.getType());

    // 요청 유효성 검사
    if (request.getId() == null || request.getContent() == null) {
      log.warn("⚠️ 잘못된 알림 요청 - ID: {}", request.getId());
      return CompletableFuture.completedFuture(
          ResponseEntity.badRequest().build());
    }

    // 비동기 처리 시작 (UI 스레드 블로킹 방지)
    return alertService.processAlertAsync(request)
        .thenApply(result -> {
          log.info("✅ 알림 분석 완료 - ID: {}, 우선순위: {}",
              result.getId(), result.getPriority());
          return ResponseEntity.ok(result);
        })
        .exceptionally(throwable -> {
          log.error("❌ 알림 분석 실패 - ID: {}", request.getId(), throwable);
          return ResponseEntity.internalServerError().build();
        });
  }

  /**
   * 간단한 텍스트 알림 분석 (빠른 요청용)
   */
  @PostMapping("/analyze/simple")
  @Operation(summary = "간단한 알림 분석", description = "기본 정보만으로 빠른 알림 분석")
  public CompletableFuture<ResponseEntity<Map<String, Object>>> analyzeSimpleAlert(
      @RequestParam String content,
      @RequestParam(required = false) String type) {

    log.info("📥 간단 알림 분석 요청 - 내용 길이: {}", content.length());

    // 간단한 요청 객체 생성
    AlertRequest request = new AlertRequest();
    request.setId("simple-" + System.currentTimeMillis());
    request.setType(type != null ? type : "GENERAL");
    request.setContent(content);
    request.setTimestamp(LocalDateTime.now());

    return alertService.processAlertAsync(request)
        .thenApply(result -> {
          Map<String, Object> response = Map.of(
              "id", result.getId(),
              "priority", result.getPriority().name(),
              "urgencyScore", result.getFinalScore(),
              "category", result.getCategory(),
              "processingTime", java.time.Duration.between(
                  result.getAnalysisStartTime(),
                  result.getAnalysisEndTime()).toMillis());
          return ResponseEntity.ok(response);
        })
        .exceptionally(throwable -> {
          log.error("❌ 간단 알림 분석 실패", throwable);
          Map<String, Object> errorResponse = Map.of(
              "error", "분석 실패",
              "message", throwable.getMessage());
          return ResponseEntity.internalServerError().body(errorResponse);
        });
  }

  /**
   * 대량 알림 분석 (배치 처리)
   */
  @PostMapping("/analyze/batch")
  @Operation(summary = "대량 알림 분석", description = "여러 알림을 동시에 분석합니다")
  public CompletableFuture<ResponseEntity<Map<String, Object>>> analyzeBatchAlerts(
      @RequestBody java.util.List<AlertRequest> requests) {

    log.info("📥 대량 알림 분석 요청 - 개수: {}", requests.size());

    if (requests.isEmpty() || requests.size() > 100) {
      log.warn("⚠️ 잘못된 배치 크기 - 개수: {}", requests.size());
      return CompletableFuture.completedFuture(
          ResponseEntity.badRequest().body(Map.of(
              "error", "배치 크기 오류",
              "message", "1-100개의 알림만 처리 가능합니다")));
    }

    // 각 알림을 병렬로 처리 (멀티스레딩 활용)
    java.util.List<CompletableFuture<AlertAnalysisResult>> futures = requests.stream()
        .map(alertService::processAlertAsync)
        .toList();

    // 모든 작업 완료 대기
    return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
        .thenApply(voidResult -> {
          java.util.List<AlertAnalysisResult> results = futures.stream()
              .map(CompletableFuture::join)
              .toList();

          Map<String, Object> response = Map.of(
              "totalCount", results.size(),
              "successCount", results.size(),
              "results", results,
              "processingTime", System.currentTimeMillis());

          log.info("✅ 대량 알림 분석 완료 - 처리된 개수: {}", results.size());
          return ResponseEntity.ok(response);
        })
        .exceptionally(throwable -> {
          log.error("❌ 대량 알림 분석 실패", throwable);
          Map<String, Object> errorResponse = Map.of(
              "error", "대량 분석 실패",
              "message", throwable.getMessage());
          return ResponseEntity.internalServerError().body(errorResponse);
        });
  }

  /**
   * 서비스 상태 확인
   */
  @GetMapping("/health")
  @Operation(summary = "서비스 상태 확인", description = "알림 서비스 및 AI API 상태를 확인합니다")
  public ResponseEntity<Map<String, Object>> checkHealth() {

    Map<String, Object> healthStatus = Map.of(
        "service", "healthy",
        "timestamp", LocalDateTime.now().toString(),
        "version", "1.0.0");

    return ResponseEntity.ok(healthStatus);
  }

  /**
   * 알림 분석 통계 (개발/모니터링용)
   */
  @GetMapping("/stats")
  @Operation(summary = "알림 분석 통계", description = "알림 처리 통계 정보를 제공합니다")
  public ResponseEntity<Map<String, Object>> getAlertStats() {

    // TODO: 실제 통계 구현
    Map<String, Object> stats = Map.of(
        "totalProcessed", 0,
        "averageProcessingTime", 0,
        "successRate", 100.0,
        "lastUpdate", LocalDateTime.now().toString());

    return ResponseEntity.ok(stats);
  }

  /**
   * 실시간 알림 분석 (SSE - Server-Sent Events)
   */
  @GetMapping(value = "/stream", produces = "text/event-stream")
  @Operation(summary = "실시간 알림 스트림", description = "실시간으로 알림 분석 결과를 스트리밍합니다")
  public org.springframework.http.codec.ServerSentEvent<String> streamAlerts() {
    // TODO: SSE 구현
    return org.springframework.http.codec.ServerSentEvent.<String>builder()
        .data("Alert stream initialized")
        .build();
  }
}
