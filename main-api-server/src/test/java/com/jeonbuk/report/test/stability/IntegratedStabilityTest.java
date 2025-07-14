package com.jeonbuk.report.test.stability;

import com.jeonbuk.report.test.stability.StabilityTestFramework.TestReport;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * 전체 시스템 안정성 통합 테스트
 */
@Slf4j
@SpringBootTest
@TestPropertySource(locations = "classpath:application-test.properties")
@RequiredArgsConstructor
public class IntegratedStabilityTest {

    private final StabilityTestFramework testFramework;
    private final SmsVerificationStabilityTest smsTest;
    private final EmailVerificationStabilityTest emailTest;
    private final NiceIdentityVerificationStabilityTest niceTest;
    private final JwtTokenServiceStabilityTest jwtTest;
    private final UserServiceStabilityTest userTest;
    private final RedisServiceStabilityTest redisTest;

    @Test
    @DisplayName("전체 시스템 안정성 종합 테스트")
    public void runComprehensiveStabilityTest() {
        log.info("\n" +
            "=================================================================\n" +
            "       전북신고 플랫폼 시스템 안정성 종합 테스트 시작\n" +
            "=================================================================");

        LocalDateTime testStartTime = LocalDateTime.now();
        List<TestReport> allReports = new ArrayList<>();
        List<String> failedServices = new ArrayList<>();

        try {
            // 1. Redis 서비스 테스트 (기반 인프라)
            log.info("\n[1/6] Redis 서비스 안정성 테스트 실행 중...");
            try {
                TestReport redisReport = runRedisStabilityTests();
                allReports.add(redisReport);
                if (redisReport.getSuccessRate() < 90.0) {
                    failedServices.add("Redis 서비스");
                }
            } catch (Exception e) {
                log.error("Redis 서비스 테스트 실행 실패", e);
                failedServices.add("Redis 서비스 (실행 실패)");
            }

            // 2. JWT 토큰 서비스 테스트
            log.info("\n[2/6] JWT 토큰 서비스 안정성 테스트 실행 중...");
            try {
                TestReport jwtReport = runJwtStabilityTests();
                allReports.add(jwtReport);
                if (jwtReport.getSuccessRate() < 90.0) {
                    failedServices.add("JWT 토큰 서비스");
                }
            } catch (Exception e) {
                log.error("JWT 토큰 서비스 테스트 실행 실패", e);
                failedServices.add("JWT 토큰 서비스 (실행 실패)");
            }

            // 3. 사용자 서비스 테스트
            log.info("\n[3/6] 사용자 서비스 안정성 테스트 실행 중...");
            try {
                TestReport userReport = runUserStabilityTests();
                allReports.add(userReport);
                if (userReport.getSuccessRate() < 85.0) {
                    failedServices.add("사용자 서비스");
                }
            } catch (Exception e) {
                log.error("사용자 서비스 테스트 실행 실패", e);
                failedServices.add("사용자 서비스 (실행 실패)");
            }

            // 4. SMS 인증 서비스 테스트
            log.info("\n[4/6] SMS 인증 서비스 안정성 테스트 실행 중...");
            try {
                TestReport smsReport = runSmsStabilityTests();
                allReports.add(smsReport);
                if (smsReport.getSuccessRate() < 80.0) {
                    failedServices.add("SMS 인증 서비스");
                }
            } catch (Exception e) {
                log.error("SMS 인증 서비스 테스트 실행 실패", e);
                failedServices.add("SMS 인증 서비스 (실행 실패)");
            }

            // 5. Email 인증 서비스 테스트
            log.info("\n[5/6] Email 인증 서비스 안정성 테스트 실행 중...");
            try {
                TestReport emailReport = runEmailStabilityTests();
                allReports.add(emailReport);
                if (emailReport.getSuccessRate() < 80.0) {
                    failedServices.add("Email 인증 서비스");
                }
            } catch (Exception e) {
                log.error("Email 인증 서비스 테스트 실행 실패", e);
                failedServices.add("Email 인증 서비스 (실행 실패)");
            }

            // 6. NICE 실명인증 서비스 테스트
            log.info("\n[6/6] NICE 실명인증 서비스 안정성 테스트 실행 중...");
            try {
                TestReport niceReport = runNiceStabilityTests();
                allReports.add(niceReport);
                if (niceReport.getSuccessRate() < 85.0) {
                    failedServices.add("NICE 실명인증 서비스");
                }
            } catch (Exception e) {
                log.error("NICE 실명인증 서비스 테스트 실행 실패", e);
                failedServices.add("NICE 실명인증 서비스 (실행 실패)");
            }

        } finally {
            LocalDateTime testEndTime = LocalDateTime.now();
            
            // 종합 결과 출력
            printComprehensiveReport(allReports, failedServices, testStartTime, testEndTime);
            
            // 테스트 결과 검증
            if (!failedServices.isEmpty()) {
                String failedList = String.join(", ", failedServices);
                throw new AssertionError("다음 서비스들이 안정성 기준을 충족하지 못했습니다: " + failedList);
            }
        }
    }

