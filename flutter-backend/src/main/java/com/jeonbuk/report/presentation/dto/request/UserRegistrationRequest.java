package com.jeonbuk.report.presentation.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * 사용자 등록 요청 DTO
 */
@Schema(description = "사용자 등록 요청")
public record UserRegistrationRequest(
    @Schema(description = "사용자명", example = "johndoe", required = true)
    @NotBlank(message = "사용자명은 필수입니다")
    @Size(min = 3, max = 50, message = "사용자명은 3-50자 사이여야 합니다")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "사용자명은 영문, 숫자, 언더스코어만 사용 가능합니다")
    String username,

    @Schema(description = "이메일", example = "john@example.com", required = true)
    @NotBlank(message = "이메일은 필수입니다")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    String email,

    @Schema(description = "비밀번호", example = "Password123!", required = true)
    @NotBlank(message = "비밀번호는 필수입니다")
    @Size(min = 8, max = 100, message = "비밀번호는 8-100자 사이여야 합니다")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]+$",
        message = "비밀번호는 영문 대소문자, 숫자, 특수문자를 포함해야 합니다")
    String password,

    @Schema(description = "실명", example = "홍길동", required = true)
    @NotBlank(message = "실명은 필수입니다")
    @Size(max = 100, message = "실명은 100자 이하여야 합니다")
    String realName,

    @Schema(description = "전화번호", example = "010-1234-5678")
    @Pattern(regexp = "^\\d{3}-\\d{4}-\\d{4}$", message = "전화번호 형식이 올바르지 않습니다")
    String phoneNumber,

    @Schema(description = "부서", example = "IT팀")
    @Size(max = 100, message = "부서명은 100자 이하여야 합니다")
    String department
) {
}
