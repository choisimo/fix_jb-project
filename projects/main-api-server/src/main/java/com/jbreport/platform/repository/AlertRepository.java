package com.jbreport.platform.repository;

import com.jbreport.platform.entity.Alert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface AlertRepository extends JpaRepository<Alert, Long>, JpaSpecificationExecutor<Alert> {
    
    Optional<Alert> findByIdAndUserId(Long id, Long userId);
    
    Long countByUserIdAndIsReadFalse(Long userId);
    
    @Modifying
    @Query("UPDATE Alert a SET a.isRead = true, a.readAt = :readAt WHERE a.userId = :userId AND a.isRead = false")
    void markAllAsReadByUserId(@Param("userId") Long userId, @Param("readAt") LocalDateTime readAt);
    
    default void markAllAsReadByUserId(Long userId) {
        markAllAsReadByUserId(userId, LocalDateTime.now());
    }
    
    @Query("SELECT a FROM Alert a WHERE a.userId = :userId AND a.isRead = false ORDER BY a.createdAt DESC")
    List<Alert> findUnreadByUserId(@Param("userId") Long userId);
    
    @Query("SELECT a FROM Alert a WHERE a.expiresAt IS NOT NULL AND a.expiresAt < :now")
    List<Alert> findExpiredAlerts(@Param("now") LocalDateTime now);
    
    @Modifying
    @Query("DELETE FROM Alert a WHERE a.expiresAt IS NOT NULL AND a.expiresAt < :now")
    void deleteExpiredAlerts(@Param("now") LocalDateTime now);
    
    List<Alert> findByUserIdAndTypeOrderByCreatedAtDesc(Long userId, Alert.AlertType type);
    
    List<Alert> findByUserIdAndSeverityOrderByCreatedAtDesc(Long userId, Alert.AlertSeverity severity);
}
