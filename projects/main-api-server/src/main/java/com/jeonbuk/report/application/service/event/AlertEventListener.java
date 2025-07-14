package com.jeonbuk.report.application.service.event;

import com.jeonbuk.report.application.service.AlertCreationService;
import com.jeonbuk.report.domain.entity.Alert.AlertSeverity;
import com.jeonbuk.report.domain.entity.Alert.AlertType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 시스템 이벤트 리스너
 * 다양한 이벤트를 수신하여 자동으로 알림을 생성하는 서비스
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AlertEventListener {
    
    private final AlertCreationService alertCreationService;
    
    /**
     * 신고서 상태 변경 이벤트 처리
     */
    @EventListener
    @Async
    public void handleReportStatusChangeEvent(ReportStatusChangeEvent event) {
        try {
            alertCreationService.createReportStatusChangeAlert(
                event.getReportId(),
                event.getNewStatus(),
                event.getPreviousStatus()
            );
            log.info("Alert created for report status change: {} -> {}", 
                    event.getPreviousStatus(), event.getNewStatus());
        } catch (Exception e) {
            log.error("Failed to create alert for report status change event", e);
        }
    }
    
    /**
     * 새 댓글 추가 이벤트 처리
     */
    @EventListener
    @Async
    public void handleNewCommentEvent(NewCommentEvent event) {
        try {
            alertCreationService.createNewCommentAlert(
                event.getReportId(),
                event.getCommentAuthorId(),
                event.getCommentContent()
            );
            log.info("Alert created for new comment on report: {}", event.getReportId());
        } catch (Exception e) {
            log.error("Failed to create alert for new comment event", e);
        }
    }
    
    /**
     * 관리자 배정 이벤트 처리
     */
    @EventListener
    @Async
    public void handleManagerAssignmentEvent(ManagerAssignmentEvent event) {
        try {
            alertCreationService.createManagerAssignmentAlert(
                event.getReportId(),
                event.getManagerId()
            );
            log.info("Alert created for manager assignment: {} to report {}", 
                    event.getManagerId(), event.getReportId());
        } catch (Exception e) {
            log.error("Failed to create alert for manager assignment event", e);
        }
    }
    
    /**
     * 보안 이벤트 처리
     */
    @EventListener
    @Async
    public void handleSecurityEvent(SecurityEvent event) {
        try {
            alertCreationService.createSecurityAlert(
                event.getUserId(),
                event.getEventType(),
                event.getDetails(),
                event.getSeverity()
            );
            log.warn("Security alert created for user {}: {}", event.getUserId(), event.getEventType());
        } catch (Exception e) {
            log.error("Failed to create alert for security event", e);
        }
    }
    
    /**
     * 시스템 점검 이벤트 처리
     */
    @EventListener
    @Async
    public void handleMaintenanceEvent(MaintenanceEvent event) {
        try {
            alertCreationService.createSystemMaintenanceAlert(
                event.getTitle(),
                event.getDetails(),
                event.getStartTime(),
                event.getEndTime()
            );
            log.info("Maintenance alerts created for all users: {}", event.getTitle());
        } catch (Exception e) {
            log.error("Failed to create alerts for maintenance event", e);
        }
    }
    
    // === 이벤트 클래스들 ===
    
    /**
     * 신고서 상태 변경 이벤트
     */
    public static class ReportStatusChangeEvent {
        private final UUID reportId;
        private final String previousStatus;
        private final String newStatus;
        private final LocalDateTime changedAt;
        
        public ReportStatusChangeEvent(UUID reportId, String previousStatus, String newStatus) {
            this.reportId = reportId;
            this.previousStatus = previousStatus;
            this.newStatus = newStatus;
            this.changedAt = LocalDateTime.now();
        }
        
        // Getters
        public UUID getReportId() { return reportId; }
        public String getPreviousStatus() { return previousStatus; }
        public String getNewStatus() { return newStatus; }
        public LocalDateTime getChangedAt() { return changedAt; }
    }
    
    /**
     * 새 댓글 추가 이벤트
     */
    public static class NewCommentEvent {
        private final UUID reportId;
        private final UUID commentAuthorId;
        private final String commentContent;
        private final LocalDateTime commentedAt;
        
        public NewCommentEvent(UUID reportId, UUID commentAuthorId, String commentContent) {
            this.reportId = reportId;
            this.commentAuthorId = commentAuthorId;
            this.commentContent = commentContent;
            this.commentedAt = LocalDateTime.now();
        }
        
        // Getters
        public UUID getReportId() { return reportId; }
        public UUID getCommentAuthorId() { return commentAuthorId; }
        public String getCommentContent() { return commentContent; }
        public LocalDateTime getCommentedAt() { return commentedAt; }
    }
    
    /**
     * 관리자 배정 이벤트
     */
    public static class ManagerAssignmentEvent {
        private final UUID reportId;
        private final UUID managerId;
        private final LocalDateTime assignedAt;
        
        public ManagerAssignmentEvent(UUID reportId, UUID managerId) {
            this.reportId = reportId;
            this.managerId = managerId;
            this.assignedAt = LocalDateTime.now();
        }
        
        // Getters
        public UUID getReportId() { return reportId; }
        public UUID getManagerId() { return managerId; }
        public LocalDateTime getAssignedAt() { return assignedAt; }
    }
    
    /**
     * 보안 이벤트
     */
    public static class SecurityEvent {
        private final UUID userId;
        private final String eventType;
        private final String details;
        private final AlertSeverity severity;
        private final LocalDateTime detectedAt;
        
        public SecurityEvent(UUID userId, String eventType, String details, AlertSeverity severity) {
            this.userId = userId;
            this.eventType = eventType;
            this.details = details;
            this.severity = severity;
            this.detectedAt = LocalDateTime.now();
        }
        
        // Getters
        public UUID getUserId() { return userId; }
        public String getEventType() { return eventType; }
        public String getDetails() { return details; }
        public AlertSeverity getSeverity() { return severity; }
        public LocalDateTime getDetectedAt() { return detectedAt; }
    }
    
    /**
     * 시스템 점검 이벤트
     */
    public static class MaintenanceEvent {
        private final String title;
        private final String details;
        private final LocalDateTime startTime;
        private final LocalDateTime endTime;
        
        public MaintenanceEvent(String title, String details, LocalDateTime startTime, LocalDateTime endTime) {
            this.title = title;
            this.details = details;
            this.startTime = startTime;
            this.endTime = endTime;
        }
        
        // Getters
        public String getTitle() { return title; }
        public String getDetails() { return details; }
        public LocalDateTime getStartTime() { return startTime; }
        public LocalDateTime getEndTime() { return endTime; }
    }
}