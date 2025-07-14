package com.jeonbuk.report.infrastructure.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
public class CorsConfig {
    
    @Value("${app.cors.allowed-origins:http://localhost:*,http://10.0.2.2:*,http://192.168.*:*,http://127.0.0.1:*}")
    private String allowedOrigins;
    
    @Value("${app.cors.allowed-methods:GET,POST,PUT,DELETE,PATCH,OPTIONS}")
    private String allowedMethods;
    
    @Value("${app.cors.allowed-headers:Authorization,Content-Type,X-Requested-With,Accept,Origin,Access-Control-Request-Method,Access-Control-Request-Headers}")
    private String allowedHeaders;
    
    @Value("${app.cors.exposed-headers:Authorization,X-Total-Count}")
    private String exposedHeaders;
    
    @Value("${app.cors.allow-credentials:true}")
    private boolean allowCredentials;
    
    @Value("${app.cors.max-age:3600}")
    private long maxAge;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // 허용할 Origin 설정 (환경 변수로 설정 가능)
        List<String> originPatterns = Arrays.asList(allowedOrigins.split(","));
        configuration.setAllowedOriginPatterns(originPatterns);
        
        // 허용할 HTTP 메서드 (환경 변수로 설정 가능)
        List<String> methods = Arrays.asList(allowedMethods.split(","));
        configuration.setAllowedMethods(methods);
        
        // 허용할 헤더 (환경 변수로 설정 가능)
        List<String> headers = Arrays.asList(allowedHeaders.split(","));
        configuration.setAllowedHeaders(headers);
        
        // 자격 증명 허용 (환경 변수로 설정 가능)
        configuration.setAllowCredentials(allowCredentials);
        
        // 프리플라이트 요청 캐시 시간 (환경 변수로 설정 가능)
        configuration.setMaxAge(maxAge);
        
        // 노출할 헤더 (환경 변수로 설정 가능)
        List<String> exposedHeadersList = Arrays.asList(exposedHeaders.split(","));
        configuration.setExposedHeaders(exposedHeadersList);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        
        return source;
    }
}