package com.jeonbuk.report.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Spring Security 설정
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // CSRF 비활성화 (개발/시연용)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/users/register").permitAll() // 회원가입 허용
                        .requestMatchers("/h2-console/**").permitAll() // H2 콘솔 허용
                        .requestMatchers("/actuator/**").permitAll() // Actuator 허용
                        .anyRequest().authenticated() // 나머지는 인증 필요
                )
                .headers(headers -> headers.frameOptions().disable()); // H2 콘솔 프레임 허용

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
