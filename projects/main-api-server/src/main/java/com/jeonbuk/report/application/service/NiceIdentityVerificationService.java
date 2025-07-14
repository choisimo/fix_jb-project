package com.jeonbuk.report.application.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.security.MessageDigest;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * NICE 평가정보 실명인증 서비스
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NiceIdentityVerificationService {

    private final RedisTemplate<String, String> redisTemplate;
    private final WebClient.Builder webClientBuilder;

    @Value("${app.nice.client-id:}")
    private String niceClientId;

    @Value("${app.nice.client-secret:}")
    private String niceClientSecret;

    @Value("${app.nice.return-url:}")
    private String niceReturnUrl;

    @Value("${app.nice.api-url:https://nice.checkplus.co.kr}")
    private String niceApiUrl;

    private static final String NICE_TOKEN_PREFIX = "nice_token:";
    private static final String NICE_RESULT_PREFIX = "nice_result:";

    /**
     * NICE 인증 요청 토큰 생성
     */
    public Map<String, String> createVerificationRequest() {
        try {
            String requestToken = UUID.randomUUID().toString();
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
            
            // 인증 요청 데이터
            Map<String, Object> requestData = new HashMap<>();
            requestData.put("requestno", requestToken);
            requestData.put("returnurl", niceReturnUrl);
            requestData.put("sitecode", niceClientId);
            requestData.put("methodtype", "get");
            requestData.put("popupyn", "Y");
            
            // 암호화된 요청 데이터 생성 (실제로는 NICE에서 제공하는 암호화 모듈 사용)
            String encData = encryptRequestData(requestData, timestamp);
            String integrityValue = generateIntegrityValue(encData, timestamp);
            
            // Redis에 요청 토큰 저장 (10분 만료)
            redisTemplate.opsForValue().set(
                NICE_TOKEN_PREFIX + requestToken, 
                "pending", 
                Duration.ofMinutes(10)
            );
            
            Map<String, String> result = new HashMap<>();
            result.put("requestToken", requestToken);
            result.put("encData", encData);
            result.put("integrityValue", integrityValue);
            result.put("niceUrl", niceApiUrl + "/checkplus.cb");
            
            log.info("NICE 인증 요청 생성: {}", requestToken);
            return result;
            
        } catch (Exception e) {
            log.error("NICE 인증 요청 생성 실패", e);
            throw new RuntimeException("실명인증 요청 생성에 실패했습니다.");
        }
    }

    /**
     * NICE 인증 결과 처리
     */
    public Map<String, Object> processVerificationResult(String requestToken, String encData) {
        try {
            // Redis에서 요청 토큰 확인
            String tokenStatus = redisTemplate.opsForValue().get(NICE_TOKEN_PREFIX + requestToken);
            if (!"pending".equals(tokenStatus)) {
                throw new RuntimeException("유효하지 않은 인증 요청입니다.");
            }
            
            // 암호화된 결과 데이터 복호화 (실제로는 NICE에서 제공하는 복호화 모듈 사용)
            Map<String, Object> decryptedData = decryptResponseData(encData);
            
            // 인증 성공 여부 확인
            String resultCode = (String) decryptedData.get("resultcode");
            if (!"0000".equals(resultCode)) {
                log.warn("NICE 인증 실패: {} - {}", resultCode, decryptedData.get("resultmsg"));
                throw new RuntimeException("실명인증에 실패했습니다.");
            }
            
            // 인증 결과 데이터 추출
            Map<String, Object> result = new HashMap<>();
            result.put("name", decryptedData.get("name"));
            result.put("birthday", decryptedData.get("birthdate"));
            result.put("gender", decryptedData.get("gender"));
            result.put("phoneNumber", decryptedData.get("mobileno"));
            result.put("carrier", decryptedData.get("mobileco"));
            result.put("ci", decryptedData.get("ci")); // 개인식별정보
            result.put("di", decryptedData.get("di")); // 중복가입확인정보
            
            // Redis에 인증 결과 저장 (24시간 만료)
            redisTemplate.opsForValue().set(
                NICE_RESULT_PREFIX + requestToken, 
                result.toString(), 
                Duration.ofHours(24)
            );
            
            // 요청 토큰 상태 업데이트
            redisTemplate.opsForValue().set(
                NICE_TOKEN_PREFIX + requestToken, 
                "completed", 
                Duration.ofHours(24)
            );
            
            log.info("NICE 인증 완료: {} - {}", requestToken, result.get("name"));
            return result;
            
        } catch (Exception e) {
            log.error("NICE 인증 결과 처리 실패: {}", requestToken, e);
            throw new RuntimeException("실명인증 결과 처리에 실패했습니다.");
        }
    }

    /**
     * 인증 상태 확인
     */
    public String getVerificationStatus(String requestToken) {
        return redisTemplate.opsForValue().get(NICE_TOKEN_PREFIX + requestToken);
    }

    /**
     * 인증 결과 조회
     */
    public Map<String, Object> getVerificationResult(String requestToken) {
        try {
            String resultData = redisTemplate.opsForValue().get(NICE_RESULT_PREFIX + requestToken);
            if (resultData == null) {
                return null;
            }
            
            // 실제로는 JSON 파싱 등을 통해 Map으로 변환
            // 여기서는 간단한 예시
            return new HashMap<>();
            
        } catch (Exception e) {
            log.error("NICE 인증 결과 조회 실패: {}", requestToken, e);
            return null;
        }
    }

    /**
     * 요청 데이터 암호화 (실제로는 NICE 제공 모듈 사용)
     */
    private String encryptRequestData(Map<String, Object> data, String timestamp) {
        // 실제 구현에서는 NICE에서 제공하는 암호화 라이브러리 사용
        // 여기서는 예시를 위한 더미 구현
        return "encrypted_" + data.hashCode() + "_" + timestamp;
    }

    /**
     * 무결성 값 생성 (실제로는 NICE 제공 모듈 사용)
     */
    private String generateIntegrityValue(String encData, String timestamp) {
        try {
            String data = encData + timestamp + niceClientSecret;
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(data.getBytes());
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            
            return hexString.toString();
        } catch (Exception e) {
            log.error("무결성 값 생성 실패", e);
            return "";
        }
    }

    /**
     * 응답 데이터 복호화 (실제로는 NICE 제공 모듈 사용)
     */
    private Map<String, Object> decryptResponseData(String encData) {
        // 실제 구현에서는 NICE에서 제공하는 복호화 라이브러리 사용
        // 여기서는 예시를 위한 더미 구현
        Map<String, Object> result = new HashMap<>();
        result.put("resultcode", "0000");
        result.put("resultmsg", "성공");
        result.put("name", "홍길동");
        result.put("birthdate", "19900101");
        result.put("gender", "1");
        result.put("mobileno", "01012345678");
        result.put("mobileco", "SKT");
        result.put("ci", "sample_ci_value");
        result.put("di", "sample_di_value");
        
        return result;
    }
}