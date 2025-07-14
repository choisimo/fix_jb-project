package com.jeonbuk.report.application.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

/**
 * Redis 기반 토큰 관리 서비스
 * - Refresh Token 저장/검증/삭제
 * - 토큰 블랙리스트 관리
 * - 로그아웃 처리
 * - Redis 미사용 시 메모리 기반 fallback 제공
 */
@Slf4j
@Service
public class TokenService {

    private final RedisTemplate<String, String> redisTemplate;
    
    private static final String REFRESH_TOKEN_PREFIX = "refresh_token:";
    private static final String BLACKLIST_PREFIX = "blacklist:";
    private static final long REFRESH_TOKEN_EXPIRE_DAYS = 7;
    private static final long BLACKLIST_EXPIRE_HOURS = 24;
    
    // Fallback in-memory storage when Redis is not available
    private final ConcurrentHashMap<String, String> inMemoryRefreshTokens = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, LocalDateTime> inMemoryBlacklist = new ConcurrentHashMap<>();
    private boolean useRedis = true;

    public TokenService(RedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
        log.info("🟢 TokenService initialized with Redis support: {}", redisTemplate != null);
    }

    /**
     * Refresh Token 저장
     */
    public void saveRefreshToken(String email, String refreshToken) {
        try {
            if (isRedisAvailable()) {
                String key = REFRESH_TOKEN_PREFIX + email;
                redisTemplate.opsForValue().set(key, refreshToken, Duration.ofDays(REFRESH_TOKEN_EXPIRE_DAYS));
                log.debug("Refresh token saved in Redis for user: {}", email);
            } else {
                inMemoryRefreshTokens.put(email, refreshToken);
                log.debug("Refresh token saved in memory for user: {}", email);
            }
        } catch (Exception e) {
            log.error("Failed to save refresh token for user: {}, falling back to memory", email, e);
            inMemoryRefreshTokens.put(email, refreshToken);
        }
    }

    /**
     * Refresh Token 검증
     */
    public boolean isValidRefreshToken(String email, String refreshToken) {
        try {
            if (isRedisAvailable()) {
                String key = REFRESH_TOKEN_PREFIX + email;
                String storedToken = redisTemplate.opsForValue().get(key);
                return refreshToken.equals(storedToken);
            } else {
                String storedToken = inMemoryRefreshTokens.get(email);
                return refreshToken.equals(storedToken);
            }
        } catch (Exception e) {
            log.error("Failed to validate refresh token for user: {}, checking memory", email, e);
            String storedToken = inMemoryRefreshTokens.get(email);
            return refreshToken.equals(storedToken);
        }
    }

    /**
     * Refresh Token 삭제
     */
    public void deleteRefreshToken(String email) {
        try {
            if (isRedisAvailable()) {
                String key = REFRESH_TOKEN_PREFIX + email;
                redisTemplate.delete(key);
                log.debug("Refresh token deleted from Redis for user: {}", email);
            } else {
                inMemoryRefreshTokens.remove(email);
                log.debug("Refresh token deleted from memory for user: {}", email);
            }
        } catch (Exception e) {
            log.error("Failed to delete refresh token for user: {}, removing from memory", email, e);
            inMemoryRefreshTokens.remove(email);
        }
    }

    /**
     * 토큰을 블랙리스트에 추가
     */
    public void addToBlacklist(String token) {
        try {
            if (isRedisAvailable()) {
                String key = BLACKLIST_PREFIX + token;
                redisTemplate.opsForValue().set(key, "blacklisted", Duration.ofHours(BLACKLIST_EXPIRE_HOURS));
                log.debug("Token added to Redis blacklist");
            } else {
                inMemoryBlacklist.put(token, LocalDateTime.now().plusHours(BLACKLIST_EXPIRE_HOURS));
                log.debug("Token added to memory blacklist");
            }
        } catch (Exception e) {
            log.error("Failed to add token to Redis blacklist, adding to memory", e);
            inMemoryBlacklist.put(token, LocalDateTime.now().plusHours(BLACKLIST_EXPIRE_HOURS));
        }
    }

    /**
     * 토큰이 블랙리스트에 있는지 확인
     */
    public boolean isBlacklisted(String token) {
        try {
            if (isRedisAvailable()) {
                String key = BLACKLIST_PREFIX + token;
                return Boolean.TRUE.equals(redisTemplate.hasKey(key));
            } else {
                LocalDateTime expiry = inMemoryBlacklist.get(token);
                if (expiry != null) {
                    if (LocalDateTime.now().isBefore(expiry)) {
                        return true;
                    } else {
                        // 만료된 항목 제거
                        inMemoryBlacklist.remove(token);
                        return false;
                    }
                }
                return false;
            }
        } catch (Exception e) {
            log.error("Failed to check Redis blacklist status, checking memory", e);
            LocalDateTime expiry = inMemoryBlacklist.get(token);
            if (expiry != null) {
                if (LocalDateTime.now().isBefore(expiry)) {
                    return true;
                } else {
                    inMemoryBlacklist.remove(token);
                    return false;
                }
            }
            return false;
        }
    }

    /**
     * 사용자의 모든 토큰 무효화 (로그아웃)
     */
    public void invalidateAllTokens(String email) {
        deleteRefreshToken(email);
        // Access Token은 JWT 특성상 만료시까지 유효하므로, 
        // 필요시 블랙리스트를 활용하여 무효화
    }

    /**
     * Redis 연결 상태 확인
     */
    public boolean isRedisAvailable() {
        if (!useRedis || redisTemplate == null) return false;
        
        try {
            redisTemplate.opsForValue().get("test");
            return true;
        } catch (Exception e) {
            log.warn("Redis is not available, using in-memory fallback: {}", e.getMessage());
            useRedis = false; // Redis가 실패하면 이 세션에서는 메모리 사용
            return false;
        }
    }
    
    /**
     * 메모리 저장소 정리 (개발용)
     */
    public void cleanupMemoryStorage() {
        // 만료된 블랙리스트 항목 정리
        LocalDateTime now = LocalDateTime.now();
        inMemoryBlacklist.entrySet().removeIf(entry -> now.isAfter(entry.getValue()));
        log.debug("Memory storage cleanup completed");
    }
}