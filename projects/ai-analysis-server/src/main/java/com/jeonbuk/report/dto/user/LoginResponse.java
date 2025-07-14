package com.jeonbuk.report.dto.user;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 로그인 응답 DTO
 */
@Schema(description = "로그인 응답")
public record LoginResponse(
                @Schema(description = "액세스 토큰") String accessToken,

                @Schema(description = "리프레시 토큰") String refreshToken,

                @Schema(description = "토큰 타입", example = "Bearer") String tokenType,

                @Schema(description = "만료 시간 (초)", example = "3600") Long expiresIn,

                @Schema(description = "사용자 정보") UserSummary user) {
}
