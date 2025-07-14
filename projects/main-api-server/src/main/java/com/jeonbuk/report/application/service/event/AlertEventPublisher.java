package com.jeonbuk.report.application.service.event;

import com.jeonbuk.report.application.service.event.AlertEventListener.*;
import com.jeonbuk.report.domain.entity.Alert.AlertSeverity;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 이벤트 발행 서비스
 * 시스템의 다양한 부분에서 이벤트를 발행하여 자동 알림 생성을 트리거하는 서비스
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AlertEventPublisher {
    
    private final ApplicationEventPublisher eventPublisher;
    
    /**
     * 신고서 상태 변경 이벤트 발행
     */
    public void publishReportStatusChange(UUID reportId, String previousStatus, String newStatus) {
        ReportStatusChangeEvent event = new ReportStatusChangeEvent(reportId, previousStatus, newStatus);
        eventPublisher.publishEvent(event);
        log.debug("Published report status change event: {} -> {}", previousStatus, newStatus);
    }
    
    /**
     * 새 댓글 추가 이벤트 발행
     */
    public void publishNewComment(UUID reportId, UUID commentAuthorId, String commentContent) {
        NewCommentEvent event = new NewCommentEvent(reportId, commentAuthorId, commentContent);
        eventPublisher.publishEvent(event);
        log.debug("Published new comment event for report: {}", reportId);
    }
    
    /**
     * 관리자 배정 이벤트 발행
     */
    public void publishManagerAssignment(UUID reportId, UUID managerId) {
        ManagerAssignmentEvent event = new ManagerAssignmentEvent(reportId, managerId);
        eventPublisher.publishEvent(event);
        log.debug("Published manager assignment event: {} to report {}", managerId, reportId);
    }
    
    /**
     * 보안 이벤트 발행
     */
    public void publishSecurityEvent(UUID userId, String eventType, String details, AlertSeverity severity) {
        SecurityEvent event = new SecurityEvent(userId, eventType, details, severity);
        eventPublisher.publishEvent(event);
        log.warn("Published security event for user {}: {}", userId, eventType);
    }
    
    /**
     * 시스템 점검 이벤트 발행
     */
    public void publishMaintenanceEvent(String title, String details, LocalDateTime startTime, LocalDateTime endTime) {
        MaintenanceEvent event = new MaintenanceEvent(title, details, startTime, endTime);
        eventPublisher.publishEvent(event);
        log.info("Published maintenance event: {}", title);
    }
    
    /**
     * 의심스러운 로그인 시도 보안 이벤트 발행
     */
    public void publishSuspiciousLoginAttempt(UUID userId, String ipAddress) {
        String details = String.format("IP: %s에서 의심스러운 로그인 시도가 감지되었습니다.", ipAddress);
        publishSecurityEvent(userId, "SUSPICIOUS_LOGIN", details, AlertSeverity.HIGH);
    }
    
    /**
     * 다중 실패 로그인 보안 이벤트 발행
     */
    public void publishMultipleFailedLogins(UUID userId, int attemptCount) {
        String details = String.format("계정에 %d회 연속 로그인 실패가 발생했습니다.", attemptCount);
        AlertSeverity severity = attemptCount >= 5 ? AlertSeverity.CRITICAL : AlertSeverity.HIGH;
        publishSecurityEvent(userId, "MULTIPLE_FAILED_LOGINS", details, severity);
    }
    
    /**
     * 계정 잠금 보안 이벤트 발행
     */
    public void publishAccountLocked(UUID userId) {
        String details = "보안상의 이유로 계정이 일시적으로 잠금되었습니다.";
        publishSecurityEvent(userId, "ACCOUNT_LOCKED", details, AlertSeverity.CRITICAL);
    }
}