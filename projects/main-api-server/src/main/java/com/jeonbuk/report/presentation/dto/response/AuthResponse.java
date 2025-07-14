package com.jeonbuk.report.presentation.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AuthResponse {
    
    private String accessToken;
    private String refreshToken;
    private long expiresIn;
    private UserResponse user;
    private boolean requiresAdditionalInfo;
    private String tempToken; // 소셜 로그인 시 추가 정보 입력용 임시 토큰
    
    public static AuthResponse success(String accessToken, String refreshToken, long expiresIn, UserResponse user) {
        return new AuthResponseBuilder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(expiresIn)
                .user(user)
                .requiresAdditionalInfo(false)
                .build();
    }
    
    public static AuthResponse socialSignupRequired(String tempToken, UserResponse user) {
        return new AuthResponseBuilder()
                .tempToken(tempToken)
                .user(user)
                .requiresAdditionalInfo(true)
                .build();
    }

    // Manual builder implementation
    public static AuthResponseBuilder builder() {
        return new AuthResponseBuilder();
    }

    public static class AuthResponseBuilder {
        private String accessToken;
        private String refreshToken;
        private long expiresIn;
        private UserResponse user;
        private boolean requiresAdditionalInfo;
        private String tempToken;

        public AuthResponseBuilder accessToken(String accessToken) {
            this.accessToken = accessToken;
            return this;
        }

        public AuthResponseBuilder refreshToken(String refreshToken) {
            this.refreshToken = refreshToken;
            return this;
        }

        public AuthResponseBuilder expiresIn(long expiresIn) {
            this.expiresIn = expiresIn;
            return this;
        }

        public AuthResponseBuilder user(UserResponse user) {
            this.user = user;
            return this;
        }

        public AuthResponseBuilder requiresAdditionalInfo(boolean requiresAdditionalInfo) {
            this.requiresAdditionalInfo = requiresAdditionalInfo;
            return this;
        }

        public AuthResponseBuilder tempToken(String tempToken) {
            this.tempToken = tempToken;
            return this;
        }

        public AuthResponse build() {
            AuthResponse response = new AuthResponse();
            response.accessToken = this.accessToken;
            response.refreshToken = this.refreshToken;
            response.expiresIn = this.expiresIn;
            response.user = this.user;
            response.requiresAdditionalInfo = this.requiresAdditionalInfo;
            response.tempToken = this.tempToken;
            return response;
        }
    }

    // Getters for missing methods
    public String getAccessToken() {
        return accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public boolean isRequiresAdditionalInfo() {
        return requiresAdditionalInfo;
    }

    public String getTempToken() {
        return tempToken;
    }
}