    /**
     * Redis 서비스 안정성 테스트 실행
     */
    private TestReport runRedisStabilityTests() {
        List<TestReport> redisReports = new ArrayList<>();
        
        // Redis 기본 연결 및 CRUD 테스트 (총 11회)
        redisReports.add(testFramework.runRepeatedTest("Redis", "연결", 
            () -> redisTest.testRedisConnection(), 5));
        redisReports.add(testFramework.runRepeatedTest("Redis", "기본 CRUD", 
            () -> redisTest.testRedisCrud(), 6));
        
        return combineReports("Redis 서비스", redisReports);
    }

    /**
     * JWT 토큰 서비스 안정성 테스트 실행
     */
    private TestReport runJwtStabilityTests() {
        List<TestReport> jwtReports = new ArrayList<>();
        
        // JWT 토큰 생성, 검증, 관리 테스트 (총 18회)
        jwtReports.add(testFramework.runRepeatedTest("JWT", "토큰 생성", 
            () -> jwtTest.testJwtTokenCreation(), 5));
        jwtReports.add(testFramework.runRepeatedTest("JWT", "토큰 검증", 
            () -> jwtTest.testJwtTokenValidation(), 6));
        jwtReports.add(testFramework.runRepeatedTest("JWT", "Refresh 토큰 관리", 
            () -> jwtTest.testRefreshTokenManagement(), 7));
        
        return combineReports("JWT 토큰 서비스", jwtReports);
    }

    /**
     * 사용자 서비스 안정성 테스트 실행
     */
    private TestReport runUserStabilityTests() {
        List<TestReport> userReports = new ArrayList<>();
        
        // 사용자 회원가입, 로그인, 관리 테스트 (총 26회)
        userReports.add(testFramework.runRepeatedTest("사용자", "회원가입", 
            () -> userTest.testUserRegistration(), 5));
        userReports.add(testFramework.runRepeatedTest("사용자", "로그인", 
            () -> userTest.testUserLogin(), 6));
        userReports.add(testFramework.runRepeatedTest("사용자", "정보 조회", 
            () -> userTest.testUserFind(), 7));
        userReports.add(testFramework.runRepeatedTest("사용자", "정보 업데이트", 
            () -> userTest.testUserUpdate(), 8));
        
        return combineReports("사용자 서비스", userReports);
    }

    /**
     * SMS 인증 서비스 안정성 테스트 실행
     */
    private TestReport runSmsStabilityTests() {
        List<TestReport> smsReports = new ArrayList<>();
        
        // SMS 인증 발송, 확인, 상태 관리 테스트 (총 22회)
        smsReports.add(testFramework.runRepeatedTest("SMS", "인증번호 발송", 
            () -> smsTest.testSmsVerificationSend(), 5));
        smsReports.add(testFramework.runRepeatedTest("SMS", "인증번호 확인", 
            () -> smsTest.testSmsVerificationVerify(), 5));
        smsReports.add(testFramework.runRepeatedTest("SMS", "인증 상태 확인", 
            () -> smsTest.testSmsVerificationStatus(), 7));
        smsReports.add(testFramework.runRepeatedTest("SMS", "전체 플로우", 
            () -> smsTest.testSmsVerificationFullFlow(), 5));
        
        return combineReports("SMS 인증 서비스", smsReports);
    }

