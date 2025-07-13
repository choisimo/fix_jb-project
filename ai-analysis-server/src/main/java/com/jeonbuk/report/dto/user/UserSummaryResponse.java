package com.jeonbuk.report.dto.user;

import com.jeonbuk.report.domain.entity.User;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

@Schema(description = "사용자 요약 정보")
public record UserSummaryResponse(
        @Schema(description = "사용자 ID") UUID id,
        @Schema(description = "이름") String name,
        @Schema(description = "이메일") String email,
        @Schema(description = "역할") User.UserRole role
) {
    public static UserSummaryResponse from(User user) {
        return new UserSummaryResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole()
        );
    }
}