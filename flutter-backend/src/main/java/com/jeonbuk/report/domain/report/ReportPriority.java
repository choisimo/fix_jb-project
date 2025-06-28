package com.jeonbuk.report.domain.report;

/**
 * 보고서 우선순위 열거형
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
