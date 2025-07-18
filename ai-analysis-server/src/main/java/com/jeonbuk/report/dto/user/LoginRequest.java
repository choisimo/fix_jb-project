package com.jeonbuk.report.dto.user;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * 로그인 요청 DTO
 */
@Schema(description = "로그인 요청")
public record LoginRequest(
                @Schema(description = "이메일", example = "hong@example.com") @NotBlank(message = "이메일은 필수입니다") @Email(message = "올바른 이메일 형식이어야 합니다") String email,

                @Schema(description = "비밀번호", example = "password123!") @NotBlank(message = "비밀번호는 필수입니다") String password) {
}
