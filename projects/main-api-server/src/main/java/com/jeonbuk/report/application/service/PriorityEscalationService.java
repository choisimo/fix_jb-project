package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Report;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class PriorityEscalationService {
    
    private final KafkaTicketService kafkaTicketService;
    
    // 우선순위별 에스컬레이션 시간 설정 (분 단위)
    @Value("${escalation.urgent.minutes:30}")
    private int urgentEscalationMinutes;
    
    @Value("${escalation.high.minutes:120}")
    private int highEscalationMinutes;
    
    @Value("${escalation.medium.minutes:480}")
    private int mediumEscalationMinutes;
    
    @Value("${escalation.low.minutes:1440}")
    private int lowEscalationMinutes;
    
    // 최대 에스컬레이션 횟수
    @Value("${escalation.max.count:3}")
    private int maxEscalationCount;
    
    /**
     * 필요한 경우 신고서를 에스컬레이션
     */
    public void escalateIfNeeded(Report report) {
        log.info("Checking escalation for report: {}", report.getId());
        
        if (!shouldEscalate(report)) {
            log.debug("Report {} does not require escalation", report.getId());
            return;
        }
        
        try {
            // 에스컬레이션 수행
            performEscalation(report);
            
            log.info("Successfully escalated report: {}", report.getId());
            
        } catch (Exception e) {
            log.error("Failed to escalate report {}: {}", report.getId(), e.getMessage(), e);
        }
    }
    
    /**
     * 에스컬레이션이 필요한지 판단
     */
    public boolean shouldEscalate(Report report) {
        log.debug("Evaluating escalation criteria for report: {}", report.getId());
        
        // 이미 완료된 신고서는 에스컬레이션 하지 않음
        if (report.isCompleted()) {
            log.debug("Report {} is already completed, no escalation needed", report.getId());
            return false;
        }
        
        // 삭제된 신고서는 에스컬레이션 하지 않음
        if (report.isDeleted()) {
            log.debug("Report {} is deleted, no escalation needed", report.getId());
            return false;
        }
        
        // 최대 에스컬레이션 횟수 확인
        int currentEscalationCount = getCurrentEscalationCount(report);
        if (currentEscalationCount >= maxEscalationCount) {
            log.debug("Report {} has reached maximum escalation count ({}), no further escalation", 
                report.getId(), maxEscalationCount);
            return false;
        }
        
        // 시간 기반 에스컬레이션 조건 확인
        if (isTimeBasedEscalationNeeded(report)) {
            log.info("Report {} requires time-based escalation", report.getId());
            return true;
        }
        
        // 우선순위 기반 에스컬레이션 조건 확인
        if (isPriorityBasedEscalationNeeded(report)) {
            log.info("Report {} requires priority-based escalation", report.getId());
            return true;
        }
        
        // 복잡한 주제 기반 에스컬레이션
        if (isComplexSubjectEscalationNeeded(report)) {
            log.info("Report {} requires complex subject escalation", report.getId());
            return true;
        }
        
        return false;
    }
    
    /**
     * 실제 에스컬레이션 수행
     */
    private void performEscalation(Report report) {
        log.info("Performing escalation for report: {}", report.getId());
        
        // 1. 우선순위 알림 전송
        kafkaTicketService.sendPriorityAlert(report);
        
        // 2. 관리자 워크스페이스로 전송
        String managerWorkspace = determineManagerWorkspace(report);
        kafkaTicketService.sendToWorkspace(report, managerWorkspace);
        
        // 3. 에스컬레이션 이력 기록 (실제로는 별도 테이블에 저장)
        recordEscalationHistory(report);
        
        log.info("Escalation completed for report: {}", report.getId());
    }
    
    /**
     * 시간 기반 에스컬레이션 필요 여부 확인
     */
    private boolean isTimeBasedEscalationNeeded(Report report) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime reportTime = report.getCreatedAt();
        Duration timeSinceReport = Duration.between(reportTime, now);
        
        int escalationThresholdMinutes = switch (report.getPriority()) {
            case URGENT -> urgentEscalationMinutes;
            case HIGH -> highEscalationMinutes;
            case MEDIUM -> mediumEscalationMinutes;
            case LOW -> lowEscalationMinutes;
        };
        
        long minutesSinceReport = timeSinceReport.toMinutes();
        boolean needsEscalation = minutesSinceReport >= escalationThresholdMinutes;
        
        log.debug("Report {} time check: {} minutes elapsed, threshold: {} minutes, needs escalation: {}", 
            report.getId(), minutesSinceReport, escalationThresholdMinutes, needsEscalation);
        
        return needsEscalation;
    }
    
    /**
     * 우선순위 기반 에스컬레이션 필요 여부 확인
     */
    private boolean isPriorityBasedEscalationNeeded(Report report) {
        // URGENT 우선순위는 즉시 에스컬레이션
        if (report.getPriority() == Report.Priority.URGENT) {
            Duration timeSinceReport = Duration.between(report.getCreatedAt(), LocalDateTime.now());
            return timeSinceReport.toMinutes() >= 15; // 15분 후 에스컬레이션
        }
        
        // HIGH 우선순위는 빠른 에스컬레이션
        if (report.getPriority() == Report.Priority.HIGH) {
            Duration timeSinceReport = Duration.between(report.getCreatedAt(), LocalDateTime.now());
            return timeSinceReport.toMinutes() >= 60; // 1시간 후 에스컬레이션
        }
        
        return false;
    }
    
    /**
     * 복잡한 주제 기반 에스컬레이션 필요 여부 확인
     */
    private boolean isComplexSubjectEscalationNeeded(Report report) {
        if (report.getIsComplexSubject() != null && report.getIsComplexSubject()) {
            Duration timeSinceReport = Duration.between(report.getCreatedAt(), LocalDateTime.now());
            // 복잡한 주제는 2시간 후 에스컬레이션
            return timeSinceReport.toMinutes() >= 120;
        }
        return false;
    }
    
    /**
     * 현재 에스컬레이션 횟수 조회
     * 실제로는 데이터베이스에서 조회해야 함
     */
    private int getCurrentEscalationCount(Report report) {
        // TODO: 실제로는 escalation_history 테이블에서 조회
        // 현재는 더미 값 반환
        return 0;
    }
    
    /**
     * 관리자 워크스페이스 결정
     */
    private String determineManagerWorkspace(Report report) {
        // 우선순위에 따른 워크스페이스 결정
        return switch (report.getPriority()) {
            case URGENT -> "emergency-response";
            case HIGH -> "high-priority-management";
            case MEDIUM -> "standard-management";
            case LOW -> "routine-management";
        };
    }
    
    /**
     * 에스컬레이션 이력 기록
     */
    private void recordEscalationHistory(Report report) {
        // TODO: 실제로는 escalation_history 테이블에 기록
        Map<String, Object> escalationRecord = Map.of(
            "reportId", report.getId(),
            "escalationTime", LocalDateTime.now(),
            "escalationReason", determineEscalationReason(report),
            "escalationLevel", determineEscalationLevel(report),
            "escalatedBy", "SYSTEM"
        );
        
        log.info("Escalation history recorded for report {}: {}", report.getId(), escalationRecord);
    }
    
    /**
     * 에스컬레이션 사유 결정
     */
    private String determineEscalationReason(Report report) {
        if (report.getPriority() == Report.Priority.URGENT) {
            return "URGENT_PRIORITY";
        } else if (report.getIsComplexSubject() != null && report.getIsComplexSubject()) {
            return "COMPLEX_SUBJECT";
        } else {
            return "TIME_THRESHOLD_EXCEEDED";
        }
    }
    
    /**
     * 에스컬레이션 레벨 결정
     */
    private int determineEscalationLevel(Report report) {
        int currentCount = getCurrentEscalationCount(report);
        return currentCount + 1;
    }
}