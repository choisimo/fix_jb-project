package com.jeonbuk.report.dto.report;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

/**
 * 신고서 상태 업데이트 요청 DTO
 */
@Schema(description = "신고서 상태 업데이트 요청")
public record ReportStatusUpdateRequest(
        @Schema(description = "새로운 상태", example = "IN_PROGRESS")
        @NotNull(message = "상태는 필수입니다")
        String status,

        @Schema(description = "관리자 메모", example = "현장 확인 완료, 수리 작업 시작")
        String managerNotes
) {
}