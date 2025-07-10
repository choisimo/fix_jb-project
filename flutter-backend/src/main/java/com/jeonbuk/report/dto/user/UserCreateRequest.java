package com.jeonbuk.report.dto.user;

import com.jeonbuk.report.domain.entity.User;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 사용자 생성 요청 DTO
 */
@Schema(description = "사용자 생성 요청")
public record UserCreateRequest(
                @Schema(description = "사용자명", example = "홍길동") @NotBlank(message = "사용자명은 필수입니다") @Size(max = 100, message = "사용자명은 100자 이하여야 합니다") String name,

                @Schema(description = "이메일", example = "hong@example.com") @NotBlank(message = "이메일은 필수입니다") @Email(message = "올바른 이메일 형식이어야 합니다") String email,

                @Schema(description = "전화번호", example = "010-1234-5678") @Size(max = 20, message = "전화번호는 20자 이하여야 합니다") String phone,

                @Schema(description = "부서", example = "IT팀") @Size(max = 100, message = "부서명은 100자 이하여야 합니다") String department,

                @Schema(description = "비밀번호", example = "password123!") @NotBlank(message = "비밀번호는 필수입니다") @Size(min = 8, max = 100, message = "비밀번호는 8-100자여야 합니다") String password,

                @Schema(description = "역할", example = "USER") User.UserRole role) {
}
