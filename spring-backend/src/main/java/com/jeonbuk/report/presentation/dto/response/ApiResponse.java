package com.jeonbuk.report.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 공통 API 응답 DTO
 * - 성공/실패 상태
 * - 메시지 및 데이터
 * - 타임스탬프
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {

  private boolean success;
  private String message;
  private T data;
  private LocalDateTime timestamp;
  private String errorCode;

  public ApiResponse(boolean success, String message, T data) {
    this.success = success;
    this.message = message;
    this.data = data;
    this.timestamp = LocalDateTime.now();
  }

  public ApiResponse(boolean success, String message, T data, String errorCode) {
    this.success = success;
    this.message = message;
    this.data = data;
    this.errorCode = errorCode;
    this.timestamp = LocalDateTime.now();
  }

  // 성공 응답 생성 메서드
  public static <T> ApiResponse<T> success(String message, T data) {
    return new ApiResponse<>(true, message, data);
  }

  public static <T> ApiResponse<T> success(T data) {
    return new ApiResponse<>(true, "요청이 성공적으로 처리되었습니다.", data);
  }

  public static ApiResponse<Void> success(String message) {
    return new ApiResponse<>(true, message, null);
  }

  public static ApiResponse<Void> success() {
    return new ApiResponse<>(true, "요청이 성공적으로 처리되었습니다.", null);
  }

  // 실패 응답 생성 메서드
  public static <T> ApiResponse<T> error(String message) {
    return new ApiResponse<>(false, message, null);
  }

  public static <T> ApiResponse<T> error(String message, String errorCode) {
    return new ApiResponse<>(false, message, null, errorCode);
  }

  public static <T> ApiResponse<T> error(String message, T data) {
    return new ApiResponse<>(false, message, data);
  }

  public static <T> ApiResponse<T> error(String message, T data, String errorCode) {
    return new ApiResponse<>(false, message, data, errorCode);
  }
}
