package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * RAG 프롬프트 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RagPrompt {
    
    /**
     * 시스템 프롬프트
     */
    private String systemPrompt;
    
    /**
     * 원본 질의
     */
    private String originalQuery;
    
    /**
     * AI 분석 결과 (있는 경우)
     */
    private AIAnalysisResponse aiAnalysisResult;
    
    /**
     * 향상된 컨텍스트
     */
    private String enrichedContext;
    
    /**
     * 컨텍스트 소스 문서들
     */
    private List<DocumentChunk> contextSources;
    
    /**
     * 추가 매개변수
     */
    private java.util.Map<String, Object> parameters;
    
    /**
     * 전체 프롬프트 길이
     */
    public int getTotalPromptLength() {
        return (systemPrompt != null ? systemPrompt.length() : 0) +
               (enrichedContext != null ? enrichedContext.length() : 0) +
               (originalQuery != null ? originalQuery.length() : 0);
    }
    
    /**
     * 컨텍스트 소스 개수
     */
    public int getContextSourceCount() {
        return contextSources != null ? contextSources.size() : 0;
    }
}