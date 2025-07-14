package com.jeonbuk.report.dto;

import lombok.Builder;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/**
 * AI 분석 요청 DTO
 */
@Data
@Builder
public class AIAnalysisRequest {
    
    /**
     * 분석할 이미지 파일
     */
    @NotNull(message = "이미지 파일은 필수입니다")
    private MultipartFile image;
    
    /**
     * 신뢰도 임계값 (0-100)
     */
    @Min(value = 0, message = "신뢰도는 0 이상이어야 합니다")
    @Max(value = 100, message = "신뢰도는 100 이하여야 합니다")
    @Builder.Default
    private Integer confidence = 50;
    
    /**
     * 겹침 임계값 (0-100)
     */
    @Min(value = 0, message = "겹침 임계값은 0 이상이어야 합니다")
    @Max(value = 100, message = "겹침 임계값은 100 이하여야 합니다")
    @Builder.Default
    private Integer overlap = 30;
    
    /**
     * 비동기 처리용 작업 ID
     */
    private String jobId;
    
    /**
     * 추가 메타데이터
     */
    private String metadata;
}
