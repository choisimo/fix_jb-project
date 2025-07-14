package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.VerificationService;
import com.jeonbuk.report.presentation.dto.request.SendVerificationRequest;
import com.jeonbuk.report.presentation.dto.request.VerifyCodeRequest;
import com.jeonbuk.report.presentation.dto.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * 인증 컨트롤러 (SMS/Email)
 */
@Slf4j
@RestController
@RequestMapping("/api/verification")
@RequiredArgsConstructor
@Tag(name = "Verification", description = "SMS/Email 인증 API")
public class VerificationController {

    private final VerificationService verificationService;

    @Operation(summary = "SMS 인증번호 발송", description = "휴대폰 번호로 인증번호를 발송합니다.")
    @PostMapping("/sms/send")
    public ResponseEntity<ApiResponse<Void>> sendSmsVerification(@Valid @RequestBody SendVerificationRequest request) {
        try {
            boolean sent = verificationService.sendSmsVerification(request.getTarget());
            
            if (sent) {
                return ResponseEntity.ok(ApiResponse.success("SMS 인증번호가 발송되었습니다.", null));
            } else {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("SMS 인증번호 발송에 실패했습니다."));
            }
        } catch (Exception e) {
            log.error("SMS 인증번호 발송 오류", e);
            return ResponseEntity.internalServerError()
                .body(ApiResponse.error("서버 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "Email 인증번호 발송", description = "이메일 주소로 인증번호를 발송합니다.")
    @PostMapping("/email/send")
    public ResponseEntity<ApiResponse<Void>> sendEmailVerification(@Valid @RequestBody SendVerificationRequest request) {
        try {
            boolean sent = verificationService.sendEmailVerification(request.getTarget());
            
            if (sent) {
                return ResponseEntity.ok(ApiResponse.success("Email 인증번호가 발송되었습니다.", null));
            } else {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Email 인증번호 발송에 실패했습니다."));
            }
        } catch (Exception e) {
            log.error("Email 인증번호 발송 오류", e);
            return ResponseEntity.internalServerError()
                .body(ApiResponse.error("서버 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "SMS 인증번호 확인", description = "SMS로 받은 인증번호를 확인합니다.")
    @PostMapping("/sms/verify")
    public ResponseEntity<ApiResponse<Boolean>> verifySmsCode(@Valid @RequestBody VerifyCodeRequest request) {
        try {
            boolean verified = verificationService.verifySmsCode(request.getTarget(), request.getCode());
            
            if (verified) {
                return ResponseEntity.ok(ApiResponse.success("SMS 인증이 완료되었습니다.", true));
            } else {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("인증번호가 올바르지 않거나 만료되었습니다."));
            }
        } catch (Exception e) {
            log.error("SMS 인증 확인 오류", e);
            return ResponseEntity.internalServerError()
                .body(ApiResponse.error("서버 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "Email 인증번호 확인", description = "Email로 받은 인증번호를 확인합니다.")
    @PostMapping("/email/verify")
    public ResponseEntity<ApiResponse<Boolean>> verifyEmailCode(@Valid @RequestBody VerifyCodeRequest request) {
        try {
            boolean verified = verificationService.verifyEmailCode(request.getTarget(), request.getCode());
            
            if (verified) {
                return ResponseEntity.ok(ApiResponse.success("Email 인증이 완료되었습니다.", true));
            } else {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("인증번호가 올바르지 않거나 만료되었습니다."));
            }
        } catch (Exception e) {
            log.error("Email 인증 확인 오류", e);
            return ResponseEntity.internalServerError()
                .body(ApiResponse.error("서버 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "휴대폰 인증 상태 확인", description = "휴대폰 번호의 인증 상태를 확인합니다.")
    @GetMapping("/sms/status")
    public ResponseEntity<ApiResponse<Boolean>> getSmsVerificationStatus(@RequestParam String phoneNumber) {
        try {
            boolean verified = verificationService.isPhoneVerified(phoneNumber);
            return ResponseEntity.ok(ApiResponse.success("휴대폰 인증 상태 조회 성공", verified));
        } catch (Exception e) {
            log.error("휴대폰 인증 상태 확인 오류", e);
            return ResponseEntity.internalServerError()
                .body(ApiResponse.error("서버 오류가 발생했습니다."));
        }
    }

    @Operation(summary = "이메일 인증 상태 확인", description = "이메일 주소의 인증 상태를 확인합니다.")
    @GetMapping("/email/status")
    public ResponseEntity<ApiResponse<Boolean>> getEmailVerificationStatus(@RequestParam String email) {
        try {
            boolean verified = verificationService.isEmailVerified(email);
            return ResponseEntity.ok(ApiResponse.success("이메일 인증 상태 조회 성공", verified));
        } catch (Exception e) {
            log.error("이메일 인증 상태 확인 오류", e);
            return ResponseEntity.internalServerError()
                .body(ApiResponse.error("서버 오류가 발생했습니다."));
        }
    }
}