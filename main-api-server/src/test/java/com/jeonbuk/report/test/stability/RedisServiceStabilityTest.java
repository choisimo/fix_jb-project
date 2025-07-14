package com.jeonbuk.report.test.stability;

import com.jeonbuk.report.test.stability.StabilityTestFramework.TestReport;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.test.context.TestPropertySource;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.time.Duration;
import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * Redis 연결 및 캐시 서비스 안정성 테스트
 */
@Slf4j
@SpringBootTest
@TestPropertySource(locations = "classpath:application-test.properties")
@RequiredArgsConstructor
public class RedisServiceStabilityTest {

    private final RedisTemplate<String, String> redisTemplate;
    private final StabilityTestFramework testFramework;

    @Test
    @DisplayName("Redis 연결 안정성 테스트 - 순차 5회")
    public void testRedisConnectionStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Redis 서비스",
            "Redis 연결",
            this::testRedisConnection,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 95% 성공률)
        assert report.getSuccessRate() >= 95.0 : 
            String.format("Redis 연결 성공률이 95%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("Redis 기본 CRUD 안정성 테스트 - 순차 6회")
    public void testRedisCrudStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Redis 서비스",
            "Redis 기본 CRUD",
            this::testRedisCrud,
            6
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 90% 성공률)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("Redis CRUD 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("Redis 만료 시간 설정 안정성 테스트 - 순차 5회")
    public void testRedisExpirationStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Redis 서비스",
            "Redis 만료 시간 설정",
            this::testRedisExpiration,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 90% 성공률)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("Redis 만료 시간 설정 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("Redis Hash 연산 안정성 테스트 - 순차 7회")
    public void testRedisHashStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Redis 서비스",
            "Redis Hash 연산",
            this::testRedisHash,
            7
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 90% 성공률)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("Redis Hash 연산 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("Redis 동시 접근 안정성 테스트 - 동시 10회")
    public void testRedisConcurrentAccessStability() {
        TestReport report = testFramework.runParallelTest(
            "Redis 서비스",
            "Redis 동시 접근",
            this::testRedisCrud,
            10
        );
        
        testFramework.printReport(report);
        
        // 동시 접근 테스트 검증 (최소 85% 성공률, 평균 응답시간 1초 이하)
        assert report.getSuccessRate() >= 85.0 : 
            String.format("Redis 동시 접근 성공률이 85%% 미만입니다: %.2f%%", report.getSuccessRate());
        assert report.getAverageExecutionTime() <= 1000 : 
            String.format("Redis 평균 응답시간이 1초를 초과했습니다: %dms", report.getAverageExecutionTime());
    }

    @Test
    @DisplayName("Redis 대용량 데이터 처리 안정성 테스트 - 순차 5회")
    public void testRedisLargeDataStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Redis 서비스",
            "Redis 대용량 데이터 처리",
            this::testRedisLargeData,
            5
        );
        
        testFramework.printReport(report);
        
        // 대용량 데이터 처리 검증 (최소 80% 성공률)
        assert report.getSuccessRate() >= 80.0 : 
            String.format("Redis 대용량 데이터 처리 성공률이 80%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("Redis 패턴 매칭 안정성 테스트 - 순차 6회")
    public void testRedisPatternMatchingStability() {
        TestReport report = testFramework.runRepeatedTest(
            "Redis 서비스",
            "Redis 패턴 매칭",
            this::testRedisPatternMatching,
            6
        );
        
        testFramework.printReport(report);
        
        // 패턴 매칭 검증 (최소 90% 성공률)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("Redis 패턴 매칭 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    /**
     * Redis 연결 테스트
     */
    private Boolean testRedisConnection() {
        try {
            // Redis 연결 상태 확인
            String pingResult = redisTemplate.getConnectionFactory()
                .getConnection()
                .ping();
            
            if (!"PONG".equals(pingResult)) {
                throw new RuntimeException("Redis ping 응답이 PONG이 아닙니다: " + pingResult);
            }
            
            // 간단한 SET/GET 테스트
            String testKey = "connection_test_" + System.currentTimeMillis();
            String testValue = "test_value";
            
            redisTemplate.opsForValue().set(testKey, testValue);
            String retrievedValue = redisTemplate.opsForValue().get(testKey);
            
            if (!testValue.equals(retrievedValue)) {
                throw new RuntimeException("SET/GET 테스트 실패");
            }
            
            // 테스트 키 정리
            redisTemplate.delete(testKey);
            
            log.info("Redis 연결 테스트 성공");
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("Redis 연결 테스트 실패: " + e.getMessage());
        }
    }

    /**
     * Redis 기본 CRUD 테스트
     */
    private Boolean testRedisCrud() {
        try {
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String testKey = "crud_test_" + uniqueId;
            String testValue = "test_value_" + uniqueId;

            // CREATE (SET)
            redisTemplate.opsForValue().set(testKey, testValue);
            
            // READ (GET)
            String retrievedValue = redisTemplate.opsForValue().get(testKey);
            if (!testValue.equals(retrievedValue)) {
                throw new RuntimeException("CREATE/READ 실패: 값이 일치하지 않음");
            }
            
            // UPDATE (SET with new value)
            String updatedValue = "updated_value_" + uniqueId;
            redisTemplate.opsForValue().set(testKey, updatedValue);
            
            String retrievedUpdatedValue = redisTemplate.opsForValue().get(testKey);
            if (!updatedValue.equals(retrievedUpdatedValue)) {
                throw new RuntimeException("UPDATE 실패: 값이 일치하지 않음");
            }
            
            // 존재 확인
            Boolean exists = redisTemplate.hasKey(testKey);
            if (!exists) {
                throw new RuntimeException("키 존재 확인 실패");
            }
            
            // DELETE
            Boolean deleted = redisTemplate.delete(testKey);
            if (!deleted) {
                throw new RuntimeException("DELETE 실패");
            }
            
            // 삭제 확인
            Boolean existsAfterDelete = redisTemplate.hasKey(testKey);
            if (existsAfterDelete) {
                throw new RuntimeException("DELETE 후 키가 여전히 존재함");
            }
            
            log.info("Redis CRUD 테스트 성공: {}", testKey);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("Redis CRUD 테스트 실패: " + e.getMessage());
        }
    }

    /**
     * Redis 만료 시간 설정 테스트
     */
    private Boolean testRedisExpiration() {
        try {
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String testKey = "expiration_test_" + uniqueId;
            String testValue = "test_value_" + uniqueId;

            // 5초 만료 시간으로 설정
            redisTemplate.opsForValue().set(testKey, testValue, Duration.ofSeconds(5));
            
            // 즉시 조회 (존재해야 함)
            String immediateValue = redisTemplate.opsForValue().get(testKey);
            if (!testValue.equals(immediateValue)) {
                throw new RuntimeException("만료 시간 설정 후 즉시 조회 실패");
            }
            
            // TTL 확인
            Long ttl = redisTemplate.getExpire(testKey, TimeUnit.SECONDS);
            if (ttl == null || ttl <= 0 || ttl > 5) {
                throw new RuntimeException("TTL이 올바르지 않음: " + ttl);
            }
            
            // 짧은 만료 시간 테스트 (1초)
            String shortKey = "short_expiration_" + uniqueId;
            redisTemplate.opsForValue().set(shortKey, testValue, Duration.ofSeconds(1));
            
            // 1.5초 대기
            Thread.sleep(1500);
            
            // 만료 확인
            String expiredValue = redisTemplate.opsForValue().get(shortKey);
            if (expiredValue != null) {
                throw new RuntimeException("만료된 키가 여전히 존재함");
            }
            
            // 원래 키 정리 (아직 만료되지 않았을 수 있음)
            redisTemplate.delete(testKey);
            
            log.info("Redis 만료 시간 테스트 성공: {}", testKey);
            return true;
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("테스트 중단됨");
        } catch (Exception e) {
            throw new RuntimeException("Redis 만료 시간 테스트 실패: " + e.getMessage());
        }
    }

    /**
     * Redis Hash 연산 테스트
     */
    private Boolean testRedisHash() {
        try {
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String hashKey = "hash_test_" + uniqueId;

            // Hash 필드 설정
            Map<String, String> hashMap = new HashMap<>();
            hashMap.put("field1", "value1_" + uniqueId);
            hashMap.put("field2", "value2_" + uniqueId);
            hashMap.put("field3", "value3_" + uniqueId);
            
            redisTemplate.opsForHash().putAll(hashKey, hashMap);
            
            // 개별 필드 조회
            String field1Value = (String) redisTemplate.opsForHash().get(hashKey, "field1");
            if (!hashMap.get("field1").equals(field1Value)) {
                throw new RuntimeException("Hash 개별 필드 조회 실패");
            }
            
            // 모든 필드 조회
            Map<Object, Object> retrievedHash = redisTemplate.opsForHash().entries(hashKey);
            if (retrievedHash.size() != 3) {
                throw new RuntimeException("Hash 전체 조회 실패: 크기가 다름");
            }
            
            // 필드 존재 확인
            Boolean hasField = redisTemplate.opsForHash().hasKey(hashKey, "field1");
            if (!hasField) {
                throw new RuntimeException("Hash 필드 존재 확인 실패");
            }
            
            // 필드 삭제
            Long deletedCount = redisTemplate.opsForHash().delete(hashKey, "field1");
            if (deletedCount != 1) {
                throw new RuntimeException("Hash 필드 삭제 실패");
            }
            
            // 삭제 확인
            Boolean hasDeletedField = redisTemplate.opsForHash().hasKey(hashKey, "field1");
            if (hasDeletedField) {
                throw new RuntimeException("삭제된 Hash 필드가 여전히 존재함");
            }
            
            // Hash 크기 확인
            Long hashSize = redisTemplate.opsForHash().size(hashKey);
            if (hashSize != 2) {
                throw new RuntimeException("Hash 크기가 올바르지 않음: " + hashSize);
            }
            
            // Hash 전체 삭제
            redisTemplate.delete(hashKey);
            
            log.info("Redis Hash 테스트 성공: {}", hashKey);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("Redis Hash 테스트 실패: " + e.getMessage());
        }
    }

    /**
     * Redis 대용량 데이터 처리 테스트
     */
    private Boolean testRedisLargeData() {
        try {
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String prefix = "large_data_test_" + uniqueId + "_";
            
            // 1000개의 키-값 쌍 생성
            int dataCount = 1000;
            Map<String, String> largeDataMap = new HashMap<>();
            
            for (int i = 0; i < dataCount; i++) {
                String key = prefix + i;
                String value = "large_value_" + i + "_" + UUID.randomUUID().toString();
                largeDataMap.put(key, value);
            }
            
            // 대량 데이터 저장
            long startTime = System.currentTimeMillis();
            redisTemplate.opsForValue().multiSet(largeDataMap);
            long setTime = System.currentTimeMillis() - startTime;
            
            if (setTime > 5000) { // 5초 이상 걸리면 경고
                log.warn("대량 데이터 저장이 5초를 초과했습니다: {}ms", setTime);
            }
            
            // 대량 데이터 조회
            startTime = System.currentTimeMillis();
            List<String> keys = new ArrayList<>(largeDataMap.keySet());
            List<String> values = redisTemplate.opsForValue().multiGet(keys);
            long getTime = System.currentTimeMillis() - startTime;
            
            if (getTime > 3000) { // 3초 이상 걸리면 경고
                log.warn("대량 데이터 조회가 3초를 초과했습니다: {}ms", getTime);
            }
            
            // 조회 결과 검증
            if (values == null || values.size() != dataCount) {
                throw new RuntimeException("대량 데이터 조회 결과 크기가 다름");
            }
            
            // 일부 값 검증
            for (int i = 0; i < Math.min(10, dataCount); i++) {
                String expectedValue = largeDataMap.get(keys.get(i));
                String actualValue = values.get(i);
                if (!expectedValue.equals(actualValue)) {
                    throw new RuntimeException("대량 데이터 값이 일치하지 않음");
                }
            }
            
            // 대량 데이터 삭제
            startTime = System.currentTimeMillis();
            Long deletedCount = redisTemplate.delete(keys);
            long deleteTime = System.currentTimeMillis() - startTime;
            
            if (deleteTime > 3000) { // 3초 이상 걸리면 경고
                log.warn("대량 데이터 삭제가 3초를 초과했습니다: {}ms", deleteTime);
            }
            
            if (deletedCount == null || deletedCount != dataCount) {
                throw new RuntimeException("대량 데이터 삭제 개수가 다름: " + deletedCount);
            }
            
            log.info("Redis 대용량 데이터 테스트 성공: {} 개 (저장: {}ms, 조회: {}ms, 삭제: {}ms)", 
                    dataCount, setTime, getTime, deleteTime);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("Redis 대용량 데이터 테스트 실패: " + e.getMessage());
        }
    }

    /**
     * Redis 패턴 매칭 테스트
     */
    private Boolean testRedisPatternMatching() {
        try {
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String prefix = "pattern_test_" + uniqueId + "_";
            
            // 다양한 패턴의 키 생성
            Map<String, String> testData = new HashMap<>();
            testData.put(prefix + "user_1", "user1_data");
            testData.put(prefix + "user_2", "user2_data");
            testData.put(prefix + "admin_1", "admin1_data");
            testData.put(prefix + "guest_1", "guest1_data");
            testData.put(prefix + "config_setting", "config_data");
            
            // 데이터 저장
            redisTemplate.opsForValue().multiSet(testData);
            
            // 패턴 매칭 테스트 1: user_* 패턴
            Set<String> userKeys = redisTemplate.keys(prefix + "user_*");
            if (userKeys == null || userKeys.size() != 2) {
                throw new RuntimeException("user_* 패턴 매칭 실패: " + (userKeys != null ? userKeys.size() : "null"));
            }
            
            // 패턴 매칭 테스트 2: *_1 패턴
            Set<String> endWithOne = redisTemplate.keys(prefix + "*_1");
            if (endWithOne == null || endWithOne.size() != 3) {
                throw new RuntimeException("*_1 패턴 매칭 실패: " + (endWithOne != null ? endWithOne.size() : "null"));
            }
            
            // 패턴 매칭 테스트 3: 전체 prefix 패턴
            Set<String> allKeys = redisTemplate.keys(prefix + "*");
            if (allKeys == null || allKeys.size() != 5) {
                throw new RuntimeException("prefix* 패턴 매칭 실패: " + (allKeys != null ? allKeys.size() : "null"));
            }
            
            // 존재하지 않는 패턴 테스트
            Set<String> noMatch = redisTemplate.keys(prefix + "nonexistent_*");
            if (noMatch == null || !noMatch.isEmpty()) {
                throw new RuntimeException("존재하지 않는 패턴이 매칭됨");
            }
            
            // 정리
            redisTemplate.delete(allKeys);
            
            log.info("Redis 패턴 매칭 테스트 성공: prefix={}", prefix);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("Redis 패턴 매칭 테스트 실패: " + e.getMessage());
        }
    }
}