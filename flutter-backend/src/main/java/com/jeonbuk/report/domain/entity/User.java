package com.jeonbuk.report.domain.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 사용자 엔티티
 * - 이메일/패스워드 인증 및 OAuth 인증 지원
 * - 사용자 역할 관리 (user, manager, admin)
 * - 소프트 삭제 지원
 */
@Entity
@Table(name = "users")
@Data
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class User {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(name = "id")
  private UUID id;

  @Column(name = "email", nullable = false, unique = true)
  private String email;

  @JsonIgnore
  @Column(name = "password_hash")
  private String passwordHash;

  @Column(name = "name", nullable = false, length = 100)
  private String name;

  @Column(name = "phone", length = 20)
  private String phone;

  @Column(name = "department", length = 100)
  private String department;

  @Enumerated(EnumType.STRING)
  @Column(name = "role", nullable = false)
  @Builder.Default
  private UserRole role = UserRole.USER;

  // OAuth 정보
  @Column(name = "oauth_provider", length = 50)
  private String oauthProvider;

  @Column(name = "oauth_id")
  private String oauthId;

  @Column(name = "oauth_email")
  private String oauthEmail;

  // 상태 정보
  @Column(name = "is_active")
  @Builder.Default
  private Boolean isActive = true;

  @Column(name = "email_verified")
  @Builder.Default
  private Boolean emailVerified = false;

  @Column(name = "last_login")
  private LocalDateTime lastLogin;

  @CreatedDate
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @LastModifiedDate
  @Column(name = "updated_at")
  private LocalDateTime updatedAt;

  // 연관 관계
  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  @JsonIgnore
  @Builder.Default
  private List<Report> reports = new ArrayList<>();

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  @JsonIgnore
  @Builder.Default
  private List<Comment> comments = new ArrayList<>();

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  @JsonIgnore
  @Builder.Default
  private List<UserSession> sessions = new ArrayList<>();

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  @JsonIgnore
  @Builder.Default
  private List<Notification> notifications = new ArrayList<>();

  // 비즈니스 메서드
  public boolean isOAuthUser() {
    return oauthProvider != null && oauthId != null;
  }

  public boolean isPasswordUser() {
    return passwordHash != null;
  }

  public boolean hasRole(UserRole role) {
    return this.role == role;
  }

  public boolean isManager() {
    return this.role == UserRole.MANAGER || this.role == UserRole.ADMIN;
  }

  public boolean isAdmin() {
    return this.role == UserRole.ADMIN;
  }

  /**
   * 사용자 활성화
   */
  public void activate() {
    this.isActive = true;
  }

  /**
   * 사용자 비활성화
   */
  public void deactivate() {
    this.isActive = false;
  }

  /**
   * 마지막 로그인 시간 업데이트
   */
  public void updateLastLogin() {
    this.lastLogin = LocalDateTime.now();
  }

  // 사용자 역할 열거형
  public enum UserRole {
    USER("일반 사용자"),
    MANAGER("관리자"),
    ADMIN("시스템 관리자");

    private final String description;

    UserRole(String description) {
      this.description = description;
    }

    public String getDescription() {
      return description;
    }
  }
}
