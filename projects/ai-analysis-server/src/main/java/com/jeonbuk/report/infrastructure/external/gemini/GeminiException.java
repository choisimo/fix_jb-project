package com.jeonbuk.report.infrastructure.external.gemini;

/**
 * Google Gemini API 예외 클래스
 */
public class GeminiException extends RuntimeException {
  
  private final int statusCode;
  private final String errorCode;
  private final String errorType;

  public GeminiException(String message) {
    super(message);
    this.statusCode = 0;
    this.errorCode = null;
    this.errorType = null;
  }

  public GeminiException(String message, Throwable cause) {
    super(message, cause);
    this.statusCode = 0;
    this.errorCode = null;
    this.errorType = null;
  }

  public GeminiException(String message, int statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = null;
    this.errorType = null;
  }

  public GeminiException(String message, int statusCode, String errorCode, String errorType) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.errorType = errorType;
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

  public boolean isAuthenticationError() {
    return statusCode == 401 || statusCode == 403;
  }

  public boolean isRateLimitError() {
    return statusCode == 429;
  }

  public boolean isServerError() {
    return statusCode >= 500;
  }
}