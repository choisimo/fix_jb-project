package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.Status;

public record StatusResponse(
    Long id,
    String name,
    String description,
    String color
) {
    public static StatusResponse from(Status status) {
        return new StatusResponse(
            status.getId(),
            status.getName(),
            status.getDescription(),
            status.getColor()
        );
    }
}
