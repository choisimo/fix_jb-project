package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.*;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

/**
 * 신고서 생성 요청 DTO
 */
@Schema(description = "신고서 생성 요청")
public record ReportCreateRequest(
    @Schema(description = "제목", example = "안전사고 신고") @NotBlank(message = "제목은 필수입니다") @Size(max = 100, message = "제목은 100자 이하여야 합니다") String title,

    @Schema(description = "내용", example = "공사 현장에서 안전사고가 발생했습니다.") @NotBlank(message = "내용은 필수입니다") @Size(max = 5000, message = "내용은 5000자 이하여야 합니다") String description,

    @Schema(description = "우선순위", example = "MEDIUM", allowableValues = {
        "LOW", "MEDIUM", "HIGH", "URGENT" }) Report.Priority priority,

    @Valid @Schema(description = "위치 정보") LocationInfo location,

    @Schema(description = "카테고리 ID") UUID categoryId,

    @Schema(description = "AI 분석 결과") Map<String, Object> aiAnalysisResults,

    @Schema(description = "AI 신뢰도 점수") BigDecimal aiConfidenceScore,

    @Schema(description = "복잡한 주제 여부") Boolean isComplexSubject,

    @Schema(description = "장치 정보") Map<String, Object> deviceInfo){
  public Report toEntity(User user, Category category) {
    return Report.builder()
        .title(title)
        .description(description)
        .user(user)
        .category(category)
        .priority(priority != null ? priority : Report.Priority.MEDIUM)
        .latitude(location != null ? location.latitude() : null)
        .longitude(location != null ? location.longitude() : null)
        .address(location != null ? location.address() : null)
        .aiAnalysisResults(aiAnalysisResults)
        .aiConfidenceScore(aiConfidenceScore)
        .isComplexSubject(isComplexSubject != null ? isComplexSubject : false)
        .deviceInfo(deviceInfo)
        .build();
  }
}
