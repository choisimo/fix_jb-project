package com.jeonbuk.report.dto.user;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 비밀번호 변경 요청 DTO
 */
@Schema(description = "비밀번호 변경 요청")
public record PasswordChangeRequest(
        @Schema(description = "현재 비밀번호", example = "currentPassword123!") @NotBlank(message = "현재 비밀번호는 필수입니다") String currentPassword,

        @Schema(description = "새 비밀번호", example = "newPassword123!") @NotBlank(message = "새 비밀번호는 필수입니다") @Size(min = 8, max = 100, message = "비밀번호는 8-100자여야 합니다") String newPassword,

        @Schema(description = "새 비밀번호 확인", example = "newPassword123!") @NotBlank(message = "새 비밀번호 확인은 필수입니다") String confirmPassword) {
}
