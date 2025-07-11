package com.jeonbuk.report.infrastructure.security.oauth2;

import com.jeonbuk.report.application.service.OAuth2Service;
import com.jeonbuk.report.presentation.dto.response.AuthResponse;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * OAuth2 인증 성공 핸들러
 * - OAuth2 인증 완료 후 처리
 * - JWT 토큰 생성 및 프론트엔드로 리다이렉트
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OAuth2AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final OAuth2Service oauth2Service;

    @Value("${app.oauth2.authorized-redirect-uris:http://localhost:3000/auth/callback}")
    private String redirectUri;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                      Authentication authentication) throws IOException, ServletException {
        
        String targetUrl = determineTargetUrl(request, response, authentication);
        
        if (response.isCommitted()) {
            log.debug("Response has already been committed. Unable to redirect to " + targetUrl);
            return;
        }

        clearAuthenticationAttributes(request);
        getRedirectStrategy().sendRedirect(request, response, targetUrl);
    }

    protected String determineTargetUrl(HttpServletRequest request, HttpServletResponse response,
                                      Authentication authentication) {
        
        try {
            OAuth2User oauth2User = (OAuth2User) authentication.getPrincipal();
            String registrationId = extractRegistrationId(request);
            
            AuthResponse authResponse = oauth2Service.processOAuth2User(oauth2User, registrationId);
            
            return UriComponentsBuilder.fromUriString(redirectUri)
                    .queryParam("token", authResponse.getAccessToken())
                    .queryParam("refreshToken", authResponse.getRefreshToken())
                    .queryParam("requiresAdditionalInfo", authResponse.isRequiresAdditionalInfo())
                    .queryParam("tempToken", authResponse.getTempToken())
                    .build().toUriString();
                    
        } catch (Exception e) {
            log.error("OAuth2 authentication success handling failed", e);
            return UriComponentsBuilder.fromUriString(redirectUri)
                    .queryParam("error", URLEncoder.encode("인증 처리 중 오류가 발생했습니다.", StandardCharsets.UTF_8))
                    .build().toUriString();
        }
    }

    private String extractRegistrationId(HttpServletRequest request) {
        String requestUri = request.getRequestURI();
        if (requestUri.contains("/oauth2/code/")) {
            return requestUri.substring(requestUri.lastIndexOf("/") + 1);
        }
        return "unknown";
    }
}