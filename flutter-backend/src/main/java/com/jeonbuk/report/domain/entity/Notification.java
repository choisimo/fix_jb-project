package com.jeonbuk.report.domain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 알림 엔티티
 * - 사용자 알림 관리
 * - 신고서 상태 변경, 댓글 등에 대한 알림
 * - 푸시 알림 및 이메일 알림 지원
 */
@Entity
@Table(name = "notifications")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Notification {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(name = "id")
  private UUID id;

  // 연관 관계
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id", nullable = false)
  private User user; // 알림을 받을 사용자

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "report_id")
  private Report report; // 관련된 신고서 (선택적)

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "sender_id")
  private User sender; // 알림을 발생시킨 사용자 (선택적)

  // 알림 내용
  @Column(name = "title", nullable = false, length = 200)
  private String title;

  @Column(name = "message", nullable = false, columnDefinition = "TEXT")
  private String message;

  @Enumerated(EnumType.STRING)
  @Column(name = "type", nullable = false)
  private NotificationType type;

  @Enumerated(EnumType.STRING)
  @Column(name = "priority", nullable = false)
  @Builder.Default
  private NotificationPriority priority = NotificationPriority.NORMAL;

  // 링크 정보
  @Column(name = "action_url", length = 500)
  private String actionUrl; // 클릭 시 이동할 URL

  @Column(name = "reference_id", length = 100)
  private String referenceId; // 관련 엔티티 ID

  // 상태 정보
  @Column(name = "is_read")
  @Builder.Default
  private Boolean isRead = false;

  @Column(name = "read_at")
  private LocalDateTime readAt;

  @Column(name = "is_sent")
  @Builder.Default
  private Boolean isSent = false;

  @Column(name = "sent_at")
  private LocalDateTime sentAt;

  @Column(name = "is_email_sent")
  @Builder.Default
  private Boolean isEmailSent = false;

  @Column(name = "email_sent_at")
  private LocalDateTime emailSentAt;

  @Column(name = "is_push_sent")
  @Builder.Default
  private Boolean isPushSent = false;

  @Column(name = "push_sent_at")
  private LocalDateTime pushSentAt;

  // 메타데이터
  @CreatedDate
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @LastModifiedDate
  @Column(name = "updated_at")
  private LocalDateTime updatedAt;

  @Column(name = "expires_at")
  private LocalDateTime expiresAt; // 알림 만료 시간

  // 비즈니스 메서드
  public void markAsRead() {
    this.isRead = true;
    this.readAt = LocalDateTime.now();
  }

  public void markAsSent() {
    this.isSent = true;
    this.sentAt = LocalDateTime.now();
  }

  public void markEmailAsSent() {
    this.isEmailSent = true;
    this.emailSentAt = LocalDateTime.now();
  }

  public void markPushAsSent() {
    this.isPushSent = true;
    this.pushSentAt = LocalDateTime.now();
  }

  public boolean isExpired() {
    return expiresAt != null && LocalDateTime.now().isAfter(expiresAt);
  }

  public boolean isHighPriority() {
    return priority == NotificationPriority.HIGH || priority == NotificationPriority.URGENT;
  }

  // 알림 유형 열거형
  public enum NotificationType {
    REPORT_SUBMITTED("신고서 제출"),
    REPORT_APPROVED("신고서 승인"),
    REPORT_REJECTED("신고서 반려"),
    REPORT_COMPLETED("신고서 완료"),
    COMMENT_ADDED("댓글 추가"),
    STATUS_CHANGED("상태 변경"),
    ASSIGNMENT_CHANGED("담당자 변경"),
    SYSTEM_MAINTENANCE("시스템 점검"),
    SECURITY_ALERT("보안 알림");

    private final String description;

    NotificationType(String description) {
      this.description = description;
    }

    public String getDescription() {
      return description;
    }
  }

  // 알림 우선순위 열거형
  public enum NotificationPriority {
    LOW("낮음"),
    NORMAL("보통"),
    HIGH("높음"),
    URGENT("긴급");

    private final String description;

    NotificationPriority(String description) {
      this.description = description;
    }

    public String getDescription() {
      return description;
    }
  }
}
