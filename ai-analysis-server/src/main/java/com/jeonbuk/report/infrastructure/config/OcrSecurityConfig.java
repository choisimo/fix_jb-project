package com.jeonbuk.report.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.SecurityFilterChain;

import java.util.Collection;
import java.util.List;

/**
 * OCR API 보안 설정
 * 사용자 로그인 방식과 관계없이 동일한 보안 정책 적용
 */
@Configuration
@EnableWebSecurity
public class OcrSecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorizeRequests ->
                authorizeRequests
                    // OCR API는 모든 인증된 사용자가 접근 가능
                    .requestMatchers("/api/v1/ocr/**").authenticated()
                    
                    // 사용자 로그인 방식별 구분 없이 JWT 토큰만 검증
                    .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> 
                oauth2.jwt(jwt -> 
                    jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())
                )
            );
        
        return http.build();
    }
    
    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(jwt -> {
            // JWT에서 사용자 정보 추출
            // 로그인 방식(google, kakao, email)과 관계없이 동일하게 처리
            String userId = jwt.getClaimAsString("sub");
            String loginProvider = jwt.getClaimAsString("provider"); // google, kakao, email
            
            // OCR 권한은 로그인 방식과 무관하게 부여
            return createAuthorities(userId, loginProvider);
        });
        return converter;
    }
    
    private Collection<GrantedAuthority> createAuthorities(String userId, String provider) {
        // 모든 로그인 방식에 대해 동일한 OCR 권한 부여
        return List.of(
            new SimpleGrantedAuthority("ROLE_USER"),
            new SimpleGrantedAuthority("ROLE_OCR_USER")  // OCR 사용 권한
        );
    }
}