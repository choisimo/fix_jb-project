package com.jeonbuk.report.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.jeonbuk.report.service.AiAnalysisService;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * 표준 API 분석 엔드포인트 컨트롤러
 */
@Slf4j
@RestController
@RequestMapping("/api/analysis")
public class ApiAnalysisController {

    @Autowired
    private AiAnalysisService aiAnalysisService;

    /**
     * 분석 서비스 상태 확인 (표준 API 엔드포인트)
     */
    @GetMapping("/status")
    public CompletableFuture<ResponseEntity<Map<String, Object>>> getAnalysisStatus() {
        log.info("📊 분석 서비스 상태 확인 요청");
        
        return aiAnalysisService.checkServicesHealth()
                .thenApply(healthStatus -> {
                    Map<String, Object> status = new HashMap<>();
                    status.put("service", "AI Analysis Server");
                    status.put("version", "2.0");
                    status.put("status", (Boolean) healthStatus.get("overall") ? "ACTIVE" : "INACTIVE");
                    status.put("uptime", System.currentTimeMillis());
                    status.put("capabilities", new String[]{"OCR", "Object Detection", "AI Analysis"});
                    status.put("health", healthStatus);
                    status.put("timestamp", System.currentTimeMillis());
                    
                    boolean overallHealth = (Boolean) healthStatus.get("overall");
                    log.info("✅ 분석 서비스 상태: {}", overallHealth ? "정상" : "비정상");
                    
                    return ResponseEntity.ok(status);
                })
                .exceptionally(throwable -> {
                    log.error("❌ 분석 서비스 상태 확인 실패", throwable);
                    
                    Map<String, Object> errorStatus = new HashMap<>();
                    errorStatus.put("service", "AI Analysis Server");
                    errorStatus.put("status", "ERROR");
                    errorStatus.put("error", throwable.getMessage());
                    errorStatus.put("timestamp", System.currentTimeMillis());
                    
                    return ResponseEntity.status(503).body(errorStatus);
                });
    }

    /**
     * 분석 서비스 정보
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getAnalysisInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("service", "AI Analysis Server");
        info.put("version", "2.0.0");
        info.put("description", "통합 AI 분석 서비스 - OCR, 객체 감지, AI 에이전트");
        info.put("endpoints", Map.of(
            "status", "/api/analysis/status",
            "info", "/api/analysis/info",
            "analyze", "/ai/analyze/comprehensive",
            "health", "/ai/health"
        ));
        info.put("supportedFormats", new String[]{"jpg", "jpeg", "png", "webp", "bmp"});
        info.put("maxFileSize", "10MB");
        info.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(info);
    }

    /**
     * 분석 통계
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getAnalysisStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalAnalyses", 0); // TODO: 실제 통계 데이터 연동
        stats.put("todayAnalyses", 0);
        stats.put("successRate", 0.95);
        stats.put("averageProcessingTime", "2.5s");
        stats.put("activeServices", 3);
        stats.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(stats);
    }
}