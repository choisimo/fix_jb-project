package com.jeonbuk.report.dto.report;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;

public class ReportRequestDto {
    
    @Schema(description = "위치 정보")
    public record LocationInfo(
            @Schema(description = "위도") @DecimalMin("-90.0") @DecimalMax("90.0") BigDecimal latitude,
            @Schema(description = "경도") @DecimalMin("-180.0") @DecimalMax("180.0") BigDecimal longitude,
            @Schema(description = "주소") String address
    ) {}
}