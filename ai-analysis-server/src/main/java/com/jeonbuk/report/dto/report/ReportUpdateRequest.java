package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.Report;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.List;

/**
 * 신고서 업데이트 요청 DTO
 */
@Schema(description = "신고서 업데이트 요청")
public record ReportUpdateRequest(
        @Schema(description = "제목")
        @NotBlank(message = "제목은 필수입니다")
        @Size(max = 200, message = "제목은 200자를 초과할 수 없습니다")
        String title,

        @Schema(description = "설명")
        @NotBlank(message = "설명은 필수입니다")
        @Size(max = 2000, message = "설명은 2000자를 초과할 수 없습니다")
        String description,

        @Schema(description = "카테고리 ID")
        Long categoryId,

        @Schema(description = "우선순위")
        Report.Priority priority,

        @Schema(description = "위치 정보")
        LocationInfo location,

        @Schema(description = "태그 목록")
        List<String> tags
) {
}