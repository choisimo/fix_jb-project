package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.dto.category.ReportCategoryResponse;
import com.jeonbuk.report.dto.user.UserSummaryResponse;
import com.jeonbuk.report.domain.entity.Report;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record ReportDetailResponse(
    UUID id,
    String title,
    String description,
    UserSummaryResponse author,
    ReportCategoryResponse category,
    StatusResponse status,
    String priority,
    LocationInfo location,
    UserSummaryResponse manager,
    List<ReportFileResponse> files,
    LocalDateTime createdAt,
    LocalDateTime updatedAt,
    LocalDateTime completedAt,
    String observation,
    String equipment,
    String actionTaken,
    Double estimatedCost,
    String externalId
) {
    public static ReportDetailResponse from(Report report) {
        LocationInfo locationInfo = null;
        if (report.getLatitude() != null && report.getLongitude() != null) {
            locationInfo = new LocationInfo(
                report.getLatitude().doubleValue(),
                report.getLongitude().doubleValue(),
                report.getAddress()
            );
        }

        return new ReportDetailResponse(
            report.getId(),
            report.getTitle(),
            report.getDescription(),
            UserSummaryResponse.from(report.getUser()),
            report.getCategory() != null ? ReportCategoryResponse.from(report.getCategory()) : null,
            report.getStatus() != null ? StatusResponse.from(report.getStatus()) : null,
            report.getPriority() != null ? report.getPriority().name() : null,
            locationInfo,
            report.getManager() != null ? UserSummaryResponse.from(report.getManager()) : null,
            report.getFiles() != null ? report.getFiles().stream().map(ReportFileResponse::from).toList() : List.of(),
            report.getCreatedAt(),
            report.getUpdatedAt(),
            report.getCompletedAt(),
            report.getObservation(),
            report.getEquipment(),
            report.getActionTaken(),
            report.getEstimatedCost() != null ? report.getEstimatedCost().doubleValue() : null,
            report.getExternalId()
        );
    }
}