    /**
     * Email 인증 서비스 안정성 테스트 실행
     */
    private TestReport runEmailStabilityTests() {
        List<TestReport> emailReports = new ArrayList<>();
        
        // Email 인증 발송, 확인, 상태 관리 테스트 (총 28회)
        emailReports.add(testFramework.runRepeatedTest("Email", "인증번호 발송", 
            () -> emailTest.testEmailVerificationSend(), 5));
        emailReports.add(testFramework.runRepeatedTest("Email", "인증번호 확인", 
            () -> emailTest.testEmailVerificationVerify(), 5));
        emailReports.add(testFramework.runRepeatedTest("Email", "인증 상태 확인", 
            () -> emailTest.testEmailVerificationStatus(), 6));
        emailReports.add(testFramework.runRepeatedTest("Email", "전체 플로우", 
            () -> emailTest.testEmailVerificationFullFlow(), 5));
        emailReports.add(testFramework.runRepeatedTest("Email", "다양한 도메인", 
            () -> emailTest.testEmailVerificationVariousDomains(), 7));
        
        return combineReports("Email 인증 서비스", emailReports);
    }

    /**
     * NICE 실명인증 서비스 안정성 테스트 실행
     */
    private TestReport runNiceStabilityTests() {
        List<TestReport> niceReports = new ArrayList<>();
        
        // NICE 실명인증 요청, 처리, 암호화 테스트 (총 28회)
        niceReports.add(testFramework.runRepeatedTest("NICE", "인증 요청 생성", 
            () -> niceTest.testNiceVerificationRequest(), 5));
        niceReports.add(testFramework.runRepeatedTest("NICE", "인증 상태 확인", 
            () -> niceTest.testNiceVerificationStatus(), 6));
        niceReports.add(testFramework.runRepeatedTest("NICE", "인증 결과 처리", 
            () -> niceTest.testNiceVerificationProcess(), 5));
        niceReports.add(testFramework.runRepeatedTest("NICE", "전체 플로우", 
            () -> niceTest.testNiceVerificationFullFlow(), 5));
        niceReports.add(testFramework.runRepeatedTest("NICE", "암호화/복호화", 
            () -> niceTest.testNiceEncryption(), 7));
        
        return combineReports("NICE 실명인증 서비스", niceReports);
    }

    /**
     * 여러 테스트 보고서를 하나로 결합
     */
    private TestReport combineReports(String serviceName, List<TestReport> reports) {
        if (reports.isEmpty()) {
            throw new IllegalArgumentException("결합할 보고서가 없습니다");
        }

        TestReport combined = new TestReport();
        combined.setServiceName(serviceName);
        combined.setTestStartTime(reports.get(0).getTestStartTime());
        combined.setTestEndTime(reports.get(reports.size() - 1).getTestEndTime());

        int totalTests = 0;
        int successfulTests = 0;
        int failedTests = 0;
        long totalExecutionTime = 0;
        long minExecutionTime = Long.MAX_VALUE;
        long maxExecutionTime = 0;
        List<com.jeonbuk.report.test.stability.StabilityTestFramework.TestResult> allResults = new ArrayList<>();

        for (TestReport report : reports) {
            totalTests += report.getTotalTests();
            successfulTests += report.getSuccessfulTests();
            failedTests += report.getFailedTests();
            totalExecutionTime += report.getTotalExecutionTime();
            
            if (report.getMinExecutionTime() < minExecutionTime) {
                minExecutionTime = report.getMinExecutionTime();
            }
            if (report.getMaxExecutionTime() > maxExecutionTime) {
                maxExecutionTime = report.getMaxExecutionTime();
            }
            
            allResults.addAll(report.getResults());
        }

        combined.setTotalTests(totalTests);
        combined.setSuccessfulTests(successfulTests);
        combined.setFailedTests(failedTests);
        combined.setSuccessRate(totalTests > 0 ? (double) successfulTests / totalTests * 100 : 0);
        combined.setTotalExecutionTime(totalExecutionTime);
        combined.setMinExecutionTime(minExecutionTime == Long.MAX_VALUE ? 0 : minExecutionTime);
        combined.setMaxExecutionTime(maxExecutionTime);
        combined.setAverageExecutionTime(
            allResults.isEmpty() ? 0 : 
            (long) allResults.stream().mapToLong(r -> r.getExecutionTimeMs()).average().orElse(0)
        );
        combined.setResults(allResults);

        return combined;
    }

