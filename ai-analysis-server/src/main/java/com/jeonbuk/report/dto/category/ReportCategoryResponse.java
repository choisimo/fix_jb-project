package com.jeonbuk.report.dto.category;

import com.jeonbuk.report.domain.entity.ReportCategory;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

@Schema(description = "신고 카테고리 정보")
public record ReportCategoryResponse(
        @Schema(description = "카테고리 ID") UUID id,
        @Schema(description = "카테고리명") String name,
        @Schema(description = "설명") String description,
        @Schema(description = "색상") String color,
        @Schema(description = "활성 여부") Boolean isActive
) {
    public static ReportCategoryResponse from(ReportCategory category) {
        return new ReportCategoryResponse(
                category.getId(),
                category.getName(),
                category.getDescription(),
                category.getColor(),
                category.getIsActive()
        );
    }
}