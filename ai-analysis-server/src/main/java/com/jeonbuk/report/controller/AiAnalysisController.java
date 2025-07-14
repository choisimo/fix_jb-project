package com.jeonbuk.report.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.jeonbuk.report.service.AiAnalysisService;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * AI 분석 컨트롤러 - OCR, AI Agent, Roboflow 통합 분석
 */
@Slf4j
@RestController
@RequestMapping("/ai")
public class AiAnalysisController {

    @Autowired
    private AiAnalysisService aiAnalysisService;

    /**
     * 통합 이미지 분석 API (비동기) - OCR + AI Agent + Roboflow
     */
    @PostMapping(value = "/analyze/comprehensive", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public CompletableFuture<ResponseEntity<Map<String, Object>>> analyzeImageComprehensive(
            @RequestParam("image") MultipartFile imageFile,
            @RequestParam(value = "confidence", defaultValue = "50") int confidence,
            @RequestParam(value = "overlap", defaultValue = "30") int overlap) {
        
        log.info("🔍 통합 이미지 분석 요청 받음 - 파일명: {}, 크기: {} bytes", 
                   imageFile.getOriginalFilename(), imageFile.getSize());
        
        return aiAnalysisService.analyzeImageComprehensive(imageFile, confidence, overlap)
                .thenApply(result -> {
                    log.info("✅ 통합 이미지 분석 완료 - 결과: {}", result.get("success"));
                    return ResponseEntity.ok(result);
                })
                .exceptionally(throwable -> {
                    log.error("❌ 통합 이미지 분석 실패", throwable);
                    
                    Map<String, Object> errorResponse = new HashMap<>();
                    errorResponse.put("success", false);
                    errorResponse.put("error", throwable.getMessage());
                    errorResponse.put("timestamp", System.currentTimeMillis());
                    
                    return ResponseEntity.status(500).body(errorResponse);
                });
    }

    /**
     * 기존 이미지 분석 API (호환성 유지)
     */
    @PostMapping(value = "/analyze/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> analyzeImage(
            @RequestParam("image") MultipartFile imageFile,
            @RequestParam(value = "confidence", defaultValue = "50") int confidence,
            @RequestParam(value = "overlap", defaultValue = "30") int overlap) {
        
        try {
            log.info("🔍 이미지 분석 요청 받음 - 파일명: {}, 크기: {} bytes", 
                       imageFile.getOriginalFilename(), imageFile.getSize());
            
            // 이미지 분석 수행 (동기 처리)
            Map<String, Object> result = aiAnalysisService.analyzeImage(imageFile, confidence, overlap);
            
            log.info("✅ 이미지 분석 완료 - 결과: {}", result.get("success"));
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            log.error("❌ 이미지 분석 실패: {}", e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", e.getMessage());
            errorResponse.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Roboflow 전용 분석 API
     */
    @PostMapping(value = "/analyze/roboflow", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> analyzeWithRoboflow(
            @RequestParam("image") MultipartFile imageFile,
            @RequestParam(value = "confidence", defaultValue = "50") int confidence,
            @RequestParam(value = "overlap", defaultValue = "30") int overlap) {
        
        try {
            log.info("🎯 Roboflow 전용 분석 요청 - 파일명: {}", imageFile.getOriginalFilename());
            
            Map<String, Object> result = aiAnalysisService.analyzeImage(imageFile, confidence, overlap);
            
            // Roboflow 결과만 반환
            Map<String, Object> roboflowOnly = new HashMap<>();
            roboflowOnly.put("success", result.get("success"));
            roboflowOnly.put("timestamp", result.get("timestamp"));
            roboflowOnly.put("processingTime", result.get("processingTime"));
            roboflowOnly.put("detections", result.get("detections"));
            roboflowOnly.put("detectionCount", result.get("detectionCount"));
            roboflowOnly.put("confidence", confidence);
            roboflowOnly.put("overlap", overlap);
            
            return ResponseEntity.ok(roboflowOnly);
            
        } catch (Exception e) {
            log.error("❌ Roboflow 분석 실패", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", e.getMessage());
            errorResponse.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * 모든 AI 서비스 상태 확인
     */
    @GetMapping("/health")
    public CompletableFuture<ResponseEntity<Map<String, Object>>> health() {
        return aiAnalysisService.checkServicesHealth()
                .thenApply(healthStatus -> {
                    healthStatus.put("service", "AI Analysis Service - Comprehensive");
                    healthStatus.put("version", "2.0");
                    healthStatus.put("features", new String[]{"Roboflow", "Google Cloud Vision OCR", "AI Agent"});
                    
                    boolean overallHealth = (Boolean) healthStatus.get("overall");
                    
                    if (overallHealth) {
                        return ResponseEntity.ok(healthStatus);
                    } else {
                        return ResponseEntity.status(503).body(healthStatus); // Service Unavailable
                    }
                })
                .exceptionally(throwable -> {
                    log.error("헬스체크 실패", throwable);
                    
                    Map<String, Object> errorStatus = new HashMap<>();
                    errorStatus.put("status", "DOWN");
                    errorStatus.put("error", throwable.getMessage());
                    errorStatus.put("timestamp", System.currentTimeMillis());
                    
                    return ResponseEntity.status(500).body(errorStatus);
                });
    }

    /**
     * 개별 서비스 상태 확인
     */
    @GetMapping("/health/{service}")
    public CompletableFuture<ResponseEntity<Map<String, Object>>> healthCheck(@PathVariable String service) {
        return aiAnalysisService.checkServicesHealth()
                .thenApply(healthStatus -> {
                    Map<String, Object> serviceStatus = new HashMap<>();
                    serviceStatus.put("service", service);
                    serviceStatus.put("timestamp", System.currentTimeMillis());
                    
                    Boolean status = (Boolean) healthStatus.get(service);
                    if (status != null) {
                        serviceStatus.put("status", status ? "UP" : "DOWN");
                        return ResponseEntity.ok(serviceStatus);
                    } else {
                        serviceStatus.put("status", "UNKNOWN");
                        serviceStatus.put("error", "Service not found");
                        return ResponseEntity.status(404).body(serviceStatus);
                    }
                });
    }

    /**
     * 분석 기능 목록
     */
    @GetMapping("/capabilities")
    public ResponseEntity<Map<String, Object>> getCapabilities() {
        Map<String, Object> capabilities = new HashMap<>();
        capabilities.put("services", new String[]{"roboflow", "googleCloudVision", "aiAgent"});
        capabilities.put("features", Map.of(
            "objectDetection", "Roboflow를 통한 객체 감지",
            "textExtraction", "Google Cloud Vision OCR을 통한 텍스트 추출",
            "sceneAnalysis", "AI Agent를 통한 장면 분석",
            "integratedAnalysis", "모든 서비스 결과 통합 분석"
        ));
        capabilities.put("endpoints", Map.of(
            "comprehensive", "/ai/analyze/comprehensive",
            "legacy", "/ai/analyze/image",
            "roboflowOnly", "/ai/analyze/roboflow"
        ));
        capabilities.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(capabilities);
    }
}