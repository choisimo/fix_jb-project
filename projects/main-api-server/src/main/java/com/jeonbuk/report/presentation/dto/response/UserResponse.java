package com.jeonbuk.report.presentation.dto.response;

import com.jeonbuk.report.domain.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 사용자 응답 DTO
 * - 클라이언트로 전송되는 사용자 정보
 * - 민감한 정보 제외 (패스워드 등)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {

  private UUID id;
  private String email;
  private String name;
  private String phone;
  private String department;
  private String role;
  private String roleDescription;

  // OAuth 정보 (공개 가능한 부분만)
  private String oauthProvider;
  private boolean isOAuthUser;

  // 상태 정보
  private boolean isActive;
  private boolean emailVerified;
  private LocalDateTime lastLogin;

  // 메타데이터
  private LocalDateTime createdAt;
  private LocalDateTime updatedAt;

  // 통계 정보 (선택적)
  private Long reportCount;
  private Long commentCount;

  /**
   * Entity를 DTO로 변환
   */
  public static UserResponse fromEntity(User user) {
    return new UserResponseBuilder()
        .id(user.getId())
        .email(user.getEmail())
        .name(user.getName())
        .phone(user.getPhone())
        .department(user.getDepartment())
        .role(user.getRole().name())
        .roleDescription(user.getRole().getDescription())
        .oauthProvider(user.getOauthProvider())
        .isOAuthUser(user.isOAuthUser())
        .isActive(user.getIsActive())
        .emailVerified(user.getEmailVerified())
        .lastLogin(user.getLastLogin())
        .createdAt(user.getCreatedAt())
        .updatedAt(user.getUpdatedAt())
        .build();
  }

  /**
   * 통계 정보를 포함한 Entity를 DTO로 변환
   */
  public static UserResponse fromEntityWithStats(User user, Long reportCount, Long commentCount) {
    UserResponse response = fromEntity(user);
    response.setReportCount(reportCount);
    response.setCommentCount(commentCount);
    return response;
  }

  /**
   * 간단한 사용자 정보만 포함 (목록 조회용)
   */
  public static UserResponse fromEntitySimple(User user) {
    return new UserResponseBuilder()
        .id(user.getId())
        .email(user.getEmail())
        .name(user.getName())
        .role(user.getRole().name())
        .roleDescription(user.getRole().getDescription())
        .isActive(user.getIsActive())
        .createdAt(user.getCreatedAt())
        .build();
  }

  // Manual builder implementation
  public static UserResponseBuilder builder() {
    return new UserResponseBuilder();
  }

  public static class UserResponseBuilder {
    private UUID id;
    private String email;
    private String name;
    private String phone;
    private String department;
    private String role;
    private String roleDescription;
    private String oauthProvider;
    private boolean isOAuthUser;
    private boolean isActive;
    private boolean emailVerified;
    private LocalDateTime lastLogin;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long reportCount;
    private Long commentCount;

    public UserResponseBuilder id(UUID id) { this.id = id; return this; }
    public UserResponseBuilder email(String email) { this.email = email; return this; }
    public UserResponseBuilder name(String name) { this.name = name; return this; }
    public UserResponseBuilder phone(String phone) { this.phone = phone; return this; }
    public UserResponseBuilder department(String department) { this.department = department; return this; }
    public UserResponseBuilder role(String role) { this.role = role; return this; }
    public UserResponseBuilder roleDescription(String roleDescription) { this.roleDescription = roleDescription; return this; }
    public UserResponseBuilder oauthProvider(String oauthProvider) { this.oauthProvider = oauthProvider; return this; }
    public UserResponseBuilder isOAuthUser(boolean isOAuthUser) { this.isOAuthUser = isOAuthUser; return this; }
    public UserResponseBuilder isActive(boolean isActive) { this.isActive = isActive; return this; }
    public UserResponseBuilder emailVerified(boolean emailVerified) { this.emailVerified = emailVerified; return this; }
    public UserResponseBuilder lastLogin(LocalDateTime lastLogin) { this.lastLogin = lastLogin; return this; }
    public UserResponseBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
    public UserResponseBuilder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }
    public UserResponseBuilder reportCount(Long reportCount) { this.reportCount = reportCount; return this; }
    public UserResponseBuilder commentCount(Long commentCount) { this.commentCount = commentCount; return this; }

    public UserResponse build() {
      UserResponse response = new UserResponse();
      response.id = this.id;
      response.email = this.email;
      response.name = this.name;
      response.phone = this.phone;
      response.department = this.department;
      response.role = this.role;
      response.roleDescription = this.roleDescription;
      response.oauthProvider = this.oauthProvider;
      response.isOAuthUser = this.isOAuthUser;
      response.isActive = this.isActive;
      response.emailVerified = this.emailVerified;
      response.lastLogin = this.lastLogin;
      response.createdAt = this.createdAt;
      response.updatedAt = this.updatedAt;
      response.reportCount = this.reportCount;
      response.commentCount = this.commentCount;
      return response;
    }
  }

  // Manual setters for missing methods
  public void setReportCount(Long reportCount) {
    this.reportCount = reportCount;
  }

  public void setCommentCount(Long commentCount) {
    this.commentCount = commentCount;
  }
}
