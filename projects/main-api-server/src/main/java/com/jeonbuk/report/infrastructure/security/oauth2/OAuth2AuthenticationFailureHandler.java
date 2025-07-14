package com.jeonbuk.report.infrastructure.security.oauth2;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * OAuth2 인증 실패 핸들러
 * - OAuth2 인증 실패 시 처리
 * - 에러 메시지와 함께 프론트엔드로 리다이렉트
 */
@Slf4j
@Component
public class OAuth2AuthenticationFailureHandler extends SimpleUrlAuthenticationFailureHandler {

    @Value("${app.oauth2.authorized-redirect-uris:http://localhost:3000/auth/callback}")
    private String redirectUri;

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
                                      AuthenticationException exception) throws IOException, ServletException {
        
        String targetUrl = UriComponentsBuilder.fromUriString(redirectUri)
                .queryParam("error", URLEncoder.encode(getErrorMessage(exception), StandardCharsets.UTF_8))
                .build().toUriString();

        log.error("OAuth2 authentication failed", exception);
        getRedirectStrategy().sendRedirect(request, response, targetUrl);
    }

    private String getErrorMessage(AuthenticationException exception) {
        if (exception.getMessage().contains("access_denied")) {
            return "사용자가 권한 요청을 거부했습니다.";
        } else if (exception.getMessage().contains("invalid_request")) {
            return "잘못된 OAuth2 요청입니다.";
        } else if (exception.getMessage().contains("unauthorized_client")) {
            return "인증되지 않은 클라이언트입니다.";
        } else if (exception.getMessage().contains("unsupported_response_type")) {
            return "지원하지 않는 응답 타입입니다.";
        } else if (exception.getMessage().contains("invalid_scope")) {
            return "잘못된 권한 범위입니다.";
        } else {
            return "OAuth2 인증 중 오류가 발생했습니다.";
        }
    }
}