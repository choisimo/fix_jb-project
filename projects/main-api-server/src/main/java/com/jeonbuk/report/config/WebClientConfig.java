package com.jeonbuk.report.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * WebClient 설정 클래스
 * GoogleVisionOcrService 및 기타 서비스에서 필요한 WebClient 빈을 제공
 */
@Configuration
public class WebClientConfig {

    /**
     * 기본 WebClient 빈 설정
     * @return WebClient 인스턴스
     */
    @Bean
    public WebClient webClient() {
        return WebClient.builder().build();
    }
}
