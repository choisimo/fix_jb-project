package com.jeonbuk.report.domain.report;

/**
 * 신고서 우선순위 열거형
 * 기존 Report.Priority enum을 별도 파일로 분리
 */
public enum ReportPriority {
  LOW("낮음"),
  MEDIUM("보통"),
  HIGH("높음"),
  URGENT("긴급");

  private final String description;

  ReportPriority(String description) {
    this.description = description;
  }

  public String getDescription() {
    return description;
  }
}
