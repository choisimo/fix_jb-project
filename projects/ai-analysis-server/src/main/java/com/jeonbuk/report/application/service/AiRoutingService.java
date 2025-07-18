package com.jeonbuk.report.application.service;

import com.jeonbuk.report.infrastructure.external.roboflow.RoboflowApiClient;
import com.jeonbuk.report.infrastructure.external.roboflow.RoboflowDto;
import com.jeonbuk.report.application.service.IntegratedAiAgentService.AnalysisResult;
import com.jeonbuk.report.application.service.IntegratedAiAgentService.InputData;
import com.jeonbuk.report.application.service.ValidationAiAgentService.ValidationResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;
import java.time.LocalDateTime;

/**
 * AI 라우팅 서비스 - 통합 AI 분석 워크플로우 오케스트레이션
 * 
 * 기능:
 * - 전체 AI 분석 워크플로우 관리
 * - 트랜잭션 관리
 * - Kafka 로깅
 * - 에러 핸들링 및 롤백
 * - 멀티스레딩으로 UI 스레드 블로킹 방지
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiRoutingService {

    private final IntegratedAiAgentService integratedAiAgent;
    private final ValidationAiAgentService validationAiAgent;
    private final RoboflowApiClient roboflowClient;
    
    // Kafka 토픽 설정 (환경 변수로 구성 가능) - 로깅용으로만 사용
    @Value("${app.kafka.topics.analysis-results:ai_analysis_results}")
    private String analysisTopic;
    
    @Value("${app.kafka.topics.analysis-errors:ai_analysis_errors}")
    private String errorTopic;
    
    @Value("${app.kafka.topics.validation-results:ai_validation_results}")
    private String validationTopic;
    
    // Statistics tracking fields
    private final AtomicLong totalRequests = new AtomicLong(0);
    private final AtomicLong successfulRequests = new AtomicLong(0);
    private final AtomicLong failedRequests = new AtomicLong(0);
    private final AtomicReference<Double> totalProcessingTime = new AtomicReference<>(0.0);
    private final Map<String, AtomicLong> modelUsageStats = new HashMap<>();
    private final AtomicReference<LocalDateTime> lastResetTime = new AtomicReference<>(LocalDateTime.now());

    /**
     * 비동기 단일 입력 처리
     * 전체 AI 분석 파이프라인을 실행합니다.
     */
    public CompletableFuture<AiRoutingResult> processInputAsync(InputData inputData) {
        return CompletableFuture.supplyAsync(() -> {
            long startTime = System.currentTimeMillis();
            recordRequestStart();
            
            try {
                log.info("Starting AI routing for input: {}", inputData.getId());
                AiRoutingResult result = processInputWithTransaction(inputData);
                
                // 성공 통계 기록
                long processingTime = System.currentTimeMillis() - startTime;
                String modelUsed = determineModelUsed(result);
                recordRequestSuccess(processingTime, modelUsed);
                
                return result;
            } catch (Exception e) {
                log.error("Error in async AI routing: {}", e.getMessage(), e);
                
                // 실패 통계 기록
                recordRequestFailure();
                
                // 에러 로깅
                logError(inputData.getId(), e);
                
                return new AiRoutingResult(
                        inputData.getId(),
                        false,
                        "AI routing failed: " + e.getMessage(),
                        null,
                        null,
                        null,
                        null,
                        System.currentTimeMillis()
                );
            }
        });
    }

    /**
     * 비동기 배치 처리
     * 여러 입력 데이터를 병렬로 처리합니다.
     */
    public CompletableFuture<List<AiRoutingResult>> processBatchAsync(List<InputData> inputDataList) {
        return CompletableFuture.supplyAsync(() -> {
            List<CompletableFuture<AiRoutingResult>> futures = inputDataList.stream()
                    .map(this::processInputAsync)
                    .toList();

            return futures.stream()
                    .map(CompletableFuture::join)
                    .toList();
        });
    }

    /**
     * 트랜잭션 내에서 입력 처리
     * 검증 실패 시 롤백이 수행됩니다.
     */
    @Transactional
    public AiRoutingResult processInputWithTransaction(InputData inputData) {
        try {
            // 1. 통합 AI 에이전트를 이용한 분석
            log.debug("Step 1: Running integrated AI analysis for {}", inputData.getId());
            AnalysisResult analysisResult = integratedAiAgent.analyzeInputAsync(inputData).join();
            
            if (!analysisResult.isSuccess()) {
                throw new RuntimeException("AI analysis failed: " + analysisResult.getErrorMessage());
            }

            // 2. 검증 AI 에이전트를 이용한 검증
            log.debug("Step 2: Running validation for {}", inputData.getId());
            ValidationResult validationResult = validationAiAgent.validateCompleteAsync(
                    analysisResult.getAnalyzedData(), 
                    analysisResult.getSelectedModel()
            ).join();

            // 3. 검증 실패 시 예외 발생 (트랜잭션 롤백)
            if (!validationResult.isValid()) {
                logValidationFailure(inputData.getId(), validationResult);
                throw new ValidationException("Validation failed: " + validationResult.getValidationMessage());
            }

            // 4. Roboflow 모델 실행
            log.debug("Step 3: Running Roboflow analysis for {}", inputData.getId());
            RoboflowDto.RoboflowAnalysisResult roboflowResult = null;
            
            if (inputData.getImageUrls() != null && !inputData.getImageUrls().isEmpty()) {
                // 첫 번째 이미지로 분석 실행 (확장 가능)
                String imageData = inputData.getImageUrls().get(0);
                roboflowResult = roboflowClient.analyzeImageAsync(imageData, analysisResult.getSelectedModel()).join();
            }

            // 5. 성공 로깅
            logSuccess(inputData.getId(), analysisResult, validationResult, roboflowResult);

            // 6. 결과 반환
            return new AiRoutingResult(
                    inputData.getId(),
                    true,
                    "AI routing completed successfully",
                    analysisResult,
                    validationResult,
                    roboflowResult,
                    null,
                    System.currentTimeMillis()
            );

        } catch (ValidationException e) {
            // 검증 실패 - 트랜잭션 롤백됨
            log.warn("Validation failed for {}: {}", inputData.getId(), e.getMessage());
            throw e; // 트랜잭션 롤백을 위해 예외 재발생
            
        } catch (Exception e) {
            // 기타 예외 - 트랜잭션 롤백됨
            log.error("Unexpected error during AI routing for {}: {}", inputData.getId(), e.getMessage(), e);
            throw new RuntimeException("AI routing failed", e);
        }
    }

    /**
     * 간단한 분석 (검증 없이)
     * 빠른 분석이 필요한 경우 사용
     */
    public CompletableFuture<AiRoutingResult> simpleAnalysisAsync(InputData inputData) {
        return CompletableFuture.supplyAsync(() -> {
            long startTime = System.currentTimeMillis();
            recordRequestStart();
            
            try {
                log.info("Starting simple AI analysis for input: {}", inputData.getId());
                
                // 통합 AI 에이전트만 실행
                AnalysisResult analysisResult = integratedAiAgent.analyzeInputAsync(inputData).join();
                
                if (!analysisResult.isSuccess()) {
                    recordRequestFailure();
                    throw new RuntimeException("Simple analysis failed: " + analysisResult.getErrorMessage());
                }

                // 성공 로깅
                logSimpleAnalysis(inputData.getId(), analysisResult);
                
                AiRoutingResult result = new AiRoutingResult(
                        inputData.getId(),
                        true,
                        "Simple AI analysis completed successfully",
                        analysisResult,
                        null,
                        null,
                        null,
                        System.currentTimeMillis()
                );

                // 성공 통계 기록
                long processingTime = System.currentTimeMillis() - startTime;
                recordRequestSuccess(processingTime, "simple-analysis");
                
                return result;

            } catch (Exception e) {
                log.error("Error in simple AI analysis: {}", e.getMessage(), e);
                recordRequestFailure();
                logError(inputData.getId(), e);
                
                return new AiRoutingResult(
                        inputData.getId(),
                        false,
                        "Simple AI analysis failed: " + e.getMessage(),
                        null,
                        null,
                        null,
                        null,
                        System.currentTimeMillis()
                );
            }
        });
    }

    /**
     * 성공 이벤트 로깅
     */
    private void logSuccess(String id, AnalysisResult analysisResult, ValidationResult validationResult, 
                          RoboflowDto.RoboflowAnalysisResult roboflowResult) {
        try {
            Map<String, Object> logData = new HashMap<>();
            logData.put("id", id);
            logData.put("eventType", "AI_ROUTING_SUCCESS");
            logData.put("analysisResult", analysisResult);
            logData.put("validationResult", validationResult);
            logData.put("roboflowResult", roboflowResult);
            logData.put("timestamp", System.currentTimeMillis());
            
            // Kafka 대신 로그로 출력
            log.info("Success event logged for {}: {}", id, logData);
        } catch (Exception e) {
            log.error("Failed to log success event for {}: {}", id, e.getMessage());
        }
    }

    /**
     * 검증 실패 이벤트 로깅
     */
    private void logValidationFailure(String id, ValidationResult validationResult) {
        try {
            Map<String, Object> logData = new HashMap<>();
            logData.put("id", id);
            logData.put("eventType", "AI_VALIDATION_FAILURE");
            logData.put("validationResult", validationResult);
            logData.put("timestamp", System.currentTimeMillis());
            
            // Kafka 대신 로그로 출력
            log.warn("Validation failure event logged for {}: {}", id, logData);
        } catch (Exception e) {
            log.error("Failed to log validation failure for {}: {}", id, e.getMessage());
        }
    }

    /**
     * 에러 이벤트 로깅
     */
    private void logError(String id, Exception error) {
        try {
            Map<String, Object> logData = new HashMap<>();
            logData.put("id", id);
            logData.put("eventType", "AI_ROUTING_ERROR");
            logData.put("error", error.getMessage());
            logData.put("timestamp", System.currentTimeMillis());
            
            // Kafka 대신 로그로 출력
            log.error("Error event logged for {}: {}", id, logData);
        } catch (Exception e) {
            log.error("Failed to log error for {}: {}", id, e.getMessage());
        }
    }

    /**
     * 간단한 분석 성공 로깅
     */
    private void logSimpleAnalysis(String id, AnalysisResult analysisResult) {
        try {
            Map<String, Object> logData = new HashMap<>();
            logData.put("id", id);
            logData.put("eventType", "AI_SIMPLE_ANALYSIS_SUCCESS");
            logData.put("analysisResult", analysisResult);
            logData.put("timestamp", System.currentTimeMillis());
            
            // Kafka 대신 로그로 출력
            log.info("Simple analysis event logged for {}: {}", id, logData);
        } catch (Exception e) {
            log.error("Failed to log simple analysis event for {}: {}", id, e.getMessage());
        }
    }

    /**
     * 검증 예외 클래스
     */
    public static class ValidationException extends RuntimeException {
        public ValidationException(String message) {
            super(message);
        }

        public ValidationException(String message, Throwable cause) {
            super(message, cause);
        }
    }

    /**
     * AI 라우팅 결과 DTO
     */
    public static class AiRoutingResult {
        private String id;
        private boolean success;
        private String message;
        private AnalysisResult analysisResult;
        private ValidationResult validationResult;
        private RoboflowDto.RoboflowAnalysisResult roboflowResult;
        private Exception error;
        private long timestamp;

        public AiRoutingResult() {}

        public AiRoutingResult(String id, boolean success, String message,
                             AnalysisResult analysisResult, ValidationResult validationResult,
                             RoboflowDto.RoboflowAnalysisResult roboflowResult, Exception error, long timestamp) {
            this.id = id;
            this.success = success;
            this.message = message;
            this.analysisResult = analysisResult;
            this.validationResult = validationResult;
            this.roboflowResult = roboflowResult;
            this.error = error;
            this.timestamp = timestamp;
        }

        // getters and setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public AnalysisResult getAnalysisResult() { return analysisResult; }
        public void setAnalysisResult(AnalysisResult analysisResult) { this.analysisResult = analysisResult; }
        public ValidationResult getValidationResult() { return validationResult; }
        public void setValidationResult(ValidationResult validationResult) { this.validationResult = validationResult; }
        public RoboflowDto.RoboflowAnalysisResult getRoboflowResult() { return roboflowResult; }
        public void setRoboflowResult(RoboflowDto.RoboflowAnalysisResult roboflowResult) { this.roboflowResult = roboflowResult; }
        public Exception getError() { return error; }
        public void setError(Exception error) { this.error = error; }
        public long getTimestamp() { return timestamp; }
        public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
    }
    
    // === 통계 관련 메서드 ===
    
    /**
     * 요청 처리 시작 시 통계 업데이트
     */
    private void recordRequestStart() {
        totalRequests.incrementAndGet();
    }
    
    /**
     * 성공적인 요청 완료 시 통계 업데이트
     */
    private void recordRequestSuccess(long processingTimeMs, String modelUsed) {
        successfulRequests.incrementAndGet();
        
        // 평균 처리 시간 업데이트
        synchronized (totalProcessingTime) {
            double currentAvg = totalProcessingTime.get();
            long successCount = successfulRequests.get();
            double newAvg = ((currentAvg * (successCount - 1)) + processingTimeMs) / successCount;
            totalProcessingTime.set(newAvg);
        }
        
        // 모델 사용 통계 업데이트
        if (modelUsed != null) {
            modelUsageStats.computeIfAbsent(modelUsed, k -> new AtomicLong(0)).incrementAndGet();
        }
    }
    
    /**
     * 실패한 요청 시 통계 업데이트
     */
    private void recordRequestFailure() {
        failedRequests.incrementAndGet();
    }
    
    /**
     * 현재 통계 정보 조회
     */
    public Map<String, Object> getStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        long total = totalRequests.get();
        long successful = successfulRequests.get();
        long failed = failedRequests.get();
        
        stats.put("totalProcessed", total);
        stats.put("successfulRequests", successful);
        stats.put("failedRequests", failed);
        stats.put("successRate", total > 0 ? (successful * 100.0 / total) : 0.0);
        stats.put("failureRate", total > 0 ? (failed * 100.0 / total) : 0.0);
        stats.put("averageProcessingTimeMs", totalProcessingTime.get());
        
        // 모델별 사용 통계
        Map<String, Long> modelStats = new HashMap<>();
        modelUsageStats.forEach((model, count) -> modelStats.put(model, count.get()));
        stats.put("modelUsageStats", modelStats);
        
        stats.put("statisticsResetTime", lastResetTime.get().toString());
        stats.put("lastUpdate", LocalDateTime.now().toString());
        
        return stats;
    }
    
    /**
     * 통계 초기화
     */
    public void resetStatistics() {
        totalRequests.set(0);
        successfulRequests.set(0);
        failedRequests.set(0);
        totalProcessingTime.set(0.0);
        modelUsageStats.clear();
        lastResetTime.set(LocalDateTime.now());
        
        log.info("AI Routing Service statistics have been reset");
    }
    
    /**
     * 사용된 모델 결정하기
     */
    private String determineModelUsed(AiRoutingResult result) {
        if (result.getRoboflowResult() != null) {
            return "roboflow-integration";
        } else if (result.getAnalysisResult() != null) {
            return "integrated-ai-agent";
        } else {
            return "unknown";
        }
    }
}
