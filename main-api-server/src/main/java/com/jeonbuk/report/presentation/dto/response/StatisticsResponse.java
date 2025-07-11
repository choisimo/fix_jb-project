package com.jeonbuk.report.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StatisticsResponse {
    
    // 전체 통계
    private Long totalReports;
    private Long completedReports;
    private Long pendingReports;
    private Long inProgressReports;
    
    // 카테고리별 통계
    private Map<String, Long> reportsByCategory;
    
    // 상태별 통계
    private Map<String, Long> reportsByStatus;
    
    // 우선순위별 통계
    private Map<String, Long> reportsByPriority;
    
    // 시간별 통계
    private Map<LocalDate, Long> reportsOverTime;
    
    // 평균 처리 시간 (일 단위)
    private Double averageProcessingDays;
    
    // 사용자별 통계
    private Long totalUsers;
    private Long activeUsers;
    
    // AI 분석 통계
    private Long reportsWithAiAnalysis;
    private Double averageAiConfidence;
    
    // 성과 지표
    private Double completionRate;
    private Long reportsThisMonth;
    private Long reportsLastMonth;
}