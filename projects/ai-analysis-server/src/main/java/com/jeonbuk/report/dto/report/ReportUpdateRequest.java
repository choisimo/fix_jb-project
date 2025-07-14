package com.jeonbuk.report.dto.report;

import jakarta.validation.constraints.Size;


public record ReportUpdateRequest(
    @Size(max = 255, message = "제목은 255자 이하여야 합니다.")
    String title,
    String description,
    Long categoryId,
    String priority,
    Long managerId
,
    LocationInfo location
) {}
