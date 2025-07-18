package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 유사도 검색 결과 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SimilaritySearchResult {
    
    /**
     * 문서 벡터
     */
    private DocumentVector documentVector;
    
    /**
     * 유사도 점수 (0.0 ~ 1.0)
     */
    private Double similarityScore;
    
    /**
     * 검색 순위
     */
    private Integer rank;
    
    /**
     * 검색 방법 (SEMANTIC, KEYWORD, HYBRID)
     */
    private String searchMethod;
    
    /**
     * 유사도 백분율
     */
    public String getSimilarityPercentage() {
        return similarityScore != null ? 
            String.format("%.1f%%", similarityScore * 100) : "N/A";
    }
}