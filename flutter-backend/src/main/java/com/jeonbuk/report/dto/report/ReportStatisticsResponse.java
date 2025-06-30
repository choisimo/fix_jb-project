package com.jeonbuk.report.dto.report;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Map;

/**
 * 신고서 통계 응답 DTO
 */
@Schema(description = "신고서 통계 정보")
public record ReportStatisticsResponse(
    @Schema(description = "전체 신고서 수") Long totalReports,

    @Schema(description = "상태별 신고서 수") Map<String, Long> reportsByStatus,

    @Schema(description = "우선순위별 신고서 수") Map<String, Long> reportsByPriority,

    @Schema(description = "카테고리별 신고서 수") Map<String, Long> reportsByCategory,

    @Schema(description = "월별 신고서 수") Map<String, Long> reportsByMonth) {
}
