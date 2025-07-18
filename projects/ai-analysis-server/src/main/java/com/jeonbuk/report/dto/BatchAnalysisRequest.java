package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 배치 분석 요청 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BatchAnalysisRequest {
    
    /**
     * 이미지 데이터
     */
    private byte[] imageData;
    
    /**
     * 파일명
     */
    private String filename;
    
    /**
     * 신고서 카테고리
     */
    private String category;
    
    /**
     * 우선순위 (HIGH, MEDIUM, LOW)
     */
    @Builder.Default
    private String priority = "MEDIUM";
    
    /**
     * 분석 옵션
     */
    private AnalysisOptions options;
    
    /**
     * 이미지 메타데이터
     */
    private java.util.Map<String, Object> imageMetadata;
    
    /**
     * 분석 옵션 내부 클래스
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AnalysisOptions {
        
        /**
         * AutoML 분석 사용 여부
         */
        @Builder.Default
        private Boolean enableAutoML = true;
        
        /**
         * RAG 분석 사용 여부
         */
        @Builder.Default
        private Boolean enableRAG = true;
        
        /**
         * 병렬 처리 사용 여부
         */
        @Builder.Default
        private Boolean enableParallel = true;
        
        /**
         * 신뢰도 임계값
         */
        @Builder.Default
        private Float confidenceThreshold = 0.7f;
        
        /**
         * 상세 분석 여부 (더 많은 컨텍스트 검색)
         */
        @Builder.Default
        private Boolean detailedAnalysis = false;
        
        /**
         * 분석 제한 시간 (초)
         */
        @Builder.Default
        private Integer timeoutSeconds = 30;
    }
    
    /**
     * 고우선순위 여부
     */
    public boolean isHighPriority() {
        return "HIGH".equals(priority);
    }
    
    /**
     * 저우선순위 여부
     */
    public boolean isLowPriority() {
        return "LOW".equals(priority);
    }
}