    /**
     * 종합 결과 보고서 출력
     */
    private void printComprehensiveReport(List<TestReport> allReports, List<String> failedServices,
                                        LocalDateTime startTime, LocalDateTime endTime) {
        
        log.info("\n" +
            "=================================================================\n" +
            "           전북신고 플랫폼 시스템 안정성 종합 결과\n" +
            "=================================================================");

        log.info("테스트 기간: {} ~ {}", 
                startTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")),
                endTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        int totalAllTests = 0;
        int totalAllSuccess = 0;
        long totalAllTime = 0;

        log.info("\n📊 서비스별 안정성 결과:");
        log.info("-----------------------------------------------------------------");
        for (TestReport report : allReports) {
            String status = report.getSuccessRate() >= 90.0 ? "✅ 우수" : 
                           report.getSuccessRate() >= 80.0 ? "⚠️ 양호" : "❌ 개선필요";
            
            log.info("🔹 {}: {} (성공률: {:.1f}%, 테스트: {}/{})",
                    report.getServiceName(),
                    status,
                    report.getSuccessRate(),
                    report.getSuccessfulTests(),
                    report.getTotalTests());

            totalAllTests += report.getTotalTests();
            totalAllSuccess += report.getSuccessfulTests();
            totalAllTime += report.getTotalExecutionTime();
        }

        double overallSuccessRate = totalAllTests > 0 ? (double) totalAllSuccess / totalAllTests * 100 : 0;

        log.info("\n🎯 전체 시스템 안정성 평가:");
        log.info("-----------------------------------------------------------------");
        log.info("총 실행된 테스트: {} 회", totalAllTests);
        log.info("성공한 테스트: {} 회", totalAllSuccess);
        log.info("실패한 테스트: {} 회", totalAllTests - totalAllSuccess);
        log.info("전체 성공률: {:.2f}%", overallSuccessRate);
        log.info("총 소요시간: {:.2f} 초", totalAllTime / 1000.0);

        String systemGrade = overallSuccessRate >= 95.0 ? "🏆 최우수 (A+)" :
                           overallSuccessRate >= 90.0 ? "🥇 우수 (A)" :
                           overallSuccessRate >= 85.0 ? "🥈 양호 (B+)" :
                           overallSuccessRate >= 80.0 ? "🥉 보통 (B)" :
                           overallSuccessRate >= 70.0 ? "⚠️ 개선필요 (C)" : "❌ 불안정 (D)";

        log.info("\n🏅 시스템 안정성 등급: {}", systemGrade);

        if (!failedServices.isEmpty()) {
            log.error("\n❌ 안정성 기준 미달 서비스:");
            log.error("-----------------------------------------------------------------");
            for (String service : failedServices) {
                log.error("- {}", service);
            }
            log.error("\n🔧 권장사항: 위 서비스들의 안정성 개선이 필요합니다.");
        } else {
            log.info("\n✅ 모든 서비스가 안정성 기준을 충족했습니다!");
        }

        log.info("\n=================================================================\n");
    }
}