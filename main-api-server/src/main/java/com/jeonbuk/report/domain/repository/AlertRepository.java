package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.Alert;
import com.jeonbuk.report.domain.entity.Alert.AlertSeverity;
import com.jeonbuk.report.domain.entity.Alert.AlertType;
import com.jeonbuk.report.domain.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AlertRepository extends JpaRepository<Alert, String> {
    
    /**
     * 사용자별 알림 조회 (생성일시 내림차순)
     */
    List<Alert> findByUserIdOrderByCreatedAtDesc(UUID userId);
    
    /**
     * 사용자별 알림 조회 (페이징)
     */
    Page<Alert> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);
    
    /**
     * 사용자별 읽지 않은 알림 조회
     */
    List<Alert> findByUserIdAndIsReadFalseOrderByCreatedAtDesc(UUID userId);
    
    /**
     * 사용자별 읽지 않은 알림 개수
     */
    long countByUserIdAndIsReadFalse(UUID userId);
    
    /**
     * 사용자별 해결되지 않은 알림 조회
     */
    List<Alert> findByUserIdAndIsResolvedFalseOrderByCreatedAtDesc(UUID userId);
    
    /**
     * 사용자별 해결되지 않은 알림 개수
     */
    long countByUserIdAndIsResolvedFalse(UUID userId);
    
    /**
     * 사용자별 활성 알림 조회 (읽지 않고, 해결되지 않고, 만료되지 않음)
     */
    @Query("SELECT a FROM Alert a WHERE a.user.id = :userId " +
           "AND a.isRead = false AND a.isResolved = false " +
           "AND (a.expiresAt IS NULL OR a.expiresAt > CURRENT_TIMESTAMP) " +
           "ORDER BY a.severity DESC, a.createdAt DESC")
    List<Alert> findActiveAlertsByUserId(@Param("userId") UUID userId);
    
    /**
     * 특정 심각도 이상의 알림 조회
     */
    @Query("SELECT a FROM Alert a WHERE a.user.id = :userId " +
           "AND a.severity IN :severities " +
           "ORDER BY a.severity DESC, a.createdAt DESC")
    List<Alert> findByUserIdAndSeverityInOrderBySeverityDescCreatedAtDesc(
            @Param("userId") UUID userId, 
            @Param("severities") List<AlertSeverity> severities);
    
    /**
     * 특정 타입의 알림 조회
     */
    List<Alert> findByUserIdAndTypeOrderByCreatedAtDesc(UUID userId, AlertType type);
    
    /**
     * 특정 신고서 관련 알림 조회
     */
    List<Alert> findByReportIdOrderByCreatedAtDesc(UUID reportId);
    
    /**
     * 만료된 알림 조회
     */
    @Query("SELECT a FROM Alert a WHERE a.expiresAt IS NOT NULL " +
           "AND a.expiresAt < CURRENT_TIMESTAMP")
    List<Alert> findExpiredAlerts();
    
    /**
     * 특정 기간 동안의 알림 조회
     */
    @Query("SELECT a FROM Alert a WHERE a.user.id = :userId " +
           "AND a.createdAt BETWEEN :startDate AND :endDate " +
           "ORDER BY a.createdAt DESC")
    List<Alert> findByUserIdAndCreatedAtBetween(
            @Param("userId") UUID userId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);
    
    /**
     * 우선순위가 높은 알림 조회 (CRITICAL, HIGH)
     */
    @Query("SELECT a FROM Alert a WHERE a.user.id = :userId " +
           "AND a.severity IN ('CRITICAL', 'HIGH') " +
           "AND a.isResolved = false " +
           "ORDER BY a.severity DESC, a.createdAt DESC")
    List<Alert> findHighPriorityUnresolvedAlerts(@Param("userId") UUID userId);
    
    /**
     * 시스템 전체 미해결 알림 통계
     */
    @Query("SELECT a.severity, COUNT(a) FROM Alert a " +
           "WHERE a.isResolved = false " +
           "GROUP BY a.severity")
    List<Object[]> getUnresolvedAlertStatistics();
    
    /**
     * 특정 사용자가 해결한 알림들
     */
    List<Alert> findByResolvedByUserOrderByResolvedAtDesc(User resolvedByUser);
    
    /**
     * 일괄 읽음 처리용 - 사용자의 읽지 않은 알림들
     */
    @Query("SELECT a FROM Alert a WHERE a.user.id = :userId AND a.isRead = false")
    List<Alert> findUnreadAlertsByUserId(@Param("userId") UUID userId);
    
    /**
     * 자동 정리용 - 특정 기간 이전의 해결된 알림들
     */
    @Query("SELECT a FROM Alert a WHERE a.isResolved = true " +
           "AND a.resolvedAt < :cutoffDate")
    List<Alert> findResolvedAlertsBefore(@Param("cutoffDate") LocalDateTime cutoffDate);
}