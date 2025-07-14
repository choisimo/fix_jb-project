package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.domain.repository.ReportRepository;
import com.jeonbuk.report.domain.repository.UserRepository;
import com.jeonbuk.report.presentation.dto.response.StatisticsResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class StatisticsService {

    private final ReportRepository reportRepository;
    private final UserRepository userRepository;

    public StatisticsResponse getOverallStatistics() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startOfMonth = now.withDayOfMonth(1).toLocalDate().atStartOfDay();
        LocalDateTime startOfLastMonth = startOfMonth.minusMonths(1);
        LocalDateTime endOfLastMonth = startOfMonth.minusSeconds(1);

        return StatisticsResponse.builder()
                .totalReports(getTotalReports())
                .completedReports(getCompletedReports())
                .pendingReports(getPendingReports())
                .inProgressReports(getInProgressReports())
                .reportsByCategory(getReportsByCategory())
                .reportsByStatus(getReportsByStatus())
                .reportsByPriority(getReportsByPriority())
                .reportsOverTime(getReportsOverTime())
                .averageProcessingDays(getAverageProcessingDays())
                .totalUsers(getTotalUsers())
                .activeUsers(getActiveUsers())
                .reportsWithAiAnalysis(getReportsWithAiAnalysis())
                .averageAiConfidence(getAverageAiConfidence())
                .completionRate(getCompletionRate())
                .reportsThisMonth(getReportsInPeriod(startOfMonth, now))
                .reportsLastMonth(getReportsInPeriod(startOfLastMonth, endOfLastMonth))
                .build();
    }

    public StatisticsResponse getCategoryStatistics(String categoryName) {
        Map<String, Long> categoryStats = new HashMap<>();
        categoryStats.put(categoryName, getReportsByCategoryName(categoryName));
        
        return StatisticsResponse.builder()
                .reportsByCategory(categoryStats)
                .build();
    }

    public StatisticsResponse getTimeRangeStatistics(LocalDate startDate, LocalDate endDate) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(23, 59, 59);
        
        return StatisticsResponse.builder()
                .totalReports(getReportsInPeriod(start, end))
                .reportsOverTime(getReportsOverTimeInRange(startDate, endDate))
                .build();
    }

    private Long getTotalReports() {
        try {
            return reportRepository.countActive();
        } catch (Exception e) {
            log.warn("Error getting total reports count, returning 0: {}", e.getMessage());
            return 0L;
        }
    }

    private Long getCompletedReports() {
        try {
            // Get all status statistics and filter for completed statuses
            List<Object[]> statusStats = reportRepository.getStatusStatistics();
            return statusStats.stream()
                    .filter(stat -> {
                        String statusName = (String) stat[0];
                        return statusName != null && (
                            statusName.toLowerCase().contains("완료") ||
                            statusName.toLowerCase().contains("해결") ||
                            statusName.toLowerCase().contains("완료됨") ||
                            statusName.toLowerCase().contains("completed") ||
                            statusName.toLowerCase().contains("resolved")
                        );
                    })
                    .mapToLong(stat -> ((Number) stat[1]).longValue())
                    .sum();
        } catch (Exception e) {
            log.warn("Error getting completed reports count, returning 0: {}", e.getMessage());
            return 0L;
        }
    }

    private Long getPendingReports() {
        try {
            List<Object[]> statusStats = reportRepository.getStatusStatistics();
            return statusStats.stream()
                    .filter(stat -> {
                        String statusName = (String) stat[0];
                        return statusName != null && (
                            statusName.toLowerCase().contains("접수") ||
                            statusName.toLowerCase().contains("대기") ||
                            statusName.toLowerCase().contains("신규") ||
                            statusName.toLowerCase().contains("pending") ||
                            statusName.toLowerCase().contains("new")
                        );
                    })
                    .mapToLong(stat -> ((Number) stat[1]).longValue())
                    .sum();
        } catch (Exception e) {
            log.warn("Error getting pending reports count, returning 0: {}", e.getMessage());
            return 0L;
        }
    }

    private Long getInProgressReports() {
        try {
            List<Object[]> statusStats = reportRepository.getStatusStatistics();
            return statusStats.stream()
                    .filter(stat -> {
                        String statusName = (String) stat[0];
                        return statusName != null && (
                            statusName.toLowerCase().contains("처리중") ||
                            statusName.toLowerCase().contains("진행중") ||
                            statusName.toLowerCase().contains("배정") ||
                            statusName.toLowerCase().contains("in_progress") ||
                            statusName.toLowerCase().contains("assigned")
                        );
                    })
                    .mapToLong(stat -> ((Number) stat[1]).longValue())
                    .sum();
        } catch (Exception e) {
            log.warn("Error getting in-progress reports count, returning 0: {}", e.getMessage());
            return 0L;
        }
    }

    private Map<String, Long> getReportsByCategory() {
        try {
            List<Object[]> categoryStats = reportRepository.getCategoryStatistics();
            return categoryStats.stream()
                    .collect(Collectors.toMap(
                        stat -> (String) stat[0],
                        stat -> ((Number) stat[1]).longValue(),
                        (existing, replacement) -> existing
                    ));
        } catch (Exception e) {
            log.warn("Error getting reports by category: {}", e.getMessage());
            return new HashMap<>();
        }
    }

    private Map<String, Long> getReportsByStatus() {
        try {
            List<Object[]> statusStats = reportRepository.getStatusStatistics();
            return statusStats.stream()
                    .collect(Collectors.toMap(
                        stat -> (String) stat[0],
                        stat -> ((Number) stat[1]).longValue(),
                        (existing, replacement) -> existing
                    ));
        } catch (Exception e) {
            log.warn("Error getting reports by status: {}", e.getMessage());
            return new HashMap<>();
        }
    }

    private Map<String, Long> getReportsByPriority() {
        Map<String, Long> priorityStats = new HashMap<>();
        try {
            for (Report.Priority priority : Report.Priority.values()) {
                long count = reportRepository.countByPriority(priority);
                priorityStats.put(priority.getDescription(), count);
            }
        } catch (Exception e) {
            log.warn("Error getting reports by priority: {}", e.getMessage());
        }
        return priorityStats;
    }

    private Map<LocalDate, Long> getReportsOverTime() {
        Map<LocalDate, Long> timeStats = new HashMap<>();
        try {
            LocalDate now = LocalDate.now();
            LocalDate startDate = now.minusDays(29); // Last 30 days
            
            // Get daily counts for the last 30 days
            for (int i = 0; i < 30; i++) {
                LocalDate date = startDate.plusDays(i);
                LocalDateTime dayStart = date.atStartOfDay();
                LocalDateTime dayEnd = date.atTime(23, 59, 59);
                
                List<Report> dailyReports = reportRepository.findByCreatedAtBetween(dayStart, dayEnd);
                timeStats.put(date, (long) dailyReports.size());
            }
        } catch (Exception e) {
            log.warn("Error getting reports over time: {}", e.getMessage());
        }
        return timeStats;
    }

    private Map<LocalDate, Long> getReportsOverTimeInRange(LocalDate startDate, LocalDate endDate) {
        Map<LocalDate, Long> timeStats = new HashMap<>();
        try {
            long daysBetween = ChronoUnit.DAYS.between(startDate, endDate);
            
            for (long i = 0; i <= daysBetween; i++) {
                LocalDate date = startDate.plusDays(i);
                LocalDateTime dayStart = date.atStartOfDay();
                LocalDateTime dayEnd = date.atTime(23, 59, 59);
                
                List<Report> dailyReports = reportRepository.findByCreatedAtBetween(dayStart, dayEnd);
                timeStats.put(date, (long) dailyReports.size());
            }
        } catch (Exception e) {
            log.warn("Error getting reports over time in range: {}", e.getMessage());
        }
        return timeStats;
    }

    private Double getAverageProcessingDays() {
        try {
            List<Report> completedReports = reportRepository.findAllActive().stream()
                    .filter(report -> report.getActualCompletion() != null)
                    .toList();
            
            if (completedReports.isEmpty()) {
                return 0.0;
            }
            
            double totalDays = completedReports.stream()
                    .mapToDouble(report -> {
                        LocalDate createdDate = report.getCreatedAt().toLocalDate();
                        LocalDate completedDate = report.getActualCompletion();
                        return ChronoUnit.DAYS.between(createdDate, completedDate);
                    })
                    .sum();
            
            return totalDays / completedReports.size();
        } catch (Exception e) {
            log.warn("Error calculating average processing days: {}", e.getMessage());
            return 0.0;
        }
    }

    private Long getTotalUsers() {
        try {
            return userRepository.count();
        } catch (Exception e) {
            log.warn("Error getting total users count, returning 0: {}", e.getMessage());
            return 0L;
        }
    }

    private Long getActiveUsers() {
        try {
            return userRepository.countByIsActiveTrue();
        } catch (Exception e) {
            log.warn("Error getting active users count, returning 0: {}", e.getMessage());
            return 0L;
        }
    }

    private Long getReportsWithAiAnalysis() {
        try {
            return (long) reportRepository.findWithAiAnalysis().size();
        } catch (Exception e) {
            log.warn("Error getting reports with AI analysis count, returning 0: {}", e.getMessage());
            return 0L;
        }
    }

    private Double getAverageAiConfidence() {
        try {
            List<Report> reportsWithAi = reportRepository.findWithAiAnalysis();
            
            if (reportsWithAi.isEmpty()) {
                return 0.0;
            }
            
            double totalConfidence = reportsWithAi.stream()
                    .filter(report -> report.getAiConfidenceScore() != null)
                    .mapToDouble(report -> report.getAiConfidenceScore().doubleValue())
                    .sum();
            
            long countWithConfidence = reportsWithAi.stream()
                    .filter(report -> report.getAiConfidenceScore() != null)
                    .count();
            
            return countWithConfidence > 0 ? totalConfidence / countWithConfidence : 0.0;
        } catch (Exception e) {
            log.warn("Error calculating average AI confidence: {}", e.getMessage());
            return 0.0;
        }
    }

    private Double getCompletionRate() {
        try {
            Long total = getTotalReports();
            if (total == 0) return 0.0;
            return (getCompletedReports() / (double) total) * 100.0;
        } catch (Exception e) {
            log.warn("Error calculating completion rate: {}", e.getMessage());
            return 0.0;
        }
    }

    private Long getReportsInPeriod(LocalDateTime start, LocalDateTime end) {
        try {
            return (long) reportRepository.findByCreatedAtBetween(start, end).size();
        } catch (Exception e) {
            log.warn("Error getting reports in period: {}", e.getMessage());
            return 0L;
        }
    }

    private Long getReportsByCategoryName(String categoryName) {
        try {
            List<Object[]> categoryStats = reportRepository.getCategoryStatistics();
            return categoryStats.stream()
                    .filter(stat -> categoryName.equals(stat[0]))
                    .mapToLong(stat -> ((Number) stat[1]).longValue())
                    .findFirst()
                    .orElse(0L);
        } catch (Exception e) {
            log.warn("Error getting reports by category name: {}", e.getMessage());
            return 0L;
        }
    }
}