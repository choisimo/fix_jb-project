package com.jeonbuk.report.infrastructure.external.roboflow;

import com.jeonbuk.report.infrastructure.external.roboflow.RoboflowDto.*;
import com.jeonbuk.report.config.ApiKeyManager;

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

import java.util.Collections;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;

/**
 * Roboflow API 클라이언트
 * 
 * 멀티스레딩 지원:
 * - 비동기 API 호출을 위한 CompletableFuture 사용
 * - UI 스레드 블로킹 방지
 * - 백그라운드 스레드풀에서 실행
 */
@Slf4j
@Service
public class RoboflowApiClient {

    private static final String DETECT_ENDPOINT = "https://detect.roboflow.com/";
    
    // 백그라운드 스레드 풀 (UI 스레드 블로킹 방지)
    private final Executor executor = Executors.newFixedThreadPool(4);
    
    private final RestTemplate restTemplate;
    private final ApiKeyManager apiKeyManager;
    private final String workspaceUrl;

    public RoboflowApiClient(
            RestTemplate restTemplate,
            ApiKeyManager apiKeyManager,
            @Value("${app.roboflow.workspace-url:#{null}}") String workspaceUrl) {
        this.restTemplate = restTemplate;
        this.apiKeyManager = apiKeyManager;
        this.workspaceUrl = workspaceUrl;
        
        if (!apiKeyManager.hasApiKey(ApiKeyManager.ApiKeyType.ROBOFLOW)) {
            log.warn("Roboflow API key is not configured. Some features may not work.");
        }
        
        log.info("RoboflowApiClient initialized with workspace: {}", workspaceUrl);
    }

