package com.jeonbuk.report.domain.entity;

import com.jeonbuk.report.domain.report.ReportStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 신고서 상태 이력 엔티티
 * - 신고서 상태 변경 이력 추적
 * - 감사 및 추적을 위한 상태 변경 로그
 * - 승인자 및 변경 사유 기록
 */
@Entity
@Table(name = "report_status_histories")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class ReportStatusHistory {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(name = "id")
  private UUID id;

  // 연관 관계
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "report_id", nullable = false)
  private Report report;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "changed_by_user_id", nullable = false)
  private User changedBy; // 상태를 변경한 사용자

  // 상태 정보
  @Enumerated(EnumType.STRING)
  @Column(name = "from_status")
  private ReportStatus fromStatus; // 이전 상태 (최초 생성시 null)

  @Enumerated(EnumType.STRING)
  @Column(name = "to_status", nullable = false)
  private ReportStatus toStatus; // 변경된 상태

  // 변경 정보
  @Column(name = "reason", columnDefinition = "TEXT")
  private String reason; // 상태 변경 사유

  @Column(name = "comment", columnDefinition = "TEXT")
  private String comment; // 추가 의견

  @Enumerated(EnumType.STRING)
  @Column(name = "action_type", nullable = false)
  @Builder.Default
  private ActionType actionType = ActionType.STATUS_CHANGE;

  // 메타데이터
  @Column(name = "ip_address", length = 45)
  private String ipAddress; // 상태 변경한 IP 주소

  @Column(name = "user_agent", length = 500)
  private String userAgent; // 사용자 에이전트

  @CreatedDate
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  // 비즈니스 메서드
  public boolean isInitialStatus() {
    return fromStatus == null;
  }

  public boolean isStatusUpgrade() {
    if (fromStatus == null)
      return true;
    return getStatusOrder(toStatus) > getStatusOrder(fromStatus);
  }

  public boolean isStatusDowngrade() {
    if (fromStatus == null)
      return false;
    return getStatusOrder(toStatus) < getStatusOrder(fromStatus);
  }

  public boolean isApproval() {
    return toStatus == ReportStatus.APPROVED;
  }

  public boolean isRejection() {
    return toStatus == ReportStatus.REJECTED;
  }

  public boolean isCompletion() {
    return toStatus == ReportStatus.COMPLETED;
  }

  private int getStatusOrder(ReportStatus status) {
    return switch (status) {
      case DRAFT -> 0;
      case SUBMITTED -> 1;
      case IN_PROGRESS -> 2;
      case REVIEW -> 3;
      case APPROVED -> 4;
      case COMPLETED -> 5;
      case REJECTED -> -1;
      case CANCELLED -> -2;
    };
  }

  public String getActionDescription() {
    if (fromStatus == null) {
      return "신고서 생성 - " + toStatus.getDescription();
    }
    return fromStatus.getDescription() + " → " + toStatus.getDescription();
  }

  // 액션 유형 열거형
  public enum ActionType {
    STATUS_CHANGE("상태 변경"),
    APPROVAL("승인"),
    REJECTION("반려"),
    SUBMISSION("제출"),
    ASSIGNMENT("담당자 지정"),
    COMPLETION("완료"),
    CANCELLATION("취소"),
    SYSTEM_UPDATE("시스템 업데이트");

    private final String description;

    ActionType(String description) {
      this.description = description;
    }

    public String getDescription() {
      return description;
    }
  }
}
