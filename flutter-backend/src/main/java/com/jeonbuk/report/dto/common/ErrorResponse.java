package com.jeonbuk.report.dto.common;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

/**
 * 에러 응답 DTO
 */
@Schema(description = "에러 응답")
public record ErrorResponse(
        @Schema(description = "에러 코드", example = "VALIDATION_FAILED") String errorCode,

        @Schema(description = "에러 메시지", example = "입력값 검증에 실패했습니다.") String message,

        @Schema(description = "상세 에러 정보") Object details,

        @Schema(description = "발생 시간") LocalDateTime timestamp) {

    public static ErrorResponse of(String errorCode, String message) {
        return new ErrorResponse(errorCode, message, null, LocalDateTime.now());
    }

    public static ErrorResponse of(String errorCode, String message, Object details) {
        return new ErrorResponse(errorCode, message, details, LocalDateTime.now());
    }
}
