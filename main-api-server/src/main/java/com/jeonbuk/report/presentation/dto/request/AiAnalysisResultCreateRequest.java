package com.jeonbuk.report.presentation.dto.request;

import com.jeonbuk.report.domain.entity.AiAnalysisResult;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;

/**
 * AI 분석 결과 생성 요청 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiAnalysisResultCreateRequest {
    
    @NotNull(message = "리포트 ID는 필수입니다")
    private String reportId;
    
    private String reportFileId;
    
    @NotNull(message = "AI 서비스 타입은 필수입니다")
    private String aiService;
    
    private String rawResponse;
    private String parsedResult;
    
    @NotNull(message = "분석 상태는 필수입니다")
    private String status;
    
    @DecimalMin(value = "0.0", message = "신뢰도 점수는 0.0 이상이어야 합니다")
    @DecimalMax(value = "1.0", message = "신뢰도 점수는 1.0 이하여야 합니다")
    private Double confidenceScore;
    
    private String errorMessage;
    
    @Min(value = 0, message = "처리 시간은 0 이상이어야 합니다")
    private Long processingTimeMs;
    
    @Min(value = 0, message = "재시도 횟수는 0 이상이어야 합니다")
    private Integer retryCount;
    
    /**
     * 요청 DTO를 엔티티로 변환 (추가 설정 필요)
     */
    public AiAnalysisResult toEntity() {
        return AiAnalysisResult.builder()
                .aiService(AiAnalysisResult.AiServiceType.valueOf(aiService.toUpperCase()))
                .rawResponse(rawResponse)
                .parsedResult(parsedResult)
                .status(AiAnalysisResult.AnalysisStatus.valueOf(status.toUpperCase()))
                .confidenceScore(confidenceScore)
                .errorMessage(errorMessage)
                .processingTimeMs(processingTimeMs)
                .retryCount(retryCount != null ? retryCount : 0)
                .build();
    }
}