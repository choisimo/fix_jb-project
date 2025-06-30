package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.Report;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

/**
 * 신고서 수정 요청 DTO
 */
@Schema(description = "신고서 수정 요청")
public record ReportUpdateRequest(
    @Schema(description = "제목", example = "수정된 안전사고 신고") @Size(max = 100, message = "제목은 100자 이하여야 합니다") String title,

    @Schema(description = "내용", example = "수정된 공사 현장 안전사고 내용입니다.") @Size(max = 5000, message = "내용은 5000자 이하여야 합니다") String description,

    @Schema(description = "우선순위", example = "HIGH", allowableValues = {
        "LOW", "MEDIUM", "HIGH", "URGENT" }) Report.Priority priority,

    @Valid @Schema(description = "위치 정보") LocationInfo location,

    @Schema(description = "카테고리 ID") UUID categoryId,

    @Schema(description = "AI 분석 결과") Map<String, Object> aiAnalysisResults,

    @Schema(description = "AI 신뢰도 점수") BigDecimal aiConfidenceScore,

    @Schema(description = "복잡한 주제 여부") Boolean isComplexSubject,

    @Schema(description = "장치 정보") Map<String, Object> deviceInfo){
}
