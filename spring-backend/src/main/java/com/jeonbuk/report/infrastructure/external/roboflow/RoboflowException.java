package com.jeonbuk.report.infrastructure.external.roboflow;

/**
 * Roboflow API 관련 예외 클래스
 */
public class RoboflowException extends RuntimeException {

  private final String errorCode;
  private final int httpStatus;

  public RoboflowException(String message) {
    super(message);
    this.errorCode = "ROBOFLOW_ERROR";
    this.httpStatus = 500;
  }

  public RoboflowException(String message, Throwable cause) {
    super(message, cause);
    this.errorCode = "ROBOFLOW_ERROR";
    this.httpStatus = 500;
  }

  public RoboflowException(String message, String errorCode, int httpStatus) {
    super(message);
    this.errorCode = errorCode;
    this.httpStatus = httpStatus;
  }

  public RoboflowException(String message, String errorCode, int httpStatus, Throwable cause) {
    super(message, cause);
    this.errorCode = errorCode;
    this.httpStatus = httpStatus;
  }

  public String getErrorCode() {
    return errorCode;
  }

  public int getHttpStatus() {
    return httpStatus;
  }
}
