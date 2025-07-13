package com.jeonbuk.report.dto.report;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 상태 응답 DTO
 */
@Schema(description = "상태 정보")
public record StatusResponse(
        @Schema(description = "상태 코드", example = "PENDING") String code,

        @Schema(description = "상태 이름", example = "처리 대기") String name,

        @Schema(description = "상태 색상 코드", example = "#FFA500") String colorCode,

        @Schema(description = "상태 설명", example = "신고가 접수되어 검토를 기다리고 있습니다.") String description
) {
}