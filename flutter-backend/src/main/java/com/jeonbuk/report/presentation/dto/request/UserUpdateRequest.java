package com.jeonbuk.report.presentation.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * 사용자 정보 수정 요청 DTO
 */
@Schema(description = "사용자 정보 수정 요청")
public record UserUpdateRequest(
    @Schema(description = "이메일", example = "john@example.com")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    String email,

    @Schema(description = "실명", example = "홍길동")
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
