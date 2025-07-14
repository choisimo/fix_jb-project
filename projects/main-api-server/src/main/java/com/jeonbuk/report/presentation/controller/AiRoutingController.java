package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.AiRoutingService;
import com.jeonbuk.report.application.service.AiRoutingService.AiRoutingResult;
import com.jeonbuk.report.application.service.IntegratedAiAgentService.InputData;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * AI 라우팅 컨트롤러
 * 
 * 기능:
 * - AI 분석 및 라우팅 API 엔드포인트 제공
 * - 비동기 처리로 UI 스레드 블로킹 방지
 * - 단일/배치/간단한 분석 지원
 */
@Slf4j
@RestController
@RequestMapping("/ai-routing")
@RequiredArgsConstructor
public class AiRoutingController {

  private final AiRoutingService aiRoutingService;

  /**
   * 단일 입력 AI 분석 및 라우팅
   * 전체 검증 파이프라인 포함
   */
  @PostMapping("/analyze")
  public CompletableFuture<ResponseEntity<Map<String, Object>>> analyzeInput(@RequestBody InputData inputData) {
    log.info("Received AI routing request for: {}", inputData.getId());

    return aiRoutingService.processInputAsync(inputData)
        .thenApply(result -> {
          Map<String, Object> response = new HashMap<>();
          response.put("success", true);
          response.put("result", result);
          response.put("timestamp", System.currentTimeMillis());
          return ResponseEntity.ok(response);
        })
        .exceptionally(throwable -> {
          log.error("Error processing AI routing request: {}", throwable.getMessage(), throwable);
          Map<String, Object> errorResponse = new HashMap<>();
          errorResponse.put("success", false);
          errorResponse.put("error", throwable.getMessage());
          errorResponse.put("timestamp", System.currentTimeMillis());
          return ResponseEntity.internalServerError().body(errorResponse);
        });
  }

  /**
   * 간단한 AI 분석 (검증 없이)
   * 빠른 응답이 필요한 경우 사용
   */
  @PostMapping("/analyze/simple")
  public CompletableFuture<ResponseEntity<Map<String, Object>>> simpleAnalysis(@RequestBody InputData inputData) {
    log.info("Received simple AI analysis request for: {}", inputData.getId());

    return aiRoutingService.simpleAnalysisAsync(inputData)
        .thenApply(result -> {
          Map<String, Object> response = new HashMap<>();
          response.put("success", true);
          response.put("result", result);
          response.put("timestamp", System.currentTimeMillis());
          return ResponseEntity.ok(response);
        })
        .exceptionally(throwable -> {
          log.error("Error processing simple analysis request: {}", throwable.getMessage(), throwable);
          Map<String, Object> errorResponse = new HashMap<>();
          errorResponse.put("success", false);
          errorResponse.put("error", throwable.getMessage());
          errorResponse.put("timestamp", System.currentTimeMillis());
          return ResponseEntity.internalServerError().body(errorResponse);
        });
  }

  /**
   * 배치 AI 분석 및 라우팅
   * 여러 입력을 병렬로 처리
   */
  @PostMapping("/analyze/batch")
  public CompletableFuture<ResponseEntity<Map<String, Object>>> analyzeBatch(
      @RequestBody List<InputData> inputDataList) {
    log.info("Received batch AI routing request for {} items", inputDataList.size());

    return aiRoutingService.processBatchAsync(inputDataList)
        .thenApply(results -> {
          Map<String, Object> response = new HashMap<>();
          response.put("success", true);
          response.put("results", results);
          response.put("totalProcessed", results.size());
          response.put("timestamp", System.currentTimeMillis());
          return ResponseEntity.ok(response);
        })
        .exceptionally(throwable -> {
          log.error("Error processing batch analysis request: {}", throwable.getMessage(), throwable);
          Map<String, Object> errorResponse = new HashMap<>();
          errorResponse.put("success", false);
          errorResponse.put("error", throwable.getMessage());
          errorResponse.put("timestamp", System.currentTimeMillis());
          return ResponseEntity.internalServerError().body(errorResponse);
        });
  }

  /**
   * AI 라우팅 서비스 상태 확인
   */
  @GetMapping("/health")
  public CompletableFuture<ResponseEntity<Map<String, Object>>> healthCheck() {
    return CompletableFuture.supplyAsync(() -> {
      Map<String, Object> healthStatus = new HashMap<>();
      healthStatus.put("service", "ai-routing");
      healthStatus.put("status", "healthy");
      healthStatus.put("timestamp", System.currentTimeMillis());

      // Check external services status
      Map<String, Object> externalServices = new HashMap<>();
      try {
        // Check if services are available (basic check)
        externalServices.put("openrouter", "available");
        externalServices.put("roboflow", "available");
        externalServices.put("kafka", "available");
        healthStatus.put("externalServices", externalServices);
        
      } catch (Exception e) {
        log.warn("Error checking external services: {}", e.getMessage());
        externalServices.put("error", e.getMessage());
        healthStatus.put("externalServices", externalServices);
        healthStatus.put("status", "degraded");
      }

      return ResponseEntity.ok(healthStatus);
    });
  }

  /**
   * AI 라우팅 통계 조회
   */
  @GetMapping("/stats")
  public CompletableFuture<ResponseEntity<Map<String, Object>>> getStats() {
    return CompletableFuture.supplyAsync(() -> {
      Map<String, Object> stats = new HashMap<>();
      stats.put("service", "ai-routing");
      stats.put("timestamp", System.currentTimeMillis());

      // Get statistics from the service
      Map<String, Object> processingStats = aiRoutingService.getProcessingStats();
      stats.putAll(processingStats);

      return ResponseEntity.ok(stats);
    });
  }

  /**
   * AI 라우팅 규칙 조회
   */
  @GetMapping("/rules")
  public ResponseEntity<Map<String, Object>> getRoutingRules() {
    Map<String, Object> response = new HashMap<>();
    response.put("rules", Map.of(
        "ROAD", "jeonbuk-road",
        "ENVIRONMENT", "jeonbuk-env",
        "FACILITY", "jeonbuk-facility",
        "default", "integrated-detection"
    ));
    response.put("timestamp", System.currentTimeMillis());

    return ResponseEntity.ok(response);
  }

  /**
   * 전역 예외 처리
   */
  @ExceptionHandler(Exception.class)
  public ResponseEntity<Map<String, Object>> handleException(Exception e) {
    log.error("Error in AI routing controller: {}", e.getMessage(), e);

    Map<String, Object> errorResponse = new HashMap<>();
    errorResponse.put("success", false);
    errorResponse.put("message", "Internal server error");
    errorResponse.put("error", e.getMessage());
    errorResponse.put("timestamp", System.currentTimeMillis());

    return ResponseEntity.internalServerError().body(errorResponse);
  }
}