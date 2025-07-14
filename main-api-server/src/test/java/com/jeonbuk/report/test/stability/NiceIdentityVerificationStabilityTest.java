package com.jeonbuk.report.test.stability;

import com.jeonbuk.report.application.service.NiceIdentityVerificationService;
import com.jeonbuk.report.test.stability.StabilityTestFramework.TestReport;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.util.Map;
import java.util.Random;

/**
 * NICE 실명인증 서비스 안정성 테스트
 */
@Slf4j
@SpringBootTest
@TestPropertySource(locations = "classpath:application-test.properties")
@RequiredArgsConstructor
public class NiceIdentityVerificationStabilityTest {

    private final NiceIdentityVerificationService niceVerificationService;
    private final StabilityTestFramework testFramework;
    
    private final Random random = new Random();

    @Test
    @DisplayName("NICE 인증 요청 생성 안정성 테스트 - 순차 5회")
    public void testNiceVerificationRequestStability() {
        TestReport report = testFramework.runRepeatedTest(
            "NICE 실명인증 서비스",
            "NICE 인증 요청 생성",
            this::testNiceVerificationRequest,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 90% 성공률 - 로컬 처리)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("NICE 인증 요청 생성 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("NICE 인증 상태 확인 안정성 테스트 - 순차 6회")
    public void testNiceVerificationStatusStability() {
        TestReport report = testFramework.runRepeatedTest(
            "NICE 실명인증 서비스",
            "NICE 인증 상태 확인",
            this::testNiceVerificationStatus,
            6
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 95% 성공률 - Redis 조회)
        assert report.getSuccessRate() >= 95.0 : 
            String.format("NICE 인증 상태 확인 성공률이 95%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("NICE 인증 결과 처리 안정성 테스트 - 순차 5회")
    public void testNiceVerificationProcessStability() {
        TestReport report = testFramework.runRepeatedTest(
            "NICE 실명인증 서비스",
            "NICE 인증 결과 처리",
            this::testNiceVerificationProcess,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 85% 성공률)
        assert report.getSuccessRate() >= 85.0 : 
            String.format("NICE 인증 결과 처리 성공률이 85%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("NICE 인증 전체 플로우 안정성 테스트 - 순차 5회")
    public void testNiceVerificationFullFlowStability() {
        TestReport report = testFramework.runRepeatedTest(
            "NICE 실명인증 서비스",
            "NICE 인증 전체 플로우",
            this::testNiceVerificationFullFlow,
            5
        );
        
        testFramework.printReport(report);
        
        // 전체 플로우 안정성 검증 (최소 80% 성공률)
        assert report.getSuccessRate() >= 80.0 : 
            String.format("NICE 전체 플로우 성공률이 80%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("NICE 인증 부하 테스트 - 동시 5회")
    public void testNiceVerificationLoadTest() {
        TestReport report = testFramework.runParallelTest(
            "NICE 실명인증 서비스",
            "NICE 인증 요청 생성 (부하)",
            this::testNiceVerificationRequest,
            5
        );
        
        testFramework.printReport(report);
        
        // 부하 테스트 검증 (최소 75% 성공률, 평균 응답시간 3초 이하)
        assert report.getSuccessRate() >= 75.0 : 
            String.format("NICE 부하 테스트 성공률이 75%% 미만입니다: %.2f%%", report.getSuccessRate());
        assert report.getAverageExecutionTime() <= 3000 : 
            String.format("NICE 평균 응답시간이 3초를 초과했습니다: %dms", report.getAverageExecutionTime());
    }

    @Test
    @DisplayName("NICE 암호화/복호화 안정성 테스트 - 순차 7회")
    public void testNiceEncryptionStability() {
        TestReport report = testFramework.runRepeatedTest(
            "NICE 실명인증 서비스",
            "NICE 암호화/복호화",
            this::testNiceEncryption,
            7
        );
        
        testFramework.printReport(report);
        
        // 암호화/복호화 안정성 검증 (최소 95% 성공률)
        assert report.getSuccessRate() >= 95.0 : 
            String.format("NICE 암호화/복호화 성공률이 95%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    /**
     * NICE 인증 요청 생성 테스트
     */
    private Map<String, String> testNiceVerificationRequest() {
        try {
            Map<String, String> request = niceVerificationService.createVerificationRequest();
            
            // 필수 필드 검증
            if (!request.containsKey("requestToken") || 
                !request.containsKey("encData") || 
                !request.containsKey("integrityValue") || 
                !request.containsKey("niceUrl")) {
                throw new RuntimeException("NICE 인증 요청 응답에 필수 필드가 누락되었습니다");
            }
            
            // 토큰 형식 검증
            String requestToken = request.get("requestToken");
            if (requestToken == null || requestToken.trim().isEmpty()) {
                throw new RuntimeException("요청 토큰이 비어있습니다");
            }
            
            log.info("NICE 인증 요청 생성 성공: {}", requestToken);
            return request;
            
        } catch (Exception e) {
            throw new RuntimeException("NICE 인증 요청 생성 실패: " + e.getMessage());
        }
    }

    /**
     * NICE 인증 상태 확인 테스트
     */
    private String testNiceVerificationStatus() {
        try {
            // 먼저 인증 요청 생성
            Map<String, String> request = niceVerificationService.createVerificationRequest();
            String requestToken = request.get("requestToken");
            
            // 상태 확인
            String status = niceVerificationService.getVerificationStatus(requestToken);
            
            // 새로 생성된 토큰은 'pending' 상태여야 함
            if (!"pending".equals(status)) {
                throw new RuntimeException("새로 생성된 토큰의 상태가 'pending'이 아닙니다: " + status);
            }
            
            log.info("NICE 인증 상태 확인 성공: {} -> {}", requestToken, status);
            return status;
            
        } catch (Exception e) {
            throw new RuntimeException("NICE 인증 상태 확인 실패: " + e.getMessage());
        }
    }

    /**
     * NICE 인증 결과 처리 테스트 (Mock 데이터 사용)
     */
    private Map<String, Object> testNiceVerificationProcess() {
        try {
            // 먼저 인증 요청 생성
            Map<String, String> request = niceVerificationService.createVerificationRequest();
            String requestToken = request.get("requestToken");
            
            // Mock 암호화 데이터 생성 (실제 환경에서는 NICE에서 전달받는 데이터)
            String mockEncData = "mock_encrypted_data_" + System.currentTimeMillis();
            
            // 인증 결과 처리
            Map<String, Object> result = niceVerificationService.processVerificationResult(requestToken, mockEncData);
            
            // 필수 필드 검증
            if (!result.containsKey("name") || 
                !result.containsKey("birthday") || 
                !result.containsKey("gender") || 
                !result.containsKey("phoneNumber")) {
                throw new RuntimeException("NICE 인증 결과에 필수 필드가 누락되었습니다");
            }
            
            log.info("NICE 인증 결과 처리 성공: {} -> {}", requestToken, result.get("name"));
            return result;
            
        } catch (Exception e) {
            throw new RuntimeException("NICE 인증 결과 처리 실패: " + e.getMessage());
        }
    }

    /**
     * NICE 인증 전체 플로우 테스트
     */
    private Boolean testNiceVerificationFullFlow() {
        try {
            // 1. 인증 요청 생성
            Map<String, String> request = niceVerificationService.createVerificationRequest();
            String requestToken = request.get("requestToken");
            
            // 2. 초기 상태 확인
            String initialStatus = niceVerificationService.getVerificationStatus(requestToken);
            if (!"pending".equals(initialStatus)) {
                throw new RuntimeException("초기 상태가 'pending'이 아닙니다: " + initialStatus);
            }
            
            // 3. 잠시 대기 (실제 인증 프로세스 시뮬레이션)
            Thread.sleep(1000);
            
            // 4. Mock 데이터로 인증 결과 처리
            String mockEncData = "mock_encrypted_data_" + System.currentTimeMillis();
            Map<String, Object> result = niceVerificationService.processVerificationResult(requestToken, mockEncData);
            
            // 5. 최종 상태 확인
            String finalStatus = niceVerificationService.getVerificationStatus(requestToken);
            if (!"completed".equals(finalStatus)) {
                throw new RuntimeException("최종 상태가 'completed'가 아닙니다: " + finalStatus);
            }
            
            // 6. 인증 결과 조회
            Map<String, Object> storedResult = niceVerificationService.getVerificationResult(requestToken);
            if (storedResult == null) {
                throw new RuntimeException("저장된 인증 결과를 찾을 수 없습니다");
            }
            
            log.info("NICE 전체 플로우 테스트 완료: {} -> {}", requestToken, result.get("name"));
            return true;
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("테스트 중단됨");
        } catch (Exception e) {
            throw new RuntimeException("NICE 전체 플로우 실패: " + e.getMessage());
        }
    }

    /**
     * NICE 암호화/복호화 테스트
     */
    private Boolean testNiceEncryption() {
        try {
            // 암호화 테스트를 위한 요청 생성
            Map<String, String> request = niceVerificationService.createVerificationRequest();
            
            // encData와 integrityValue가 올바르게 생성되었는지 확인
            String encData = request.get("encData");
            String integrityValue = request.get("integrityValue");
            
            if (encData == null || encData.trim().isEmpty()) {
                throw new RuntimeException("암호화 데이터가 생성되지 않았습니다");
            }
            
            if (integrityValue == null || integrityValue.trim().isEmpty()) {
                throw new RuntimeException("무결성 값이 생성되지 않았습니다");
            }
            
            // 암호화 데이터 형식 검증 (예시)
            if (!encData.startsWith("encrypted_")) {
                throw new RuntimeException("암호화 데이터 형식이 올바르지 않습니다");
            }
            
            // 무결성 값 길이 검증 (SHA-256 해시는 64자)
            if (integrityValue.length() != 64) {
                throw new RuntimeException("무결성 값 길이가 올바르지 않습니다: " + integrityValue.length());
            }
            
            log.info("NICE 암호화/복호화 테스트 성공: encData={}, integrity={}", 
                    encData.substring(0, Math.min(20, encData.length())), 
                    integrityValue.substring(0, 16));
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("NICE 암호화/복호화 실패: " + e.getMessage());
        }
    }
}