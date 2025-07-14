package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Alert.AlertSeverity;
import com.jeonbuk.report.domain.entity.Alert.AlertType;
import com.jeonbuk.report.domain.entity.Alert;
import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.domain.repository.UserRepository;
import com.jeonbuk.report.domain.repository.ReportRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import jakarta.servlet.http.HttpServletRequest;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.Optional;

/**
 * Alert 생성 서비스
 * 시스템 이벤트에 따라 자동으로 알림을 생성하는 서비스
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AlertCreationService {
    
    private final AlertEntityService alertEntityService;
    private final UserRepository userRepository;
    private final ReportRepository reportRepository;
    
    /**
     * 사용자 ID로 알림 생성
     */
    public Alert createAlert(UUID userId, AlertType type, String title, String content, AlertSeverity severity) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found: " + userId);
        }
        
        User user = userOpt.get();
        Alert alert = alertEntityService.createAlert(user, type, title, content, severity);
        
        log.info("Created alert for user {}: {}", userId, title);
        return alert;
    }
    
    /**
     * 신고서 상태 변경 알림 생성
     */
    public Alert createReportStatusChangeAlert(UUID reportId, String newStatus, String previousStatus) {
        Optional<Report> reportOpt = reportRepository.findById(reportId);
        if (reportOpt.isEmpty()) {
            throw new IllegalArgumentException("Report not found: " + reportId);
        }
        
        Report report = reportOpt.get();
        User user = report.getUser();
        
        String title = "신고서 상태가 변경되었습니다";
        String content = String.format("""
            {
                "reportId": "%s",
                "reportTitle": "%s",
                "previousStatus": "%s",
                "newStatus": "%s",
                "changedAt": "%s"
            }
            """, 
            reportId, 
            report.getTitle(),
            previousStatus,
            newStatus,
            LocalDateTime.now()
        );
        
        AlertSeverity severity = determineStatusChangeSeverity(newStatus);
        
        Alert alert = alertEntityService.createReportAlert(
            user, 
            report, 
            AlertType.REPORT_ESCALATION, 
            title, 
            content, 
            severity
        );
        
        log.info("Created report status change alert for report {} (user {}): {} -> {}", 
                reportId, user.getId(), previousStatus, newStatus);
        return alert;
    }
    
    /**
     * 새 댓글 알림 생성
     */
    public Alert createNewCommentAlert(UUID reportId, UUID commentAuthorId, String commentContent) {
        Optional<Report> reportOpt = reportRepository.findById(reportId);
        if (reportOpt.isEmpty()) {
            throw new IllegalArgumentException("Report not found: " + reportId);
        }
        
        Optional<User> commentAuthorOpt = userRepository.findById(commentAuthorId);
        if (commentAuthorOpt.isEmpty()) {
            throw new IllegalArgumentException("Comment author not found: " + commentAuthorId);
        }
        
        Report report = reportOpt.get();
        User reportOwner = report.getUser();
        User commentAuthor = commentAuthorOpt.get();
        
        // 자신이 단 댓글에는 알림 생성하지 않음
        if (reportOwner.getId().equals(commentAuthorId)) {
            log.debug("Skipping comment alert for self-comment on report {}", reportId);
            return null;
        }
        
        String title = "새 댓글이 추가되었습니다";
        String content = String.format("""
            {
                "reportId": "%s",
                "reportTitle": "%s",
                "commentAuthor": "%s",
                "commentPreview": "%s",
                "commentedAt": "%s"
            }
            """, 
            reportId,
            report.getTitle(),
            commentAuthor.getName(),
            truncateContent(commentContent, 100),
            LocalDateTime.now()
        );
        
        Alert alert = alertEntityService.createReportAlert(
            reportOwner, 
            report, 
            AlertType.USER_ACTION_REQUIRED, 
            title, 
            content, 
            AlertSeverity.MEDIUM
        );
        
        log.info("Created new comment alert for report {} (user {})", reportId, reportOwner.getId());
        return alert;
    }
    
    /**
     * 관리자 배정 알림 생성
     */
    public Alert createManagerAssignmentAlert(UUID reportId, UUID managerId) {
        Optional<Report> reportOpt = reportRepository.findById(reportId);
        Optional<User> managerOpt = userRepository.findById(managerId);
        
        if (reportOpt.isEmpty() || managerOpt.isEmpty()) {
            throw new IllegalArgumentException("Report or Manager not found");
        }
        
        Report report = reportOpt.get();
        User reportOwner = report.getUser();
        User manager = managerOpt.get();
        
        String title = "담당자가 배정되었습니다";
        String content = String.format("""
            {
                "reportId": "%s",
                "reportTitle": "%s",
                "managerName": "%s",
                "assignedAt": "%s"
            }
            """, 
            reportId,
            report.getTitle(),
            manager.getName(),
            LocalDateTime.now()
        );
        
        Alert alert = alertEntityService.createReportAlert(
            reportOwner, 
            report, 
            AlertType.SYSTEM_NOTIFICATION, 
            title, 
            content, 
            AlertSeverity.MEDIUM
        );
        
        log.info("Created manager assignment alert for report {} (user {}): manager {}", 
                reportId, reportOwner.getId(), managerId);
        return alert;
    }
    
    /**
     * 시스템 점검 알림 생성 (모든 사용자)
     */
    public List<Alert> createSystemMaintenanceAlert(String maintenanceTitle, String maintenanceDetails, 
                                                   LocalDateTime maintenanceStart, LocalDateTime maintenanceEnd) {
        List<User> allUsers = userRepository.findByIsActiveTrue();
        
        String title = "시스템 점검 안내";
        String content = String.format("""
            {
                "maintenanceTitle": "%s",
                "details": "%s",
                "startTime": "%s",
                "endTime": "%s",
                "notifiedAt": "%s"
            }
            """,
            maintenanceTitle,
            maintenanceDetails,
            maintenanceStart,
            maintenanceEnd,
            LocalDateTime.now()
        );
        
        return allUsers.stream()
                .map(user -> {
                    Alert alert = alertEntityService.createExpiringAlert(
                        user,
                        AlertType.MAINTENANCE,
                        title,
                        content,
                        AlertSeverity.HIGH,
                        maintenanceEnd.plusHours(1) // 점검 종료 1시간 후 만료
                    );
                    log.debug("Created maintenance alert for user {}", user.getId());
                    return alert;
                })
                .toList();
    }
    
    /**
     * 보안 위험 알림 생성
     */
    public Alert createSecurityAlert(UUID userId, String securityEvent, String details, AlertSeverity severity) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found: " + userId);
        }
        
        User user = userOpt.get();
        String title = "보안 알림";
        String content = String.format("""
            {
                "securityEvent": "%s",
                "details": "%s",
                "detectedAt": "%s",
                "userAgent": "%s",
                "ipAddress": "%s"
            }
            """,
            securityEvent,
            details,
            LocalDateTime.now(),
            getRequestUserAgent(),
            getRequestIpAddress()
        );
        
        Alert alert = alertEntityService.createAlert(
            user,
            AlertType.SECURITY_BREACH,
            title,
            content,
            severity
        );
        
        log.warn("Created security alert for user {}: {}", userId, securityEvent);
        return alert;
    }
    
    /**
     * 마감일 경고 알림 생성
     */
    public Alert createDeadlineWarningAlert(UUID reportId, int daysRemaining) {
        Optional<Report> reportOpt = reportRepository.findById(reportId);
        if (reportOpt.isEmpty()) {
            throw new IllegalArgumentException("Report not found: " + reportId);
        }
        
        Report report = reportOpt.get();
        User user = report.getUser();
        
        String title = String.format("처리 마감일이 %d일 남았습니다", daysRemaining);
        String content = String.format("""
            {
                "reportId": "%s",
                "reportTitle": "%s",
                "daysRemaining": %d,
                "warningAt": "%s"
            }
            """,
            reportId,
            report.getTitle(),
            daysRemaining,
            LocalDateTime.now()
        );
        
        AlertSeverity severity = daysRemaining <= 1 ? AlertSeverity.CRITICAL : 
                               daysRemaining <= 3 ? AlertSeverity.HIGH : AlertSeverity.MEDIUM;
        
        Alert alert = alertEntityService.createReportAlert(
            user,
            report,
            AlertType.DEADLINE_WARNING,
            title,
            content,
            severity
        );
        
        log.info("Created deadline warning alert for report {} (user {}): {} days remaining", 
                reportId, user.getId(), daysRemaining);
        return alert;
    }
    
    /**
     * 성능 이슈 알림 생성 (관리자용)
     */
    public List<Alert> createPerformanceIssueAlert(String issueType, String metrics, AlertSeverity severity) {
        // 관리자 권한을 가진 사용자들에게만 알림 생성
        List<User> adminUsers = userRepository.findByRoleAndIsActiveTrue(User.UserRole.ADMIN);
        
        String title = "시스템 성능 이슈 감지";
        String content = String.format("""
            {
                "issueType": "%s",
                "metrics": "%s",
                "detectedAt": "%s"
            }
            """,
            issueType,
            metrics,
            LocalDateTime.now()
        );
        
        return adminUsers.stream()
                .map(admin -> {
                    Alert alert = alertEntityService.createAlert(
                        admin,
                        AlertType.PERFORMANCE_ISSUE,
                        title,
                        content,
                        severity
                    );
                    log.warn("Created performance issue alert for admin {}: {}", admin.getId(), issueType);
                    return alert;
                })
                .toList();
    }
    
    // === 유틸리티 메서드들 ===
    
    /**
     * 상태 변경에 따른 알림 심각도 결정
     */
    private AlertSeverity determineStatusChangeSeverity(String newStatus) {
        return switch (newStatus.toUpperCase()) {
            case "COMPLETED", "RESOLVED" -> AlertSeverity.LOW;
            case "IN_PROGRESS", "ASSIGNED" -> AlertSeverity.MEDIUM;
            case "URGENT", "ESCALATED" -> AlertSeverity.HIGH;
            case "CRITICAL", "EMERGENCY" -> AlertSeverity.CRITICAL;
            default -> AlertSeverity.MEDIUM;
        };
    }
    
    /**
     * 텍스트 내용을 지정된 길이로 자르기
     */
    private String truncateContent(String content, int maxLength) {
        if (content == null) {
            return "";
        }
        return content.length() <= maxLength ? content : content.substring(0, maxLength) + "...";
    }
    
    /**
     * 현재 요청의 User-Agent 정보 가져오기
     */
    private String getRequestUserAgent() {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                String userAgent = request.getHeader("User-Agent");
                return userAgent != null ? userAgent : "Unknown";
            }
        } catch (Exception e) {
            log.debug("Failed to get user agent from request context: {}", e.getMessage());
        }
        return "Unknown";
    }
    
    /**
     * 현재 요청의 IP 주소 가져오기
     */
    private String getRequestIpAddress() {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                String ipAddress = request.getHeader("X-Forwarded-For");
                if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
                    ipAddress = request.getHeader("X-Real-IP");
                }
                if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
                    ipAddress = request.getRemoteAddr();
                }
                return ipAddress != null ? ipAddress : "Unknown";
            }
        } catch (Exception e) {
            log.debug("Failed to get IP address from request context: {}", e.getMessage());
        }
        return "Unknown";
    }
}