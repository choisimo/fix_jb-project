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
 * 사용자 세션 엔티티
 * - 사용자 로그인 세션 관리
 * - JWT 토큰 추적 및 무효화
 * - 보안 감사를 위한 세션 이력
 */
@Entity
@Table(name = "user_sessions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class UserSession {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(name = "id")
  private UUID id;

  // 연관 관계
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  // 세션 정보
  @Column(name = "session_token", nullable = false, unique = true, length = 500)
  private String sessionToken; // JWT 토큰 또는 세션 ID

  @Column(name = "refresh_token", length = 500)
  private String refreshToken;

  @Column(name = "device_info", length = 200)
  private String deviceInfo; // 사용자 에이전트, 디바이스 정보

  @Column(name = "ip_address", length = 45)
  private String ipAddress; // IPv4/IPv6 지원

  @Column(name = "location", length = 100)
  private String location; // 접속 위치 (선택적)

  // 상태 정보
  @Column(name = "is_active")
  @Builder.Default
  private Boolean isActive = true;

  @Column(name = "expires_at", nullable = false)
  private LocalDateTime expiresAt;

  @Column(name = "last_activity_at")
  private LocalDateTime lastActivityAt;

  @Column(name = "logout_at")
  private LocalDateTime logoutAt;

  // 메타데이터
  @CreatedDate
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @LastModifiedDate
  @Column(name = "updated_at")
  private LocalDateTime updatedAt;

  // 비즈니스 메서드
  public boolean isExpired() {
    return LocalDateTime.now().isAfter(expiresAt);
  }

  public boolean isValid() {
    return isActive && !isExpired() && logoutAt == null;
  }

  public void logout() {
    this.isActive = false;
    this.logoutAt = LocalDateTime.now();
  }

  public void updateActivity() {
    this.lastActivityAt = LocalDateTime.now();
  }

  public void extend(LocalDateTime newExpiryTime) {
    this.expiresAt = newExpiryTime;
    updateActivity();
  }

  public long getMinutesUntilExpiry() {
    return java.time.Duration.between(LocalDateTime.now(), expiresAt).toMinutes();
  }
}
