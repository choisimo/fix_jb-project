package com.jeonbuk.report.application.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.concurrent.TimeUnit;

/**
 * Redis 기반 토큰 관리 서비스
 * - Refresh Token 저장/검증/삭제
 * - 토큰 블랙리스트 관리
 * - 로그아웃 처리
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TokenService {

    private final RedisTemplate<String, String> redisTemplate;
    
    private static final String REFRESH_TOKEN_PREFIX = "refresh_token:";
    private static final String BLACKLIST_PREFIX = "blacklist:";
    private static final long REFRESH_TOKEN_EXPIRE_DAYS = 7;
    private static final long BLACKLIST_EXPIRE_HOURS = 24;

    /**
     * Refresh Token 저장
     */
    public void saveRefreshToken(String email, String refreshToken) {
        try {
            String key = REFRESH_TOKEN_PREFIX + email;
            redisTemplate.opsForValue().set(key, refreshToken, Duration.ofDays(REFRESH_TOKEN_EXPIRE_DAYS));
            log.debug("Refresh token saved for user: {}", email);
        } catch (Exception e) {
            log.error("Failed to save refresh token for user: {}", email, e);
        }
    }

    /**
     * Refresh Token 검증
     */
    public boolean isValidRefreshToken(String email, String refreshToken) {
        try {
            String key = REFRESH_TOKEN_PREFIX + email;
            String storedToken = redisTemplate.opsForValue().get(key);
            return refreshToken.equals(storedToken);
        } catch (Exception e) {
            log.error("Failed to validate refresh token for user: {}", email, e);
            return false;
        }
    }

    /**
     * Refresh Token 삭제
     */
    public void deleteRefreshToken(String email) {
        try {
            String key = REFRESH_TOKEN_PREFIX + email;
            redisTemplate.delete(key);
            log.debug("Refresh token deleted for user: {}", email);
        } catch (Exception e) {
            log.error("Failed to delete refresh token for user: {}", email, e);
        }
    }

    /**
     * 토큰을 블랙리스트에 추가
     */
    public void addToBlacklist(String token) {
        try {
            String key = BLACKLIST_PREFIX + token;
            redisTemplate.opsForValue().set(key, "blacklisted", Duration.ofHours(BLACKLIST_EXPIRE_HOURS));
            log.debug("Token added to blacklist");
        } catch (Exception e) {
            log.error("Failed to add token to blacklist", e);
        }
    }

    /**
     * 토큰이 블랙리스트에 있는지 확인
     */
    public boolean isBlacklisted(String token) {
        try {
            String key = BLACKLIST_PREFIX + token;
            return redisTemplate.hasKey(key);
        } catch (Exception e) {
            log.error("Failed to check blacklist status", e);
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
        try {
            redisTemplate.opsForValue().get("test");
            return true;
        } catch (Exception e) {
            log.warn("Redis is not available", e);
            return false;
        }
    }
}