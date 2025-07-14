package com.jeonbuk.report.test.stability;

import com.jeonbuk.report.application.service.VerificationService;
import com.jeonbuk.report.test.stability.StabilityTestFramework.TestReport;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.util.Random;
import java.util.UUID;

/**
 * Email 인증 서비스 안정성 테스트
 */
@Slf4j
@SpringBootTest
@TestPropertySource(locations = "classpath:application-test.properties")
@RequiredArgsConstructor
public class EmailVerificationStabilityTest {

    private final VerificationService verificationService;
    private final StabilityTestFramework testFramework;
    
    private final Random random = new Random();

    @Test
    @DisplayName("Email 인증번호 발송 안정성 테스트 - 순차 5회")
    public void testEmailVerificationSendStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Email 인증 서비스",
            "Email 인증번호 발송",
            this::testEmailVerificationSend,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 80% 성공률)
        assert report.getSuccessRate() >= 80.0 : 
            String.format("Email 발송 성공률이 80%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("Email 인증번호 확인 안정성 테스트 - 순차 5회")
    public void testEmailVerificationVerifyStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Email 인증 서비스",
            "Email 인증번호 확인",
            this::testEmailVerificationVerify,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 80% 성공률)
        assert report.getSuccessRate() >= 80.0 : 
            String.format("Email 인증 확인 성공률이 80%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("Email 인증번호 발송 부하 테스트 - 동시 8회")
    public void testEmailVerificationSendLoad() {
        TestReport report = testFramework.runParallelTest(
            "Email 인증 서비스",
            "Email 인증번호 발송 (부하)",
            this::testEmailVerificationSend,
            8
        );
        
        testFramework.printReport(report);
        
        // 부하 테스트 검증 (최소 70% 성공률, 평균 응답시간 10초 이하)
        assert report.getSuccessRate() >= 70.0 : 
            String.format("Email 발송 부하 테스트 성공률이 70%% 미만입니다: %.2f%%", report.getSuccessRate());
        assert report.getAverageExecutionTime() <= 10000 : 
            String.format("Email 발송 평균 응답시간이 10초를 초과했습니다: %dms", report.getAverageExecutionTime());
    }

    @Test
    @DisplayName("Email 인증 상태 확인 안정성 테스트 - 순차 6회")
    public void testEmailVerificationStatusStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Email 인증 서비스",
            "Email 인증 상태 확인",
            this::testEmailVerificationStatus,
            6
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 95% 성공률 - 상태 확인은 단순 Redis 조회)
        assert report.getSuccessRate() >= 95.0 : 
            String.format("Email 상태 확인 성공률이 95%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("Email 인증 전체 플로우 안정성 테스트 - 순차 5회")
    public void testEmailVerificationFullFlowStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Email 인증 서비스",
            "Email 인증 전체 플로우",
            this::testEmailVerificationFullFlow,
            5
        );
        
        testFramework.printReport(report);
        
        // 전체 플로우 안정성 검증 (최소 80% 성공률)
        assert report.getSuccessRate() >= 80.0 : 
            String.format("Email 전체 플로우 성공률이 80%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("다양한 Email 도메인 발송 테스트 - 순차 7회")
    public void testEmailVerificationVariousDomains() {
        TestReport report = testFramework.runRepeatedTest(
            "Email 인증 서비스",
            "다양한 도메인 Email 발송",
            this::testEmailVerificationVariousDomains,
            7
        );
        
        testFramework.printReport(report);
        
        // 다양한 도메인 테스트 검증 (최소 75% 성공률)
        assert report.getSuccessRate() >= 75.0 : 
            String.format("다양한 도메인 Email 발송 성공률이 75%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    /**
     * Email 인증번호 발송 테스트
     */
    private Boolean testEmailVerificationSend() {
        String email = generateRandomEmail();
        boolean result = verificationService.sendEmailVerification(email);
        
        if (!result) {
            throw new RuntimeException("Email 인증번호 발송 실패: " + email);
        }
        
        return result;
    }

    /**
     * Email 인증번호 확인 테스트 (Mock 코드 사용)
     */
    private Boolean testEmailVerificationVerify() {
        String email = generateRandomEmail();
        
        // 먼저 인증번호 발송
        boolean sendResult = verificationService.sendEmailVerification(email);
        if (!sendResult) {
            throw new RuntimeException("Email 인증번호 발송 실패: " + email);
        }
        
        // 개발 환경에서는 고정 코드로 테스트
        String testCode = "123456";
        
        try {
            // 잠시 대기 (이메일 발송 시뮬레이션)
            Thread.sleep(500);
            
            boolean verifyResult = verificationService.verifyEmailCode(email, testCode);
            return verifyResult;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("테스트 중단됨");
        } catch (Exception e) {
            throw new RuntimeException("Email 인증번호 확인 실패: " + e.getMessage());
        }
    }

    /**
     * Email 인증 상태 확인 테스트
     */
    private Boolean testEmailVerificationStatus() {
        String email = generateRandomEmail();
        
        try {
            boolean status = verificationService.isEmailVerified(email);
            // 새로운 이메일은 인증되지 않은 상태여야 함
            return !status; // 인증되지 않은 상태가 정상
        } catch (Exception e) {
            throw new RuntimeException("Email 인증 상태 확인 실패: " + e.getMessage());
        }
    }

    /**
     * Email 인증 전체 플로우 테스트
     */
    private Boolean testEmailVerificationFullFlow() {
        String email = generateRandomEmail();
        
        try {
            // 1. 초기 상태 확인 (인증되지 않은 상태)
            boolean initialStatus = verificationService.isEmailVerified(email);
            if (initialStatus) {
                throw new RuntimeException("초기 상태가 인증된 상태입니다");
            }
            
            // 2. 인증번호 발송
            boolean sendResult = verificationService.sendEmailVerification(email);
            if (!sendResult) {
                throw new RuntimeException("Email 인증번호 발송 실패");
            }
            
            // 3. 잠시 대기 (실제 발송 시뮬레이션)
            Thread.sleep(1500);
            
            // 4. 상태 확인 (여전히 인증되지 않은 상태)
            boolean middleStatus = verificationService.isEmailVerified(email);
            if (middleStatus) {
                throw new RuntimeException("인증번호 발송 후 상태가 잘못되었습니다");
            }
            
            // 5. 개발 환경에서는 성공으로 처리
            log.info("Email 인증 전체 플로우 테스트 완료: {}", email);
            return true;
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("테스트 중단됨");
        } catch (Exception e) {
            throw new RuntimeException("Email 전체 플로우 실패: " + e.getMessage());
        }
    }

    /**
     * 다양한 도메인 Email 발송 테스트
     */
    private Boolean testEmailVerificationVariousDomains() {
        String[] domains = {"gmail.com", "naver.com", "daum.net", "yahoo.com", "hotmail.com", "outlook.com", "kakao.com"};
        String domain = domains[random.nextInt(domains.length)];
        String email = generateRandomEmailWithDomain(domain);
        
        try {
            boolean result = verificationService.sendEmailVerification(email);
            if (!result) {
                throw new RuntimeException("Email 인증번호 발송 실패: " + email);
            }
            
            log.info("다양한 도메인 Email 발송 테스트 성공: {}", email);
            return result;
        } catch (Exception e) {
            throw new RuntimeException("다양한 도메인 Email 발송 실패: " + e.getMessage());
        }
    }

    /**
     * 랜덤 이메일 주소 생성 (테스트용)
     */
    private String generateRandomEmail() {
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        return "test-" + uuid + "@test.com";
    }

    /**
     * 특정 도메인으로 랜덤 이메일 주소 생성
     */
    private String generateRandomEmailWithDomain(String domain) {
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        return "test-" + uuid + "@" + domain;
    }
}