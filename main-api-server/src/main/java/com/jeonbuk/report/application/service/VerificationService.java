package com.jeonbuk.report.application.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.concurrent.TimeUnit;

/**
 * SMS/Email 인증 서비스
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VerificationService {

    private final RedisTemplate<String, String> redisTemplate;
    private final JavaMailSender mailSender;
    private final WebClient.Builder webClientBuilder;

    @Value("${app.verification.sms.api-key:}")
    private String smsApiKey;

    @Value("${app.verification.sms.sender:010-0000-0000}")
    private String smsSender;

    @Value("${app.verification.email.from:noreply@jeonbuk-report.kr}")
    private String emailFrom;

    @Value("${app.verification.code.length:6}")
    private int codeLength;

    @Value("${app.verification.code.expiry:300}")
    private int codeExpirySeconds;

    private static final String SMS_CODE_PREFIX = "sms_code:";
    private static final String EMAIL_CODE_PREFIX = "email_code:";
    private static final String PHONE_VERIFIED_PREFIX = "phone_verified:";
    private static final String EMAIL_VERIFIED_PREFIX = "email_verified:";

    /**
     * SMS 인증번호 발송
     */
    public boolean sendSmsVerification(String phoneNumber) {
        try {
            String code = generateVerificationCode();
            String key = SMS_CODE_PREFIX + phoneNumber;

            // Redis에 인증번호 저장 (5분 만료)
            redisTemplate.opsForValue().set(key, code, Duration.ofSeconds(codeExpirySeconds));

            // SMS 발송
            boolean sent = sendSms(phoneNumber, code);
            
            if (sent) {
                log.info("SMS 인증번호 발송 성공: {}", phoneNumber);
                return true;
            } else {
                redisTemplate.delete(key);
                log.error("SMS 인증번호 발송 실패: {}", phoneNumber);
                return false;
            }
        } catch (Exception e) {
            log.error("SMS 인증번호 발송 중 오류: {}", phoneNumber, e);
            return false;
        }
    }

    /**
     * Email 인증번호 발송
     */
    public boolean sendEmailVerification(String email) {
        try {
            String code = generateVerificationCode();
            String key = EMAIL_CODE_PREFIX + email;

            // Redis에 인증번호 저장 (5분 만료)
            redisTemplate.opsForValue().set(key, code, Duration.ofSeconds(codeExpirySeconds));

            // Email 발송
            boolean sent = sendEmail(email, code);
            
            if (sent) {
                log.info("Email 인증번호 발송 성공: {}", email);
                return true;
            } else {
                redisTemplate.delete(key);
                log.error("Email 인증번호 발송 실패: {}", email);
                return false;
            }
        } catch (Exception e) {
            log.error("Email 인증번호 발송 중 오류: {}", email, e);
            return false;
        }
    }

    /**
     * SMS 인증번호 확인
     */
    public boolean verifySmsCode(String phoneNumber, String code) {
        try {
            String key = SMS_CODE_PREFIX + phoneNumber;
            String storedCode = redisTemplate.opsForValue().get(key);

            if (storedCode != null && storedCode.equals(code)) {
                // 인증 성공 시 코드 삭제하고 인증 완료 표시
                redisTemplate.delete(key);
                redisTemplate.opsForValue().set(
                    PHONE_VERIFIED_PREFIX + phoneNumber, 
                    "verified", 
                    Duration.ofHours(24) // 24시간 동안 인증 상태 유지
                );
                log.info("SMS 인증 성공: {}", phoneNumber);
                return true;
            }
            log.warn("SMS 인증 실패: {} (잘못된 코드)", phoneNumber);
            return false;
        } catch (Exception e) {
            log.error("SMS 인증 확인 중 오류: {}", phoneNumber, e);
            return false;
        }
    }

    /**
     * Email 인증번호 확인
     */
    public boolean verifyEmailCode(String email, String code) {
        try {
            String key = EMAIL_CODE_PREFIX + email;
            String storedCode = redisTemplate.opsForValue().get(key);

            if (storedCode != null && storedCode.equals(code)) {
                // 인증 성공 시 코드 삭제하고 인증 완료 표시
                redisTemplate.delete(key);
                redisTemplate.opsForValue().set(
                    EMAIL_VERIFIED_PREFIX + email, 
                    "verified", 
                    Duration.ofHours(24) // 24시간 동안 인증 상태 유지
                );
                log.info("Email 인증 성공: {}", email);
                return true;
            }
            log.warn("Email 인증 실패: {} (잘못된 코드)", email);
            return false;
        } catch (Exception e) {
            log.error("Email 인증 확인 중 오류: {}", email, e);
            return false;
        }
    }

    /**
     * 휴대폰 인증 상태 확인
     */
    public boolean isPhoneVerified(String phoneNumber) {
        String verified = redisTemplate.opsForValue().get(PHONE_VERIFIED_PREFIX + phoneNumber);
        return "verified".equals(verified);
    }

    /**
     * 이메일 인증 상태 확인
     */
    public boolean isEmailVerified(String email) {
        String verified = redisTemplate.opsForValue().get(EMAIL_VERIFIED_PREFIX + email);
        return "verified".equals(verified);
    }

    /**
     * 인증번호 생성
     */
    private String generateVerificationCode() {
        SecureRandom random = new SecureRandom();
        StringBuilder code = new StringBuilder();
        
        for (int i = 0; i < codeLength; i++) {
            code.append(random.nextInt(10));
        }
        
        return code.toString();
    }

    /**
     * SMS 발송 (알리고 API 사용 예시)
     */
    private boolean sendSms(String phoneNumber, String code) {
        try {
            if (smsApiKey == null || smsApiKey.isEmpty()) {
                log.warn("SMS API 키가 설정되지 않음. 개발 모드에서는 콘솔에 출력: {} -> {}", phoneNumber, code);
                return true; // 개발 환경에서는 성공으로 처리
            }

            // 알리고 API 호출 예시
            WebClient webClient = webClientBuilder.build();
            
            String response = webClient.post()
                .uri("https://apis.aligo.in/send/")
                .header("Content-Type", "application/x-www-form-urlencoded")
                .bodyValue(String.format(
                    "key=%s&user_id=your_user_id&sender=%s&receiver=%s&msg=[전북신고] 인증번호: %s",
                    smsApiKey, smsSender, phoneNumber, code
                ))
                .retrieve()
                .bodyToMono(String.class)
                .block();

            log.debug("SMS API 응답: {}", response);
            return response != null && response.contains("success");
            
        } catch (Exception e) {
            log.error("SMS 발송 실패", e);
            return false;
        }
    }

    /**
     * Email 발송
     */
    private boolean sendEmail(String email, String code) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(emailFrom);
            message.setTo(email);
            message.setSubject("[전북신고] 이메일 인증번호");
            message.setText(String.format(
                "안녕하세요.\n\n" +
                "전북신고 플랫폼 이메일 인증번호입니다.\n\n" +
                "인증번호: %s\n\n" +
                "5분 내에 입력해주세요.\n\n" +
                "감사합니다.",
                code
            ));

            mailSender.send(message);
            return true;
            
        } catch (Exception e) {
            log.error("Email 발송 실패", e);
            return false;
        }
    }
}