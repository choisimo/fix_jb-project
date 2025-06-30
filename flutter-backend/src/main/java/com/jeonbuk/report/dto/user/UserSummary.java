package com.jeonbuk.report.dto.user;

import com.jeonbuk.report.domain.entity.User;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

/**
 * 사용자 요약 DTO (목록용)
 */
@Schema(description = "사용자 요약")
public record UserSummary(
        @Schema(description = "사용자 ID", example = "123e4567-e89b-12d3-a456-426614174000") UUID id,

        @Schema(description = "사용자명", example = "홍길동") String name,

        @Schema(description = "이메일", example = "hong@example.com") String email,

        @Schema(description = "역할", example = "USER") User.UserRole role) {
    public static UserSummary from(User user) {
        return new UserSummary(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole());
    }
}
