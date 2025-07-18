package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 문서 청크 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DocumentChunk {
    
    /**
     * 원본 문서 ID
     */
    private String documentId;
    
    /**
     * 컨텐츠 타입 (AI_ANALYSIS, REPORT, KNOWLEDGE_BASE 등)
     */
    private String contentType;
    
    /**
     * 청크 텍스트 내용
     */
    private String chunkText;
    
    /**
     * 청크 인덱스 (문서 내 순서)
     */
    private Integer chunkIndex;
    
    /**
     * 메타데이터
     */
    private Map<String, Object> metadata;
    
    /**
     * 생성 시간
     */
    private LocalDateTime createdAt;
    
    /**
     * 유사도 점수 (검색 시 사용)
     */
    private Double similarityScore;
    
    /**
     * 리랭킹 점수
     */
    private Double rerankScore;
    
    /**
     * 청크 길이
     */
    public int getChunkLength() {
        return chunkText != null ? chunkText.length() : 0;
    }
    
    /**
     * 한국어 컨텐츠 타입 반환
     */
    public String getKoreanContentType() {
        return switch (contentType) {
            case "AI_ANALYSIS" -> "AI 분석 결과";
            case "REPORT" -> "신고서";
            case "KNOWLEDGE_BASE" -> "지식 베이스";
            case "MANUAL" -> "매뉴얼";
            case "FAQ" -> "자주 묻는 질문";
            default -> contentType;
        };
    }
    
    /**
     * 유사도 백분율 반환
     */
    public String getSimilarityPercentage() {
        return similarityScore != null ? 
            String.format("%.1f%%", similarityScore * 100) : "N/A";
    }
    
    /**
     * 요약된 텍스트 반환 (검색 결과 표시용)
     */
    public String getSummaryText(int maxLength) {
        if (chunkText == null || chunkText.length() <= maxLength) {
            return chunkText;
        }
        return chunkText.substring(0, maxLength) + "...";
    }
}