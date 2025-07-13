package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Alert;
import com.jeonbuk.report.domain.entity.Alert.AlertSeverity;
import com.jeonbuk.report.domain.entity.Alert.AlertType;
import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.domain.repository.AlertRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Alert Entity 관리 서비스
 * Alert 엔티티의 CRUD 작업과 비즈니스 로직을 담당
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class AlertEntityService {
    
    private final AlertRepository alertRepository;
    
    /**
     * 새 알림 생성
     */
    @Transactional
    public Alert createAlert(User user, AlertType type, String title, String content, AlertSeverity severity) {
        Alert alert = Alert.builder()
                .user(user)
                .type(type)
                .title(title)
                .content(content)
                .severity(severity)
                .build();
        
        Alert savedAlert = alertRepository.save(alert);
        log.info("Created alert: {} for user: {}", savedAlert.getId(), user.getId());
        
        return savedAlert;
    }
    
    /**
     * 신고서 관련 알림 생성
     */
    @Transactional
    public Alert createReportAlert(User user, Report report, AlertType type, String title, String content, AlertSeverity severity) {
        Alert alert = Alert.builder()
                .user(user)
                .report(report)
                .type(type)
                .title(title)
                .content(content)
                .severity(severity)
                .build();
        
        Alert savedAlert = alertRepository.save(alert);
        log.info("Created report alert: {} for user: {} and report: {}", 
                savedAlert.getId(), user.getId(), report.getId());
        
        return savedAlert;
    }
    
    /**
     * 만료 시간이 있는 알림 생성
     */
    @Transactional
    public Alert createExpiringAlert(User user, AlertType type, String title, String content, 
                                   AlertSeverity severity, LocalDateTime expiresAt) {
        Alert alert = Alert.builder()
                .user(user)
                .type(type)
                .title(title)
                .content(content)
                .severity(severity)
                .expiresAt(expiresAt)
                .build();
        
        Alert savedAlert = alertRepository.save(alert);
        log.info("Created expiring alert: {} for user: {} expires at: {}", 
                savedAlert.getId(), user.getId(), expiresAt);
        
        return savedAlert;
    }
    
    /**
     * 알림 조회
     */
    public Optional<Alert> findById(String id) {
        return alertRepository.findById(id);
    }
    
    /**
     * 사용자별 알림 조회 (페이징)
     */
    public Page<Alert> findByUserId(UUID userId, Pageable pageable) {
        return alertRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
    }
    
    /**
     * 사용자별 읽지 않은 알림 조회
     */
    public List<Alert> findUnreadAlerts(UUID userId) {
        return alertRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(userId);
    }
    
    /**
     * 사용자별 읽지 않은 알림 개수
     */
    public long countUnreadAlerts(UUID userId) {
        return alertRepository.countByUserIdAndIsReadFalse(userId);
    }
    
    /**
     * 사용자별 활성 알림 조회
     */
    public List<Alert> findActiveAlerts(UUID userId) {
        return alertRepository.findActiveAlertsByUserId(userId);
    }
    
    /**
     * 우선순위가 높은 미해결 알림 조회
     */
    public List<Alert> findHighPriorityUnresolvedAlerts(UUID userId) {
        return alertRepository.findHighPriorityUnresolvedAlerts(userId);
    }
    
    /**
     * 신고서 관련 알림 조회
     */
    public List<Alert> findByReportId(String reportId) {
        return alertRepository.findByReportIdOrderByCreatedAtDesc(UUID.fromString(reportId));
    }
    
    /**
     * 알림을 읽음으로 표시
     */
    @Transactional
    public Alert markAsRead(String alertId) {
        Optional<Alert> alertOpt = alertRepository.findById(alertId);
        if (alertOpt.isPresent()) {
            Alert alert = alertOpt.get();
            alert.markAsRead();
            Alert savedAlert = alertRepository.save(alert);
            log.info("Marked alert as read: {}", alertId);
            return savedAlert;
        }
        throw new IllegalArgumentException("Alert not found: " + alertId);
    }
    
    /**
     * 알림을 해결됨으로 표시
     */
    @Transactional
    public Alert markAsResolved(String alertId, User resolvedByUser) {
        Optional<Alert> alertOpt = alertRepository.findById(alertId);
        if (alertOpt.isPresent()) {
            Alert alert = alertOpt.get();
            alert.markAsResolved(resolvedByUser);
            Alert savedAlert = alertRepository.save(alert);
            log.info("Marked alert as resolved: {} by user: {}", alertId, resolvedByUser.getId());
            return savedAlert;
        }
        throw new IllegalArgumentException("Alert not found: " + alertId);
    }
    
    /**
     * 사용자의 모든 읽지 않은 알림을 읽음으로 표시
     */
    @Transactional
    public int markAllAsRead(UUID userId) {
        List<Alert> unreadAlerts = alertRepository.findUnreadAlertsByUserId(userId);
        for (Alert alert : unreadAlerts) {
            alert.markAsRead();
        }
        alertRepository.saveAll(unreadAlerts);
        log.info("Marked {} alerts as read for user: {}", unreadAlerts.size(), userId);
        return unreadAlerts.size();
    }
    
    /**
     * 만료된 알림 정리
     */
    @Transactional
    public int cleanupExpiredAlerts() {
        List<Alert> expiredAlerts = alertRepository.findExpiredAlerts();
        if (!expiredAlerts.isEmpty()) {
            alertRepository.deleteAll(expiredAlerts);
            log.info("Cleaned up {} expired alerts", expiredAlerts.size());
        }
        return expiredAlerts.size();
    }
    
    /**
     * 오래된 해결된 알림 정리 (예: 30일 이전)
     */
    @Transactional
    public int cleanupOldResolvedAlerts(int daysOld) {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(daysOld);
        List<Alert> oldResolvedAlerts = alertRepository.findResolvedAlertsBefore(cutoffDate);
        if (!oldResolvedAlerts.isEmpty()) {
            alertRepository.deleteAll(oldResolvedAlerts);
            log.info("Cleaned up {} old resolved alerts (older than {} days)", 
                    oldResolvedAlerts.size(), daysOld);
        }
        return oldResolvedAlerts.size();
    }
    
    /**
     * 알림 삭제
     */
    @Transactional
    public void deleteAlert(String alertId) {
        if (alertRepository.existsById(alertId)) {
            alertRepository.deleteById(alertId);
            log.info("Deleted alert: {}", alertId);
        } else {
            throw new IllegalArgumentException("Alert not found: " + alertId);
        }
    }
    
    /**
     * 시스템 전체 미해결 알림 통계
     */
    public List<Object[]> getUnresolvedAlertStatistics() {
        return alertRepository.getUnresolvedAlertStatistics();
    }
}