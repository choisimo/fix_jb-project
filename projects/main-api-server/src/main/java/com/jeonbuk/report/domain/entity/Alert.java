package com.jeonbuk.report.domain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "alerts")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Alert {
    
    @Id
    private String id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "report_id")
    private Report report;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private AlertType type;
    
    @Column(name = "title", nullable = false, length = 200)
    private String title;
    
    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content; // JSON 구조화된 알림 데이터
    
    @Enumerated(EnumType.STRING)
    @Column(name = "severity", nullable = false)
    private AlertSeverity severity;
    
    @Column(name = "is_read", nullable = false)
    @Builder.Default
    private Boolean isRead = false;
    
    @Column(name = "is_resolved", nullable = false)
    @Builder.Default
    private Boolean isResolved = false;
    
    @Column(name = "read_at")
    private LocalDateTime readAt;
    
    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "resolved_by_user_id")
    private User resolvedByUser;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    @Column(name = "expires_at")
    private LocalDateTime expiresAt;
    
    public enum AlertType {
        CRITICAL,
        HIGH_PRIORITY,
        SYSTEM_ERROR,
        SECURITY_BREACH,
        MAINTENANCE,
        REPORT_ESCALATION,
        DEADLINE_WARNING,
        PERFORMANCE_ISSUE,
        USER_ACTION_REQUIRED,
        SYSTEM_NOTIFICATION
    }
    
    public enum AlertSeverity {
        LOW,
        MEDIUM,
        HIGH,
        CRITICAL
    }
    
    @PrePersist
    protected void onCreate() {
        if (id == null) {
            id = java.util.UUID.randomUUID().toString();
        }
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (isRead == null) {
            isRead = false;
        }
        if (isResolved == null) {
            isResolved = false;
        }
        if (severity == null) {
            severity = AlertSeverity.MEDIUM;
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    /**
     * 알림을 읽음으로 표시
     */
    public void markAsRead() {
        this.isRead = true;
        this.readAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 알림을 해결됨으로 표시
     */
    public void markAsResolved(User resolvedBy) {
        this.isResolved = true;
        this.resolvedAt = LocalDateTime.now();
        this.resolvedByUser = resolvedBy;
        this.updatedAt = LocalDateTime.now();
        
        // 해결되면 자동으로 읽음 처리
        if (!this.isRead) {
            markAsRead();
        }
    }
    
    /**
     * 알림이 만료되었는지 확인
     */
    public boolean isExpired() {
        return expiresAt != null && LocalDateTime.now().isAfter(expiresAt);
    }
    
    /**
     * 알림이 활성상태인지 확인 (읽지 않고, 해결되지 않고, 만료되지 않음)
     */
    public boolean isActive() {
        return !isRead && !isResolved && !isExpired();
    }
}