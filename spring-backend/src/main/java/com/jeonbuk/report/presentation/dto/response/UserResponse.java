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
    return UserResponse.builder()
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
    return UserResponse.builder()
        .id(user.getId())
        .email(user.getEmail())
        .name(user.getName())
        .role(user.getRole().name())
        .roleDescription(user.getRole().getDescription())
        .isActive(user.getIsActive())
        .createdAt(user.getCreatedAt())
        .build();
  }
}