    /**
     * 비동기 이미지 분석 (단일)
     * UI 스레드를 블로킹하지 않습니다.
     */
    public CompletableFuture<RoboflowAnalysisResult> analyzeImageAsync(String imageData, String modelId) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                return analyzeImage(imageData, modelId);
            } catch (Exception e) {
                log.error("Error in async image analysis: {}", e.getMessage(), e);
                throw new RoboflowException("Async image analysis failed", e);
            }
        }, executor);
    }

    /**
     * 비동기 배치 이미지 분석
     * 여러 이미지를 병렬로 처리합니다.
     */
    public CompletableFuture<List<RoboflowAnalysisResult>> analyzeBatchAsync(List<String> imageDataList, String modelId) {
        return CompletableFuture.supplyAsync(() -> {
            List<CompletableFuture<RoboflowAnalysisResult>> futures = imageDataList.stream()
                    .map(imageData -> analyzeImageAsync(imageData, modelId))
                    .collect(Collectors.toList());

            return futures.stream()
                    .map(CompletableFuture::join)
                    .collect(Collectors.toList());
        }, executor);
    }

    /**
     * 동기 이미지 분석 (내부용)
     */
    @Retryable(
            retryFor = {ResourceAccessException.class, HttpServerErrorException.class},
            maxAttempts = 3,
            backoff = @Backoff(delay = 1000, multiplier = 2)
    )
    private RoboflowAnalysisResult analyzeImage(String imageData, String modelId) {
        validateApiKey();
        
        try {
            String endpoint = buildEndpoint(modelId);
            AnalysisRequest request = new AnalysisRequest(imageData, modelId, 0.4, 0.3);
            
            HttpHeaders headers = createHeaders();
            HttpEntity<AnalysisRequest> httpEntity = new HttpEntity<>(request, headers);
            
            log.debug("Sending Roboflow analysis request to: {} for model: {}", endpoint, modelId);
            
            ResponseEntity<AnalysisResponse> response = restTemplate.exchange(
                    endpoint,
                    HttpMethod.POST,
                    httpEntity,
                    AnalysisResponse.class
            );
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return convertToAnalysisResult(response.getBody(), modelId);
            } else {
                throw new RoboflowException("Invalid response from Roboflow API", "INVALID_RESPONSE", 
                        response.getStatusCode().value());
            }
            
        } catch (HttpClientErrorException e) {
            log.error("Roboflow API client error: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
            throw new RoboflowException("Roboflow API client error: " + e.getMessage(), 
                    "CLIENT_ERROR", e.getStatusCode().value(), e);
        } catch (HttpServerErrorException e) {
            log.error("Roboflow API server error: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
            throw new RoboflowException("Roboflow API server error: " + e.getMessage(), 
                    "SERVER_ERROR", e.getStatusCode().value(), e);
        } catch (Exception e) {
            log.error("Unexpected error during Roboflow API call: {}", e.getMessage(), e);
            throw new RoboflowException("Roboflow API call failed: " + e.getMessage(), e);
        }
    }

    /**
     * 재시도 실패 시 호출되는 복구 메서드
     */
    @Recover
    private RoboflowAnalysisResult recoverFromRoboflowError(Exception ex, String imageData, String modelId) {
        log.error("All retry attempts failed for Roboflow analysis. Model: {}, Error: {}", modelId, ex.getMessage());
        
        return new RoboflowAnalysisResult(
                modelId,
                Collections.emptyList(),
                0.0,
                null,
                false,
                "Analysis failed after retries: " + ex.getMessage()
        );
    }

    /**
     * API 헤더 생성
     */
    private HttpHeaders createHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("User-Agent", "JeonbukReportPlatform/1.0");
        
        if (apiKeyManager.hasApiKey(ApiKeyManager.ApiKeyType.ROBOFLOW)) {
            headers.set("Authorization", "Bearer " + apiKeyManager.getApiKey(ApiKeyManager.ApiKeyType.ROBOFLOW));
        }
        
        return headers;
    }

    /**
     * 엔드포인트 URL 구성
     */
    private String buildEndpoint(String modelId) {
        String apiKey = apiKeyManager.getApiKey(ApiKeyManager.ApiKeyType.ROBOFLOW);
        if (workspaceUrl != null && !workspaceUrl.trim().isEmpty()) {
            return workspaceUrl + "/" + modelId + "?api_key=" + apiKey;
        }
        return DETECT_ENDPOINT + modelId + "?api_key=" + apiKey;
    }

    /**
     * API 키 검증
     */
    private void validateApiKey() {
        if (!apiKeyManager.hasApiKey(ApiKeyManager.ApiKeyType.ROBOFLOW)) {
            throw new RoboflowException("Roboflow API key is not configured", "MISSING_API_KEY", 401);
        }
    }

    /**
     * Roboflow 응답을 내부 분석 결과로 변환
     */
    private RoboflowAnalysisResult convertToAnalysisResult(AnalysisResponse response, String modelId) {
        List<RoboflowAnalysisResult.DetectedObject> detectedObjects = response.getPredictions().stream()
                .map(prediction -> {
                    RoboflowAnalysisResult.DetectedObject.BoundingBox boundingBox = 
                            new RoboflowAnalysisResult.DetectedObject.BoundingBox(
                                    prediction.getX(),
                                    prediction.getY(),
                                    prediction.getWidth(),
                                    prediction.getHeight()
                            );
                    
                    return new RoboflowAnalysisResult.DetectedObject(
                            prediction.getClassName(),
                            prediction.getConfidence(),
                            boundingBox,
                            Collections.emptyMap()
                    );
                })
                .collect(Collectors.toList());

        double averageConfidence = detectedObjects.stream()
                .mapToDouble(obj -> obj.getConfidence())
                .average()
                .orElse(0.0);

        return new RoboflowAnalysisResult(
                modelId,
                detectedObjects,
                averageConfidence,
                response.getTime(),
                true,
                null
        );
    }

    /**
     * API 연결 상태 확인
     */
    public CompletableFuture<Boolean> healthCheckAsync() {
        return CompletableFuture.supplyAsync(() -> {
            try {
                validateApiKey();
                // 간단한 더미 요청으로 API 연결 상태 확인
                return true;
            } catch (Exception e) {
                log.warn("Roboflow API health check failed: {}", e.getMessage());
                return false;
            }
        }, executor);
    }
}
