package com.jeonbuk.report.dto.common;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.report.ReportStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 보고서 검색 조건 DTO
 */
@Schema(description = "보고서 검색 조건")
public record ReportSearchCondition(
    @Schema(description = "검색 키워드 (제목, 내용에서 검색)", example = "안전") @Size(max = 100, message = "검색 키워드는 100자 이하여야 합니다") String keyword,

    @Schema(description = "상태 목록", example = "[\"SUBMITTED\", \"APPROVED\"]") List<ReportStatus> statuses,

    @Schema(description = "우선순위 목록", example = "[\"HIGH\", \"URGENT\"]") List<Report.Priority> priorities,

    @Schema(description = "카테고리 ID 목록", example = "[1, 2, 3]") List<Long> categoryIds,

    @Schema(description = "작성자 ID", example = "123") Long authorId,

    @Schema(description = "승인자 ID", example = "456") Long approverId,

    @Schema(description = "검색 시작일") LocalDateTime startDate,

    @Schema(description = "검색 종료일") LocalDateTime endDate) {
}
