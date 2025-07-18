package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 하이브리드 AI 분석 결과 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HybridAnalysisResult {
    
    /**
     * 신고서 ID
     */
    private String reportId;
    
    /**
     * 파일명
     */
    private String filename;
    
    /**
     * 분석 시작 시간
     */
    private LocalDateTime analysisStartTime;
    
    /**
     * 분석 종료 시간
     */
    private LocalDateTime analysisEndTime;
    
    /**
     * OCR 분석 결과
     */
    private List<String> ocrTexts;
    
    /**
     * Roboflow 분석 결과
     */
    private String roboflowAnalysis;
    
    /**
     * AutoML 분류 결과
     */
    private AutoMLClassificationResult autoMLClassification;
    
    /**
     * AutoML 객체 탐지 결과
     */
    private AutoMLObjectDetectionResult autoMLDetection;
    
    /**
     * 기본 AI 분석 결과
     */
    private AIAnalysisResponse basicAnalysis;
    
    /**
     * RAG 향상 분석 결과
     */
    private RagAnalysisResult ragAnalysis;
    
    /**
     * 최종 통합 분석 결과
     */
    private String finalAnalysis;
    
    /**
     * 최종 신뢰도 (0.0 ~ 1.0)
     */
    private Float finalConfidence;
    
    /**
     * 전체 처리 시간 (밀리초)
     */
    private Long processingTimeMs;
    
    /**
     * 분석 상태 (SUCCESS, FAILED, PARTIAL)
     */
    private String status;
    
    /**
     * 오류 메시지 (실패 시)
     */
    private String errorMessage;
    
    /**
     * 사용된 AI 서비스들
     */
    @Builder.Default
    private List<String> usedServices = List.of();
    
    /**
     * 성능 지표
     */
    private PerformanceMetrics performanceMetrics;
    
    /**
     * 분석 성공 여부
     */
    public boolean isSuccessful() {
        return "SUCCESS".equals(status);
    }
    
    /**
     * 부분 성공 여부 (일부 서비스는 실패했지만 기본 분석은 성공)
     */
    public boolean isPartialSuccess() {
        return "PARTIAL".equals(status);
    }
    
    /**
     * 신뢰도 백분율
     */
    public String getConfidencePercentage() {
        return finalConfidence != null ? 
            String.format("%.1f%%", finalConfidence * 100) : "N/A";
    }
    
    /**
     * 분석 소요 시간 (초)
     */
    public double getProcessingTimeSeconds() {
        return processingTimeMs != null ? processingTimeMs / 1000.0 : 0.0;
    }
    
    /**
     * 성능 등급 계산 (A, B, C, D, F)
     */
    public String getPerformanceGrade() {
        if (finalConfidence == null) return "F";
        
        float confidence = finalConfidence;
        if (confidence >= 0.9f) return "A";
        if (confidence >= 0.8f) return "B";
        if (confidence >= 0.7f) return "C";
        if (confidence >= 0.6f) return "D";
        return "F";
    }
    
    /**
     * AutoML 분석 사용 여부
     */
    public boolean hasAutoMLAnalysis() {
        return autoMLClassification != null || autoMLDetection != null;
    }
    
    /**
     * RAG 분석 사용 여부
     */
    public boolean hasRAGAnalysis() {
        return ragAnalysis != null && ragAnalysis.isSuccessful();
    }
    
    /**
     * 성능 지표 내부 클래스
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PerformanceMetrics {
        private Long ocrTimeMs;
        private Long roboflowTimeMs;
        private Long automlClassificationTimeMs;
        private Long automlDetectionTimeMs;
        private Long ragTimeMs;
        private Long totalTimeMs;
        
        /**
         * 각 단계별 소요 시간 비율
         */
        public double getOCRTimeRatio() {
            return totalTimeMs > 0 ? (double) ocrTimeMs / totalTimeMs : 0.0;
        }
        
        public double getAutoMLTimeRatio() {
            long automlTotal = (automlClassificationTimeMs != null ? automlClassificationTimeMs : 0) +
                             (automlDetectionTimeMs != null ? automlDetectionTimeMs : 0);
            return totalTimeMs > 0 ? (double) automlTotal / totalTimeMs : 0.0;
        }
        
        public double getRAGTimeRatio() {
            return totalTimeMs > 0 && ragTimeMs != null ? (double) ragTimeMs / totalTimeMs : 0.0;
        }
    }
}