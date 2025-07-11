package com.jeonbuk.report.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
public class CorsConfig {

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // 허용할 Origin 설정 (개발 환경)
        configuration.setAllowedOriginPatterns(Arrays.asList(
            "http://localhost:*",
            "http://10.0.2.2:*",
            "http://192.168.*:*",
            "http://127.0.0.1:*"
        ));
        
        // 허용할 HTTP 메서드
        configuration.setAllowedMethods(Arrays.asList(
            "GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"
        ));
        
        // 허용할 헤더
        configuration.setAllowedHeaders(Arrays.asList(
            "Authorization", 
            "Content-Type", 
            "X-Requested-With",
            "Accept",
            "Origin",
            "Access-Control-Request-Method",
            "Access-Control-Request-Headers"
        ));
        
        // 자격 증명 허용
        configuration.setAllowCredentials(true);
        
        // 프리플라이트 요청 캐시 시간 (초)
        configuration.setMaxAge(3600L);
        
        // 노출할 헤더
        configuration.setExposedHeaders(Arrays.asList(
            "Authorization",
            "X-Total-Count"
        ));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        
        return source;
    }
}