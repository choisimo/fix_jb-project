package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * RAG 분석 결과 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RagAnalysisResult {
    
    /**
     * 원본 질의
     */
    private String originalQuery;
    
    /**
     * 원본 AI 분석 결과
     */
    private AIAnalysisResponse originalAnalysis;
    
    /**
     * RAG로 향상된 분석 결과
     */
    private String enhancedAnalysis;
    
    /**
     * 컨텍스트 소스 문서들
     */
    private List<DocumentChunk> contextSources;
    
    /**
     * 분석 신뢰도 (0.0 ~ 1.0)
     */
    private Float confidence;
    
    /**
     * 처리 시간 (밀리초)
     */
    private Long processingTime;
    
    /**
     * 분석 수행 시간
     */
    private LocalDateTime timestamp;
    
    /**
     * 추가 메타데이터
     */
    private Map<String, Object> metadata;
    
    /**
     * 오류 메시지 (있는 경우)
     */
    private String error;
    
    /**
     * 분석 성공 여부
     */
    public boolean isSuccessful() {
        return error == null || error.isEmpty();
    }
    
    /**
     * 신뢰도 백분율 반환
     */
    public String getConfidencePercentage() {
        return confidence != null ? String.format("%.1f%%", confidence * 100) : "N/A";
    }
    
    /**
     * 컨텍스트 소스 개수
     */
    public int getContextSourceCount() {
        return contextSources != null ? contextSources.size() : 0;
    }
    
    /**
     * 원본 분석 대비 향상도 계산
     */
    public float getImprovementRatio() {
        if (originalAnalysis == null || enhancedAnalysis == null) {
            return 0.0f;
        }
        
        float originalLength = originalAnalysis.getAnalysisResult().length();
        float enhancedLength = enhancedAnalysis.length();
        
        return enhancedLength / originalLength;
    }
}