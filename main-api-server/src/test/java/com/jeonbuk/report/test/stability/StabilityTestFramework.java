package com.jeonbuk.report.test.stability;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.function.Supplier;

/**
 * 서비스 안정성 테스트 프레임워크
 */
@Slf4j
@Component
public class StabilityTestFramework {

    private final ExecutorService executorService = Executors.newFixedThreadPool(10);

    /**
     * 테스트 실행 결과
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TestResult {
        private String serviceName;
        private String testName;
        private boolean success;
        private String errorMessage;
        private long executionTimeMs;
        private LocalDateTime timestamp;
        private Object responseData;
    }

    /**
     * 전체 테스트 보고서
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TestReport {
        private String serviceName;
        private int totalTests;
        private int successfulTests;
        private int failedTests;
        private double successRate;
        private long averageExecutionTime;
        private long minExecutionTime;
        private long maxExecutionTime;
        private List<TestResult> results;
        private LocalDateTime testStartTime;
        private LocalDateTime testEndTime;
        private long totalExecutionTime;
    }

    /**
     * 단일 테스트 실행
     */
    public TestResult runSingleTest(String serviceName, String testName, Supplier<Object> testFunction) {
        LocalDateTime startTime = LocalDateTime.now();
        TestResult result = new TestResult();
        result.setServiceName(serviceName);
        result.setTestName(testName);
        result.setTimestamp(startTime);

        try {
            log.info("테스트 실행 시작: {} - {}", serviceName, testName);
            
            Object response = testFunction.get();
            
            LocalDateTime endTime = LocalDateTime.now();
            long executionTime = ChronoUnit.MILLIS.between(startTime, endTime);
            
            result.setSuccess(true);
            result.setExecutionTimeMs(executionTime);
            result.setResponseData(response);
            
            log.info("테스트 성공: {} - {} ({}ms)", serviceName, testName, executionTime);
            
        } catch (Exception e) {
            LocalDateTime endTime = LocalDateTime.now();
            long executionTime = ChronoUnit.MILLIS.between(startTime, endTime);
            
            result.setSuccess(false);
            result.setErrorMessage(e.getMessage());
            result.setExecutionTimeMs(executionTime);
            
            log.error("테스트 실패: {} - {} ({}ms): {}", serviceName, testName, executionTime, e.getMessage());
        }

        return result;
    }

    /**
     * 반복 테스트 실행 (동일 테스트를 여러 번)
     */
    public TestReport runRepeatedTest(String serviceName, String testName, 
                                    Supplier<Object> testFunction, int repeatCount) {
        LocalDateTime testStartTime = LocalDateTime.now();
        List<TestResult> results = new ArrayList<>();
        
        log.info("반복 테스트 시작: {} - {} ({} 회)", serviceName, testName, repeatCount);

        // 순차 실행 (안정성 확인을 위해)
        for (int i = 1; i <= repeatCount; i++) {
            String currentTestName = testName + " (반복 " + i + "/" + repeatCount + ")";
            TestResult result = runSingleTest(serviceName, currentTestName, testFunction);
            results.add(result);
            
            // 테스트 간 간격 (1초)
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }

        LocalDateTime testEndTime = LocalDateTime.now();
        return generateReport(serviceName, results, testStartTime, testEndTime);
    }

    /**
     * 병렬 테스트 실행 (부하 테스트)
     */
    public TestReport runParallelTest(String serviceName, String testName, 
                                    Supplier<Object> testFunction, int concurrentCount) {
        LocalDateTime testStartTime = LocalDateTime.now();
        List<CompletableFuture<TestResult>> futures = new ArrayList<>();
        
        log.info("병렬 테스트 시작: {} - {} ({} 동시)", serviceName, testName, concurrentCount);

        // 동시 실행
        for (int i = 1; i <= concurrentCount; i++) {
            int index = i;
            CompletableFuture<TestResult> future = CompletableFuture.supplyAsync(() -> {
                String currentTestName = testName + " (병렬 " + index + "/" + concurrentCount + ")";
                return runSingleTest(serviceName, currentTestName, testFunction);
            }, executorService);
            futures.add(future);
        }

        // 모든 테스트 완료 대기
        List<TestResult> results = new ArrayList<>();
        for (CompletableFuture<TestResult> future : futures) {
            try {
                results.add(future.get());
            } catch (Exception e) {
                log.error("병렬 테스트 결과 수집 실패", e);
            }
        }

        LocalDateTime testEndTime = LocalDateTime.now();
        return generateReport(serviceName, results, testStartTime, testEndTime);
    }

    /**
     * 테스트 보고서 생성
     */
    private TestReport generateReport(String serviceName, List<TestResult> results, 
                                    LocalDateTime startTime, LocalDateTime endTime) {
        TestReport report = new TestReport();
        report.setServiceName(serviceName);
        report.setResults(results);
        report.setTestStartTime(startTime);
        report.setTestEndTime(endTime);
        report.setTotalExecutionTime(ChronoUnit.MILLIS.between(startTime, endTime));

        int totalTests = results.size();
        int successfulTests = (int) results.stream().filter(TestResult::isSuccess).count();
        int failedTests = totalTests - successfulTests;

        report.setTotalTests(totalTests);
        report.setSuccessfulTests(successfulTests);
        report.setFailedTests(failedTests);
        report.setSuccessRate(totalTests > 0 ? (double) successfulTests / totalTests * 100 : 0);

        if (!results.isEmpty()) {
            List<Long> executionTimes = results.stream()
                .map(TestResult::getExecutionTimeMs)
                .toList();
            
            report.setAverageExecutionTime(
                (long) executionTimes.stream().mapToLong(Long::longValue).average().orElse(0)
            );
            report.setMinExecutionTime(
                executionTimes.stream().mapToLong(Long::longValue).min().orElse(0)
            );
            report.setMaxExecutionTime(
                executionTimes.stream().mapToLong(Long::longValue).max().orElse(0)
            );
        }

        return report;
    }

    /**
     * 보고서 출력
     */
    public void printReport(TestReport report) {
        log.info("\n" +
            "==================================================\n" +
            "서비스 안정성 테스트 보고서\n" +
            "==================================================\n" +
            "서비스명: {}\n" +
            "테스트 기간: {} ~ {}\n" +
            "총 실행시간: {}ms\n" +
            "총 테스트: {}\n" +
            "성공: {} ({}%)\n" +
            "실패: {}\n" +
            "평균 실행시간: {}ms\n" +
            "최소 실행시간: {}ms\n" +
            "최대 실행시간: {}ms\n" +
            "==================================================",
            report.getServiceName(),
            report.getTestStartTime(),
            report.getTestEndTime(),
            report.getTotalExecutionTime(),
            report.getTotalTests(),
            report.getSuccessfulTests(),
            String.format("%.2f", report.getSuccessRate()),
            report.getFailedTests(),
            report.getAverageExecutionTime(),
            report.getMinExecutionTime(),
            report.getMaxExecutionTime()
        );

        // 실패한 테스트 상세 출력
        List<TestResult> failedTests = report.getResults().stream()
            .filter(result -> !result.isSuccess())
            .toList();

        if (!failedTests.isEmpty()) {
            log.error("\n실패한 테스트 상세:");
            for (TestResult failed : failedTests) {
                log.error("- {}: {}", failed.getTestName(), failed.getErrorMessage());
            }
        }
    }

    /**
     * 리소스 정리
     */
    public void shutdown() {
        executorService.shutdown();
    }
}