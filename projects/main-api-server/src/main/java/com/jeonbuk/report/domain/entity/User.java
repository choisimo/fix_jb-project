package com.jeonbuk.report.domain.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
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

  @Convert(converter = UserRoleConverter.class)
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

  // Lombok이 작동하지 않을 경우를 위한 수동 getter/setter 메서드들
  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public String getPasswordHash() {
    return passwordHash;
  }

  public void setPasswordHash(String passwordHash) {
    this.passwordHash = passwordHash;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getPhone() {
    return phone;
  }

  public void setPhone(String phone) {
    this.phone = phone;
  }

  public String getDepartment() {
    return department;
  }

  public void setDepartment(String department) {
    this.department = department;
  }

  public UserRole getRole() {
    return role;
  }

  public void setRole(UserRole role) {
    this.role = role;
  }

  public String getOauthProvider() {
    return oauthProvider;
  }

  public void setOauthProvider(String oauthProvider) {
    this.oauthProvider = oauthProvider;
  }

  public Boolean getIsActive() {
    return isActive;
  }

  public void setIsActive(Boolean isActive) {
    this.isActive = isActive;
  }

  public Boolean getEmailVerified() {
    return emailVerified;
  }

  public void setEmailVerified(Boolean emailVerified) {
    this.emailVerified = emailVerified;
  }

  public LocalDateTime getLastLogin() {
    return lastLogin;
  }

  public void setLastLogin(LocalDateTime lastLogin) {
    this.lastLogin = lastLogin;
  }

  public LocalDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(LocalDateTime createdAt) {
    this.createdAt = createdAt;
  }

  public LocalDateTime getUpdatedAt() {
    return updatedAt;
  }

  public void setUpdatedAt(LocalDateTime updatedAt) {
    this.updatedAt = updatedAt;
  }

  // Manual builder implementation
  public static UserBuilder builder() {
    return new UserBuilder();
  }

  public static class UserBuilder {
    private UUID id;
    private String email;
    private String passwordHash;
    private String name;
    private String phone;
    private String department;
    private UserRole role = UserRole.USER;
    private String oauthProvider;
    private String oauthId;
    private String oauthEmail;
    private Boolean isActive = true;
    private Boolean emailVerified = false;
    private LocalDateTime lastLogin;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public UserBuilder id(UUID id) { this.id = id; return this; }
    public UserBuilder email(String email) { this.email = email; return this; }
    public UserBuilder passwordHash(String passwordHash) { this.passwordHash = passwordHash; return this; }
    public UserBuilder name(String name) { this.name = name; return this; }
    public UserBuilder phone(String phone) { this.phone = phone; return this; }
    public UserBuilder department(String department) { this.department = department; return this; }
    public UserBuilder role(UserRole role) { this.role = role; return this; }
    public UserBuilder oauthProvider(String oauthProvider) { this.oauthProvider = oauthProvider; return this; }
    public UserBuilder oauthId(String oauthId) { this.oauthId = oauthId; return this; }
    public UserBuilder oauthEmail(String oauthEmail) { this.oauthEmail = oauthEmail; return this; }
    public UserBuilder isActive(Boolean isActive) { this.isActive = isActive; return this; }
    public UserBuilder emailVerified(Boolean emailVerified) { this.emailVerified = emailVerified; return this; }
    public UserBuilder lastLogin(LocalDateTime lastLogin) { this.lastLogin = lastLogin; return this; }
    public UserBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
    public UserBuilder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

    public User build() {
      User user = new User();
      user.id = this.id;
      user.email = this.email;
      user.passwordHash = this.passwordHash;
      user.name = this.name;
      user.phone = this.phone;
      user.department = this.department;
      user.role = this.role;
      user.oauthProvider = this.oauthProvider;
      user.oauthId = this.oauthId;
      user.oauthEmail = this.oauthEmail;
      user.isActive = this.isActive;
      user.emailVerified = this.emailVerified;
      user.lastLogin = this.lastLogin;
      user.createdAt = this.createdAt;
      user.updatedAt = this.updatedAt;
      user.reports = new ArrayList<>();
      user.comments = new ArrayList<>();
      user.sessions = new ArrayList<>();
      user.notifications = new ArrayList<>();
      return user;
    }
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
    
    @Override
    public String toString() {
      return name().toLowerCase();
    }
  }
}
