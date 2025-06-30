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
          response.put("success", result.isSuccess());
          response.put("message", result.getMessage());
          response.put("id", result.getId());
          response.put("timestamp", result.getTimestamp());

          if (result.isSuccess()) {
            response.put("analysisResult", result.getAnalysisResult());
            response.put("validationResult", result.getValidationResult());
            response.put("roboflowResult", result.getRoboflowResult());
            return ResponseEntity.ok(response);
          } else {
            response.put("error", result.getMessage());
            return ResponseEntity.badRequest().body(response);
          }
        })
        .exceptionally(ex -> {
          log.error("Error in AI routing analysis: {}", ex.getMessage(), ex);
          Map<String, Object> errorResponse = new HashMap<>();
          errorResponse.put("success", false);
          errorResponse.put("message", "AI routing analysis failed");
          errorResponse.put("error", ex.getMessage());
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
          response.put("success", result.isSuccess());
          response.put("message", result.getMessage());
          response.put("id", result.getId());
          response.put("timestamp", result.getTimestamp());

          if (result.isSuccess()) {
            response.put("analysisResult", result.getAnalysisResult());
            return ResponseEntity.ok(response);
          } else {
            response.put("error", result.getMessage());
            return ResponseEntity.badRequest().body(response);
          }
        })
        .exceptionally(ex -> {
          log.error("Error in simple AI analysis: {}", ex.getMessage(), ex);
          Map<String, Object> errorResponse = new HashMap<>();
          errorResponse.put("success", false);
          errorResponse.put("message", "Simple AI analysis failed");
          errorResponse.put("error", ex.getMessage());
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

          long successCount = results.stream().mapToLong(r -> r.isSuccess() ? 1 : 0).sum();
          long failureCount = results.size() - successCount;

          response.put("totalItems", results.size());
          response.put("successCount", successCount);
          response.put("failureCount", failureCount);
          response.put("results", results);
          response.put("timestamp", System.currentTimeMillis());

          if (failureCount == 0) {
            response.put("success", true);
            response.put("message", "All batch items processed successfully");
            return ResponseEntity.ok(response);
          } else if (successCount == 0) {
            response.put("success", false);
            response.put("message", "All batch items failed");
            return ResponseEntity.badRequest().body(response);
          } else {
            response.put("success", true);
            response.put("message", "Batch processed with some failures");
            return ResponseEntity.ok(response);
          }
        })
        .exceptionally(ex -> {
          log.error("Error in batch AI routing: {}", ex.getMessage(), ex);
          Map<String, Object> errorResponse = new HashMap<>();
          errorResponse.put("success", false);
          errorResponse.put("message", "Batch AI routing failed");
          errorResponse.put("error", ex.getMessage());
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

      // TODO: 실제 서비스 상태 확인 로직 추가
      // - OpenRouter API 연결 상태
      // - Roboflow API 연결 상태
      // - Kafka 연결 상태

      return ResponseEntity.ok(healthStatus);
    });
  }

  /**
   * AI 라우팅 통계 정보
   */
  @GetMapping("/stats")
  public CompletableFuture<ResponseEntity<Map<String, Object>>> getStats() {
    return CompletableFuture.supplyAsync(() -> {
      Map<String, Object> stats = new HashMap<>();
      stats.put("service", "ai-routing");
      stats.put("timestamp", System.currentTimeMillis());

      // TODO: 실제 통계 정보 수집 로직 추가
      // - 처리된 요청 수
      // - 성공/실패 비율
      // - 평균 처리 시간
      // - 모델별 사용 통계

      stats.put("message", "Statistics collection not yet implemented");

      return ResponseEntity.ok(stats);
    });
  }

  /**
   * 모델 라우팅 규칙 조회
   */
  @GetMapping("/routing-rules")
  public ResponseEntity<Map<String, Object>> getRoutingRules() {
    Map<String, Object> response = new HashMap<>();
    response.put("rules", Map.of(
        "pothole", "pothole-detection-v1",
        "traffic_sign", "traffic-sign-detection",
        "road_damage", "road-damage-assessment",
        "infrastructure", "infrastructure-monitoring",
        "general", "general-object-detection"));
    response.put("timestamp", System.currentTimeMillis());

    return ResponseEntity.ok(response);
  }

  /**
   * 에러 핸들링
   */
  @ExceptionHandler(Exception.class)
  public ResponseEntity<Map<String, Object>> handleException(Exception e) {
    log.error("Unhandled exception in AI routing controller: {}", e.getMessage(), e);

    Map<String, Object> errorResponse = new HashMap<>();
    errorResponse.put("success", false);
    errorResponse.put("message", "Internal server error");
    errorResponse.put("error", e.getMessage());
    errorResponse.put("timestamp", System.currentTimeMillis());

    return ResponseEntity.internalServerError().body(errorResponse);
  }
}
