package com.jeonbuk.report.test.stability;

import com.jeonbuk.report.application.service.TokenService;
import com.jeonbuk.report.infrastructure.security.jwt.JwtTokenProvider;
import com.jeonbuk.report.test.stability.StabilityTestFramework.TestReport;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.util.UUID;

/**
 * JWT 토큰 서비스 안정성 테스트
 */
@Slf4j
@SpringBootTest
@TestPropertySource(locations = "classpath:application-test.properties")
@RequiredArgsConstructor
public class JwtTokenServiceStabilityTest {

    private final JwtTokenProvider jwtTokenProvider;
    private final TokenService tokenService;
    private final StabilityTestFramework testFramework;

    @Test
    @DisplayName("JWT 토큰 생성 안정성 테스트 - 순차 5회")
    public void testJwtTokenCreationStability() {
        TestReport report = testFramework.runRepeatedTest(
            "JWT 토큰 서비스",
            "JWT 토큰 생성",
            this::testJwtTokenCreation,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 95% 성공률)
        assert report.getSuccessRate() >= 95.0 : 
            String.format("JWT 토큰 생성 성공률이 95%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("JWT 토큰 검증 안정성 테스트 - 순차 6회")
    public void testJwtTokenValidationStability() {
        TestReport report = testFramework.runRepeatedTest(
            "JWT 토큰 서비스",
            "JWT 토큰 검증",
            this::testJwtTokenValidation,
            6
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 95% 성공률)
        assert report.getSuccessRate() >= 95.0 : 
            String.format("JWT 토큰 검증 성공률이 95%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("Refresh 토큰 관리 안정성 테스트 - 순차 5회")
    public void testRefreshTokenManagementStability() {
        TestReport report = testFramework.runRepeatedTest(
            "JWT 토큰 서비스",
            "Refresh 토큰 관리",
            this::testRefreshTokenManagement,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 90% 성공률)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("Refresh 토큰 관리 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("토큰 블랙리스트 관리 안정성 테스트 - 순차 5회")
    public void testTokenBlacklistStability() {
        TestReport report = testFramework.runRepeatedTest(
            "JWT 토큰 서비스",
            "토큰 블랙리스트 관리",
            this::testTokenBlacklist,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 90% 성공률)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("토큰 블랙리스트 관리 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("JWT 토큰 부하 테스트 - 동시 10회")
    public void testJwtTokenLoadTest() {
        TestReport report = testFramework.runParallelTest(
            "JWT 토큰 서비스",
            "JWT 토큰 생성 (부하)",
            this::testJwtTokenCreation,
            10
        );
        
        testFramework.printReport(report);
        
        // 부하 테스트 검증 (최소 85% 성공률, 평균 응답시간 500ms 이하)
        assert report.getSuccessRate() >= 85.0 : 
            String.format("JWT 부하 테스트 성공률이 85%% 미만입니다: %.2f%%", report.getSuccessRate());
        assert report.getAverageExecutionTime() <= 500 : 
            String.format("JWT 평균 응답시간이 500ms를 초과했습니다: %dms", report.getAverageExecutionTime());
    }

    @Test
    @DisplayName("JWT 토큰 전체 플로우 안정성 테스트 - 순차 7회")
    public void testJwtTokenFullFlowStability() {
        TestReport report = testFramework.runRepeatedTest(
            "JWT 토큰 서비스",
            "JWT 토큰 전체 플로우",
            this::testJwtTokenFullFlow,
            7
        );
        
        testFramework.printReport(report);
        
        // 전체 플로우 안정성 검증 (최소 85% 성공률)
        assert report.getSuccessRate() >= 85.0 : 
            String.format("JWT 전체 플로우 성공률이 85%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    /**
     * JWT 토큰 생성 테스트
     */
    private String testJwtTokenCreation() {
        try {
            String email = generateRandomEmail();
            String accessToken = jwtTokenProvider.createToken(email);
            
            if (accessToken == null || accessToken.trim().isEmpty()) {
                throw new RuntimeException("Access 토큰이 생성되지 않았습니다");
            }
            
            // JWT 형식 검증 (3개 부분으로 구성: header.payload.signature)
            String[] parts = accessToken.split("\\.");
            if (parts.length != 3) {
                throw new RuntimeException("JWT 토큰 형식이 올바르지 않습니다: " + parts.length + "개 부분");
            }
            
            // 토큰에서 사용자 정보 추출 테스트
            String extractedEmail = jwtTokenProvider.getUsername(accessToken);
            if (!email.equals(extractedEmail)) {
                throw new RuntimeException("토큰에서 추출한 이메일이 일치하지 않습니다");
            }
            
            log.info("JWT 토큰 생성 성공: {} -> {}", email, accessToken.substring(0, 20) + "...");
            return accessToken;
            
        } catch (Exception e) {
            throw new RuntimeException("JWT 토큰 생성 실패: " + e.getMessage());
        }
    }

    /**
     * JWT 토큰 검증 테스트
     */
    private Boolean testJwtTokenValidation() {
        try {
            String email = generateRandomEmail();
            
            // 1. 유효한 토큰 생성
            String validToken = jwtTokenProvider.createToken(email);
            
            // 2. 유효한 토큰 검증
            boolean isValid = jwtTokenProvider.validateToken(validToken);
            if (!isValid) {
                throw new RuntimeException("유효한 토큰이 유효하지 않다고 판단됨");
            }
            
            // 3. 잘못된 토큰 검증
            String invalidToken = "invalid.jwt.token";
            boolean isInvalid = jwtTokenProvider.validateToken(invalidToken);
            if (isInvalid) {
                throw new RuntimeException("잘못된 토큰이 유효하다고 판단됨");
            }
            
            // 4. 토큰 만료 확인 (실제로는 별도 테스트에서 수행)
            
            log.info("JWT 토큰 검증 테스트 성공: {}", email);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("JWT 토큰 검증 실패: " + e.getMessage());
        }
    }

    /**
     * Refresh 토큰 관리 테스트
     */
    private Boolean testRefreshTokenManagement() {
        try {
            String email = generateRandomEmail();
            
            // 1. Refresh 토큰 생성
            String refreshToken = jwtTokenProvider.createRefreshToken(email);
            if (refreshToken == null || refreshToken.trim().isEmpty()) {
                throw new RuntimeException("Refresh 토큰이 생성되지 않았습니다");
            }
            
            // 2. Refresh 토큰 저장
            tokenService.saveRefreshToken(email, refreshToken);
            
            // 3. Refresh 토큰 검증
            boolean isValidRefresh = tokenService.isValidRefreshToken(email, refreshToken);
            if (!isValidRefresh) {
                throw new RuntimeException("저장된 Refresh 토큰이 유효하지 않음");
            }
            
            // 4. 잘못된 Refresh 토큰 검증
            String wrongToken = jwtTokenProvider.createRefreshToken("wrong@email.com");
            boolean isWrongTokenValid = tokenService.isValidRefreshToken(email, wrongToken);
            if (isWrongTokenValid) {
                throw new RuntimeException("잘못된 Refresh 토큰이 유효하다고 판단됨");
            }
            
            // 5. Refresh 토큰 삭제
            tokenService.deleteRefreshToken(email);
            
            // 6. 삭제 후 검증
            boolean isDeletedTokenValid = tokenService.isValidRefreshToken(email, refreshToken);
            if (isDeletedTokenValid) {
                throw new RuntimeException("삭제된 Refresh 토큰이 여전히 유효함");
            }
            
            log.info("Refresh 토큰 관리 테스트 성공: {}", email);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("Refresh 토큰 관리 실패: " + e.getMessage());
        }
    }

    /**
     * 토큰 블랙리스트 테스트
     */
    private Boolean testTokenBlacklist() {
        try {
            String email = generateRandomEmail();
            String accessToken = jwtTokenProvider.createToken(email);
            
            // 1. 초기 상태 확인 (블랙리스트에 없음)
            boolean isInitiallyBlacklisted = tokenService.isBlacklisted(accessToken);
            if (isInitiallyBlacklisted) {
                throw new RuntimeException("새로 생성된 토큰이 이미 블랙리스트에 있음");
            }
            
            // 2. 블랙리스트에 추가
            tokenService.addToBlacklist(accessToken);
            
            // 3. 블랙리스트 확인
            boolean isBlacklisted = tokenService.isBlacklisted(accessToken);
            if (!isBlacklisted) {
                throw new RuntimeException("블랙리스트에 추가된 토큰이 블랙리스트에 없음");
            }
            
            // 4. 다른 토큰은 블랙리스트에 없어야 함
            String anotherToken = jwtTokenProvider.createToken("another@email.com");
            boolean isAnotherBlacklisted = tokenService.isBlacklisted(anotherToken);
            if (isAnotherBlacklisted) {
                throw new RuntimeException("다른 토큰이 블랙리스트에 있음");
            }
            
            log.info("토큰 블랙리스트 테스트 성공: {}", email);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("토큰 블랙리스트 실패: " + e.getMessage());
        }
    }

    /**
     * JWT 토큰 전체 플로우 테스트
     */
    private Boolean testJwtTokenFullFlow() {
        try {
            String email = generateRandomEmail();
            
            // 1. Access 토큰 생성
            String accessToken = jwtTokenProvider.createToken(email);
            String refreshToken = jwtTokenProvider.createRefreshToken(email);
            
            // 2. 토큰 검증
            boolean isAccessValid = jwtTokenProvider.validateToken(accessToken);
            boolean isRefreshValid = jwtTokenProvider.validateToken(refreshToken);
            
            if (!isAccessValid || !isRefreshValid) {
                throw new RuntimeException("생성된 토큰이 유효하지 않음");
            }
            
            // 3. Refresh 토큰 저장
            tokenService.saveRefreshToken(email, refreshToken);
            
            // 4. 토큰 갱신 시뮬레이션
            String newAccessToken = jwtTokenProvider.createToken(email);
            String newRefreshToken = jwtTokenProvider.createRefreshToken(email);
            
            // 5. 기존 토큰 무효화
            tokenService.deleteRefreshToken(email);
            tokenService.addToBlacklist(accessToken);
            
            // 6. 새 토큰 저장
            tokenService.saveRefreshToken(email, newRefreshToken);
            
            // 7. 상태 확인
            boolean isOldTokenBlacklisted = tokenService.isBlacklisted(accessToken);
            boolean isOldRefreshValid = tokenService.isValidRefreshToken(email, refreshToken);
            boolean isNewRefreshValid = tokenService.isValidRefreshToken(email, newRefreshToken);
            
            if (!isOldTokenBlacklisted) {
                throw new RuntimeException("기존 Access 토큰이 블랙리스트에 없음");
            }
            
            if (isOldRefreshValid) {
                throw new RuntimeException("기존 Refresh 토큰이 여전히 유효함");
            }
            
            if (!isNewRefreshValid) {
                throw new RuntimeException("새 Refresh 토큰이 유효하지 않음");
            }
            
            // 8. 정리
            tokenService.invalidateAllTokens(email);
            
            log.info("JWT 전체 플로우 테스트 성공: {}", email);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("JWT 전체 플로우 실패: " + e.getMessage());
        }
    }

    /**
     * 랜덤 이메일 생성
     */
    private String generateRandomEmail() {
        return "test-" + UUID.randomUUID().toString().substring(0, 8) + "@test.com";
    }
}