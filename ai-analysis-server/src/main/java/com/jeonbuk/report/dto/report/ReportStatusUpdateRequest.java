package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.report.ReportStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

/**
 * 신고서 상태 변경 요청 DTO
 */
@Schema(description = "신고서 상태 변경 요청")
public record ReportStatusUpdateRequest(
    @Schema(description = "변경할 상태", example = "APPROVED", allowableValues = {
        "DRAFT", "SUBMITTED", "UNDER_REVIEW", "APPROVED", "REJECTED",
        "COMPLETED" }) @NotNull(message = "상태는 필수입니다") ReportStatus status,

    @Schema(description = "상태 변경 사유", example = "검토 완료") String reason){
}
