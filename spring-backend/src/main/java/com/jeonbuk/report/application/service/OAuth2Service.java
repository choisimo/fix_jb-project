package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.infrastructure.security.jwt.JwtTokenProvider;
import com.jeonbuk.report.presentation.dto.response.AuthResponse;
import com.jeonbuk.report.presentation.dto.response.UserResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

/**
 * OAuth2 인증 서비스
 * - Provider별 사용자 정보 처리
 * - JWT 토큰 생성
 * - 신규/기존 사용자 처리
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OAuth2Service {

    private final UserService userService;
    private final JwtTokenProvider jwtTokenProvider;

    /**
     * OAuth2 사용자 정보 처리
     */
    @Transactional
    public AuthResponse processOAuth2User(OAuth2User oauth2User, String registrationId) {
        OAuth2UserInfo userInfo = OAuth2UserInfoFactory.getOAuth2UserInfo(registrationId, oauth2User.getAttributes());
        
        if (userInfo.getEmail() == null || userInfo.getEmail().isEmpty()) {
            throw new IllegalArgumentException("OAuth2 제공자로부터 이메일을 가져올 수 없습니다: " + registrationId);
        }

        // 기존 사용자 확인
        User user = userService.processOAuthUser(
            registrationId,
            userInfo.getId(),
            userInfo.getEmail(),
            userInfo.getName()
        );

        // JWT 토큰 생성
        String accessToken = jwtTokenProvider.createToken(user.getEmail());
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getEmail());
        long expiresIn = jwtTokenProvider.getTokenValidityInMilliseconds();

        UserResponse userResponse = UserResponse.fromEntity(user);

        // 소셜 로그인 사용자가 추가 정보가 필요한지 확인
        if (needsAdditionalInfo(user)) {
            String tempToken = jwtTokenProvider.createTempToken(user.getEmail());
            return AuthResponse.socialSignupRequired(tempToken, userResponse);
        }

        return AuthResponse.success(accessToken, refreshToken, expiresIn, userResponse);
    }

    /**
     * 추가 정보 입력이 필요한지 확인
     */
    private boolean needsAdditionalInfo(User user) {
        return user.getName() == null || user.getName().isEmpty() ||
               user.getPhone() == null || user.getPhone().isEmpty();
    }

    /**
     * OAuth2 사용자 정보 추상화
     */
    public static abstract class OAuth2UserInfo {
        protected Map<String, Object> attributes;

        public OAuth2UserInfo(Map<String, Object> attributes) {
            this.attributes = attributes;
        }

        public abstract String getId();
        public abstract String getName();
        public abstract String getEmail();
        public abstract String getImageUrl();
    }

    /**
     * Google OAuth2 사용자 정보
     */
    public static class GoogleOAuth2UserInfo extends OAuth2UserInfo {
        public GoogleOAuth2UserInfo(Map<String, Object> attributes) {
            super(attributes);
        }

        @Override
        public String getId() {
            return (String) attributes.get("sub");
        }

        @Override
        public String getName() {
            return (String) attributes.get("name");
        }

        @Override
        public String getEmail() {
            return (String) attributes.get("email");
        }

        @Override
        public String getImageUrl() {
            return (String) attributes.get("picture");
        }
    }

    /**
     * Kakao OAuth2 사용자 정보
     */
    public static class KakaoOAuth2UserInfo extends OAuth2UserInfo {
        public KakaoOAuth2UserInfo(Map<String, Object> attributes) {
            super(attributes);
        }

        @Override
        public String getId() {
            return String.valueOf(attributes.get("id"));
        }

        @Override
        public String getName() {
            Map<String, Object> kakaoAccount = (Map<String, Object>) attributes.get("kakao_account");
            if (kakaoAccount == null) return null;
            
            Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");
            if (profile == null) return null;
            
            return (String) profile.get("nickname");
        }

        @Override
        public String getEmail() {
            Map<String, Object> kakaoAccount = (Map<String, Object>) attributes.get("kakao_account");
            if (kakaoAccount == null) return null;
            
            return (String) kakaoAccount.get("email");
        }

        @Override
        public String getImageUrl() {
            Map<String, Object> kakaoAccount = (Map<String, Object>) attributes.get("kakao_account");
            if (kakaoAccount == null) return null;
            
            Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");
            if (profile == null) return null;
            
            return (String) profile.get("profile_image_url");
        }
    }

    /**
     * OAuth2UserInfo 팩토리
     */
    public static class OAuth2UserInfoFactory {
        public static OAuth2UserInfo getOAuth2UserInfo(String registrationId, Map<String, Object> attributes) {
            switch (registrationId.toLowerCase()) {
                case "google":
                    return new GoogleOAuth2UserInfo(attributes);
                case "kakao":
                    return new KakaoOAuth2UserInfo(attributes);
                default:
                    throw new IllegalArgumentException("지원하지 않는 OAuth2 제공자입니다: " + registrationId);
            }
        }
    }
}