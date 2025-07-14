package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.dto.category.CategoryDto.CategorySummary;
import com.jeonbuk.report.dto.user.UserSummary;
import com.jeonbuk.report.domain.entity.Report;

import java.time.LocalDateTime;
import java.util.UUID;

public record ReportSummaryResponse(
    UUID id,
    String title,
    UserSummary author,
    CategorySummary category,
    String status,
    String priority,
    LocationInfo location,
    LocalDateTime createdAt,
    int commentCount
) {
    public static ReportSummaryResponse from(Report report) {
        LocationInfo locationInfo = null;
        if (report.getLatitude() != null && report.getLongitude() != null) {
            locationInfo = new LocationInfo(
                report.getLatitude().doubleValue(),
                report.getLongitude().doubleValue(),
                report.getAddress()
            );
        }

        return new ReportSummaryResponse(
            report.getId(),
            report.getTitle(),
            UserSummary.from(report.getUser()),
            report.getCategory() != null ? CategorySummary.from(report.getCategory()) : null,
            report.getStatus() != null ? report.getStatus().getName() : null,
            report.getPriority() != null ? report.getPriority().name() : null,
            locationInfo,
            report.getCreatedAt(),
            report.getComments() != null ? report.getComments().size() : 0
        );
    }
}
