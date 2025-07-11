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
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(expiresIn)
                .user(user)
                .requiresAdditionalInfo(false)
                .build();
    }
    
    public static AuthResponse socialSignupRequired(String tempToken, UserResponse user) {
        return AuthResponse.builder()
                .tempToken(tempToken)
                .user(user)
                .requiresAdditionalInfo(true)
                .build();
    }
}