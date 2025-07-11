package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.dto.user.UserSummary;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 신고서 요약 응답 DTO (목록용)
 */
@Schema(description = "신고서 요약 정보")
public record ReportSummaryResponse(
    @Schema(description = "신고서 ID") UUID id,

    @Schema(description = "제목") String title,

    @Schema(description = "작성자 정보") UserSummary author,

    @Schema(description = "상태 정보") String status,

    @Schema(description = "우선순위", example = "HIGH") Report.Priority priority,

    @Schema(description = "주소") String address,

    @Schema(description = "생성일") LocalDateTime createdAt,

    @Schema(description = "수정일") LocalDateTime updatedAt) {
  public static ReportSummaryResponse from(Report report) {
    return new ReportSummaryResponse(
        report.getId(),
        report.getTitle(),
        UserSummary.from(report.getUser()),
        report.getStatus() != null ? report.getStatus().getName() : null,
        report.getPriority(),
        report.getAddress(),
        report.getCreatedAt(),
        report.getUpdatedAt());
  }
}
