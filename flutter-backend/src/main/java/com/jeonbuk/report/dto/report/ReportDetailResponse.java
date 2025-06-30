package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.*;
import com.jeonbuk.report.dto.user.UserSummary;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 신고서 상세 응답 DTO
 */
@Schema(description = "신고서 상세 정보")
public record ReportDetailResponse(
    @Schema(description = "신고서 ID") UUID id,

    @Schema(description = "제목") String title,

    @Schema(description = "설명") String description,

    @Schema(description = "작성자 정보") UserSummary author,

    @Schema(description = "상태 정보") String status,

    @Schema(description = "우선순위", example = "HIGH") Report.Priority priority,

    @Schema(description = "위치 정보") LocationInfo location,

    @Schema(description = "담당자 정보") UserSummary manager,

    @Schema(description = "AI 분석 결과") Map<String, Object> aiAnalysisResults,

    @Schema(description = "AI 신뢰도 점수") BigDecimal aiConfidenceScore,

    @Schema(description = "생성일") LocalDateTime createdAt,

    @Schema(description = "수정일") LocalDateTime updatedAt,

    @Schema(description = "첨부 파일 목록") List<ReportFileResponse> files) {
  public static ReportDetailResponse from(Report report) {
    LocationInfo locationInfo = null;
    if (report.getLatitude() != null && report.getLongitude() != null) {
      locationInfo = new LocationInfo(
          report.getLatitude(),
          report.getLongitude(),
          report.getAddress());
    }

    return new ReportDetailResponse(
        report.getId(),
        report.getTitle(),
        report.getDescription(),
        UserSummary.from(report.getUser()),
        report.getStatus() != null ? report.getStatus().getName() : null,
        report.getPriority(),
        locationInfo,
        report.getManager() != null ? UserSummary.from(report.getManager()) : null,
        report.getAiAnalysisResults(),
        report.getAiConfidenceScore(),
        report.getCreatedAt(),
        report.getUpdatedAt(),
        report.getFiles() != null
            ? report.getFiles().stream().map(ReportFileResponse::from).collect(Collectors.toList())
            : null);
  }
}
