package com.jeonbuk.report.presentation.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 인증번호 확인 요청 DTO
 */
@Data
@Schema(description = "인증번호 확인 요청")
public class VerifyCodeRequest {

    @Schema(description = "인증 대상 (휴대폰 번호 또는 이메일)", example = "010-1234-5678")
    @NotBlank(message = "인증 대상을 입력해주세요.")
    private String target;

    @Schema(description = "인증번호", example = "123456")
    @NotBlank(message = "인증번호를 입력해주세요.")
    private String code;
}