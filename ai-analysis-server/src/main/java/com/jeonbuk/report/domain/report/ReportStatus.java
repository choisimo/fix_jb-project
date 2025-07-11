package com.jeonbuk.report.domain.report;

/**
 * 신고서 상태 열거형
 * 기본적인 신고서 처리 상태를 정의
 */
public enum ReportStatus {
  DRAFT("임시저장"),
  SUBMITTED("제출됨"),
  IN_PROGRESS("처리중"),
  REVIEW("검토중"),
  APPROVED("승인됨"),
  REJECTED("반려됨"),
  COMPLETED("완료"),
  CANCELLED("취소됨");

  private final String description;

  ReportStatus(String description) {
    this.description = description;
  }

  public String getDescription() {
    return description;
  }
}
