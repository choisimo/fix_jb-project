package com.jeonbuk.report.infrastructure.external.openrouter;

/**
 * OpenRouter API 관련 예외 클래스
 */
public class OpenRouterException extends RuntimeException {

  private final int statusCode;
  private final String errorCode;
  private final String errorType;

  public OpenRouterException(String message) {
    super(message);
    this.statusCode = 500;
    this.errorCode = "UNKNOWN";
    this.errorType = "internal_error";
  }

  public OpenRouterException(String message, int statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = "HTTP_" + statusCode;
    this.errorType = "http_error";
  }

  public OpenRouterException(String message, int statusCode, String errorCode, String errorType) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.errorType = errorType;
  }

  public OpenRouterException(String message, Throwable cause) {
    super(message, cause);
    this.statusCode = 500;
    this.errorCode = "UNKNOWN";
    this.errorType = "internal_error";
  }

  public int getStatusCode() {
    return statusCode;
  }

  public String getErrorCode() {
    return errorCode;
  }

  public String getErrorType() {
    return errorType;
  }

  public boolean isRetryable() {
    // 일시적인 오류로 재시도 가능한 상태 코드들
    return statusCode == 429 || // Rate limit
        statusCode == 502 || // Bad gateway
        statusCode == 503 || // Service unavailable
        statusCode == 504; // Gateway timeout
  }

  public boolean isAuthenticationError() {
    return statusCode == 401;
  }

  public boolean isRateLimitError() {
    return statusCode == 429;
  }
}
