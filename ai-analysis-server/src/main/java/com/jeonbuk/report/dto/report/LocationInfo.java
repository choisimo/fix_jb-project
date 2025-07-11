package com.jeonbuk.report.dto.report;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;

/**
 * 위치 정보 DTO
 */
@Schema(description = "위치 정보")
public record LocationInfo(
    @Schema(description = "위도", example = "35.824776") @NotNull(message = "위도는 필수입니다") @DecimalMin(value = "-90.0", message = "위도는 -90 이상이어야 합니다") @DecimalMax(value = "90.0", message = "위도는 90 이하여야 합니다") BigDecimal latitude,

    @Schema(description = "경도", example = "127.147953") @NotNull(message = "경도는 필수입니다") @DecimalMin(value = "-180.0", message = "경도는 -180 이상이어야 합니다") @DecimalMax(value = "180.0", message = "경도는 180 이하여야 합니다") BigDecimal longitude,

    @Schema(description = "주소", example = "전북 전주시 덕진구 백제대로 567") @Size(max = 200, message = "주소는 200자 이하여야 합니다") String address) {
}
