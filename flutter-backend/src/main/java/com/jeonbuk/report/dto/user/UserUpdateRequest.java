package com.jeonbuk.report.dto.user;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Size;

/**
 * 사용자 수정 요청 DTO
 */
@Schema(description = "사용자 수정 요청")
public record UserUpdateRequest(
        @Schema(description = "사용자명", example = "홍길동") @Size(max = 100, message = "사용자명은 100자 이하여야 합니다") String name,

        @Schema(description = "전화번호", example = "010-1234-5678") @Size(max = 20, message = "전화번호는 20자 이하여야 합니다") String phone,

        @Schema(description = "부서", example = "IT팀") @Size(max = 100, message = "부서명은 100자 이하여야 합니다") String department) {
}
