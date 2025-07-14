package com.jeonbuk.report.presentation.dto.response;

import com.jeonbuk.report.domain.entity.AiAnalysisResult;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * AI 분석 결과 응답 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiAnalysisResultResponse {
    
    private Long id;
    private String reportId;
    private String reportFileId;
    private String aiService;
    private String parsedResult;
    private String status;
    private Double confidenceScore;
    private String errorMessage;
    private Long processingTimeMs;
    private Integer retryCount;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
    
    /**
     * 엔티티에서 응답 DTO로 변환
     */
    public static AiAnalysisResultResponse from(AiAnalysisResult entity) {
        if (entity == null) {
            return null;
        }
        
        return AiAnalysisResultResponse.builder()
                .id(entity.getId())
                .reportId(entity.getReport() != null ? entity.getReport().getId().toString() : null)
                .reportFileId(entity.getReportFile() != null ? entity.getReportFile().getId().toString() : null)
                .aiService(entity.getAiService() != null ? entity.getAiService().name() : null)
                .parsedResult(entity.getParsedResult())
                .status(entity.getStatus() != null ? entity.getStatus().name() : null)
                .confidenceScore(entity.getConfidenceScore())
                .errorMessage(entity.getErrorMessage())
                .processingTimeMs(entity.getProcessingTimeMs())
                .retryCount(entity.getRetryCount())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }
}