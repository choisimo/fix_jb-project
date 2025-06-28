package com.jeonbuk.report.domain.report;

/**
 * 보고서 상태 열거형
 */
public enum ReportStatus {
    DRAFT("초안"),
    SUBMITTED("제출"),
    APPROVED("승인"),
    REJECTED("반려");
    
    private final String description;
    
    ReportStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}
