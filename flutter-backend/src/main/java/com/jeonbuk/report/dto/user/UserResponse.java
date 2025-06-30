package com.jeonbuk.report.dto.user;

import com.jeonbuk.report.domain.entity.User;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 사용자 응답 DTO
 */
@Schema(description = "사용자 응답")
public record UserResponse(
        @Schema(description = "사용자 ID", example = "123e4567-e89b-12d3-a456-426614174000") UUID id,

        @Schema(description = "사용자명", example = "홍길동") String name,

        @Schema(description = "이메일", example = "hong@example.com") String email,

        @Schema(description = "전화번호", example = "010-1234-5678") String phone,

        @Schema(description = "부서", example = "IT팀") String department,

        @Schema(description = "역할", example = "USER") User.UserRole role,

        @Schema(description = "OAuth 제공자", example = "google") String oauthProvider,

        @Schema(description = "활성 상태", example = "true") Boolean isActive,

        @Schema(description = "이메일 인증 여부", example = "true") Boolean emailVerified,

        @Schema(description = "생성일") LocalDateTime createdAt,

        @Schema(description = "수정일") LocalDateTime updatedAt,

        @Schema(description = "마지막 로그인") LocalDateTime lastLogin) {
    public static UserResponse fromEntity(User user) {
        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getPhone(),
                user.getDepartment(),
                user.getRole(),
                user.getOauthProvider(),
                user.getIsActive(),
                user.getEmailVerified(),
                user.getCreatedAt(),
                user.getUpdatedAt(),
                user.getLastLogin());
    }

    /**
     * Entity를 DTO로 변환 (간단한 메서드명)
     */
    public static UserResponse from(User user) {
        if (user == null) {
            return null;
        }
        return fromEntity(user);
    }
}
