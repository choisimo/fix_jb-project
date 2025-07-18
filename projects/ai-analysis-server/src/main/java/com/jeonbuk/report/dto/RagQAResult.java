package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * RAG 질의응답 결과 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RagQAResult {
    
    /**
     * 질문
     */
    private String question;
    
    /**
     * 답변
     */
    private String answer;
    
    /**
     * 컨텍스트 소스 문서들
     */
    private List<DocumentChunk> contextSources;
    
    /**
     * 답변 신뢰도 (0.0 ~ 1.0)
     */
    private Float confidence;
    
    /**
     * 응답 생성 시간
     */
    private LocalDateTime timestamp;
    
    /**
     * 처리 시간 (밀리초)
     */
    private Long processingTime;
    
    /**
     * 답변 성공 여부
     */
    public boolean isSuccessful() {
        return answer != null && !answer.trim().isEmpty() && confidence > 0.3f;
    }
    
    /**
     * 신뢰도 백분율
     */
    public String getConfidencePercentage() {
        return confidence != null ? String.format("%.1f%%", confidence * 100) : "N/A";
    }
    
    /**
     * 컨텍스트 소스 개수
     */
    public int getSourceCount() {
        return contextSources != null ? contextSources.size() : 0;
    }
}