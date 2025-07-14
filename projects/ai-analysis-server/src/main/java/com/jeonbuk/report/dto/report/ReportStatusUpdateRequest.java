package com.jeonbuk.report.dto.report;

import jakarta.validation.constraints.NotNull;

public record ReportStatusUpdateRequest(
    @NotNull(message = "상태 ID는 필수입니다.")
    Long statusId,
    Long managerId,
    String comment
) {}
