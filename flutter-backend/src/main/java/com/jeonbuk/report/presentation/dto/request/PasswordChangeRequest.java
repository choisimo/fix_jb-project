package com.jeonbuk.report.presentation.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * 비밀번호 변경 요청 DTO
 */
@Schema(description = "비밀번호 변경 요청")
public record PasswordChangeRequest(
        @Schema(description = "현재 비밀번호", required = true) @NotBlank(message = "현재 비밀번호는 필수입니다") String currentPassword,

        @Schema(description = "새 비밀번호", example = "NewPassword123!", required = true) @NotBlank(message = "새 비밀번호는 필수입니다") @Size(min = 8, max = 100, message = "비밀번호는 8-100자 사이여야 합니다") @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]+$", message = "비밀번호는 영문 대소문자, 숫자, 특수문자를 포함해야 합니다") String newPassword,

        @Schema(description = "새 비밀번호 확인", required = true) @NotBlank(message = "새 비밀번호 확인은 필수입니다") String confirmNewPassword) {
    public boolean isNewPasswordMatching() {
        return newPassword != null && newPassword.equals(confirmNewPassword);
    }
}
