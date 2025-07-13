package com.jeonbuk.report.application.service.example;

import com.jeonbuk.report.application.service.AlertCreationService;
import com.jeonbuk.report.application.service.event.AlertEventPublisher;
import com.jeonbuk.report.domain.entity.Alert;
import com.jeonbuk.report.domain.entity.Alert.AlertSeverity;
import com.jeonbuk.report.domain.entity.Alert.AlertType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Alert 생성 서비스 사용 예제
 * AlertCreationService의 다양한 기능을 보여주는 예제 서비스
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AlertExampleService {
    
    private final AlertCreationService alertCreationService;
    private final AlertEventPublisher eventPublisher;
    
    /**
     * 직접 알림 생성 예제
     */
    public Alert createDirectAlert(UUID userId) {
        return alertCreationService.createAlert(
            userId,
            AlertType.SYSTEM_NOTIFICATION,
            "환영 알림",
            "시스템에 오신 것을 환영합니다!",
            AlertSeverity.LOW
        );
    }
    
    /**
     * 이벤트 기반 알림 생성 예제
     */
    public void triggerEventBasedAlert(UUID reportId, UUID managerId) {
        // 이벤트를 발행하면 AlertEventListener가 자동으로 알림을 생성함
        eventPublisher.publishManagerAssignment(reportId, managerId);
    }
    
    /**
     * 시스템 점검 알림 예제
     */
    public List<Alert> scheduleMaintenanceAlert() {
        LocalDateTime maintenanceStart = LocalDateTime.now().plusDays(1);
        LocalDateTime maintenanceEnd = maintenanceStart.plusHours(4);
        
        return alertCreationService.createSystemMaintenanceAlert(
            "정기 시스템 점검",
            "시스템 안정성 향상을 위한 정기 점검이 예정되어 있습니다.",
            maintenanceStart,
            maintenanceEnd
        );
    }
    
    /**
     * 보안 위험 알림 예제
     */
    public Alert createSecurityAlert(UUID userId) {
        return alertCreationService.createSecurityAlert(
            userId,
            "비정상적인 접근 감지",
            "알 수 없는 위치에서의 로그인이 감지되었습니다.",
            AlertSeverity.HIGH
        );
    }
    
    /**
     * 마감일 경고 알림 예제
     */
    public Alert createDeadlineWarning(UUID reportId) {
        return alertCreationService.createDeadlineWarningAlert(reportId, 2);
    }
    
    /**
     * 성능 이슈 알림 예제 (관리자용)
     */
    public List<Alert> createPerformanceAlert() {
        return alertCreationService.createPerformanceIssueAlert(
            "데이터베이스 응답 지연",
            "평균 응답시간: 2.5초 (기준: 1초 이내)",
            AlertSeverity.HIGH
        );
    }
    
    /**
     * 복합 시나리오 예제: 신고서 처리 과정에서 발생하는 다양한 알림들
     */
    public void demonstrateReportProcessingAlerts(UUID reportId, UUID managerId, UUID commentAuthorId) {
        log.info("=== 신고서 처리 과정 알림 시나리오 시작 ===");
        
        // 1. 담당자 배정 알림
        eventPublisher.publishManagerAssignment(reportId, managerId);
        log.info("1. 담당자 배정 알림 이벤트 발행");
        
        // 2. 상태 변경 알림
        eventPublisher.publishReportStatusChange(reportId, "PENDING", "IN_PROGRESS");
        log.info("2. 상태 변경 알림 이벤트 발행");
        
        // 3. 새 댓글 알림
        eventPublisher.publishNewComment(reportId, commentAuthorId, "처리 시작하겠습니다.");
        log.info("3. 새 댓글 알림 이벤트 발행");
        
        // 4. 마감일 경고 (직접 호출)
        alertCreationService.createDeadlineWarningAlert(reportId, 1);
        log.info("4. 마감일 경고 알림 직접 생성");
        
        // 5. 최종 완료 상태 변경
        eventPublisher.publishReportStatusChange(reportId, "IN_PROGRESS", "COMPLETED");
        log.info("5. 완료 상태 변경 알림 이벤트 발행");
        
        log.info("=== 신고서 처리 과정 알림 시나리오 완료 ===");
    }
    
    /**
     * 보안 이벤트 시나리오 예제
     */
    public void demonstrateSecurityAlerts(UUID userId) {
        log.info("=== 보안 이벤트 알림 시나리오 시작 ===");
        
        // 1. 의심스러운 로그인 시도
        eventPublisher.publishSuspiciousLoginAttempt(userId, "192.168.1.100");
        log.info("1. 의심스러운 로그인 시도 알림");
        
        // 2. 다중 실패 로그인
        eventPublisher.publishMultipleFailedLogins(userId, 6);
        log.info("2. 다중 실패 로그인 알림");
        
        // 3. 계정 잠금
        eventPublisher.publishAccountLocked(userId);
        log.info("3. 계정 잠금 알림");
        
        log.info("=== 보안 이벤트 알림 시나리오 완료 ===");
    }
}