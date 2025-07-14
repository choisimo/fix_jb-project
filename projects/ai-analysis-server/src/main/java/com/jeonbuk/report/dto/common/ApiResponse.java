package com.jeonbuk.report.dto.common;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

/**
 * API 공통 응답 DTO
 */
@Schema(description = "API 응답")
@com.fasterxml.jackson.annotation.JsonInclude(com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(
    @Schema(description = "성공 여부", example = "true") boolean success,

    @Schema(description = "응답 메시지", example = "요청이 성공적으로 처리되었습니다.") String message,

    @Schema(description = "응답 데이터") T data,

    @Schema(description = "에러 코드", example = "USER_NOT_FOUND") String errorCode,

    @Schema(description = "응답 시간") LocalDateTime timestamp) {

  public static <T> ApiResponse<T> success(T data) {
    return new ApiResponse<>(
        true,
        "요청이 성공적으로 처리되었습니다.",
        data,
        null,
        LocalDateTime.now());
  }

  public static <T> ApiResponse<T> success(String message, T data) {
    return new ApiResponse<>(
        true,
        message,
        data,
        null,
        LocalDateTime.now());
  }

  public static <T> ApiResponse<T> error(String message, String errorCode) {
    return new ApiResponse<>(
        false,
        message,
        null,
        errorCode,
        LocalDateTime.now());
  }

  public static <T> ApiResponse<T> error(String message) {
    return error(message, "INTERNAL_ERROR");
  }
}
