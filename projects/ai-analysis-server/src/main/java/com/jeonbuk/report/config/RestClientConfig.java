package com.jeonbuk.report.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import org.springframework.ai.embedding.EmbeddingClient;
import org.springframework.ai.openai.OpenAiEmbeddingClient;
import org.springframework.ai.openai.OpenAiEmbeddingOptions;
import org.springframework.ai.openai.api.OpenAiApi;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.Duration;

/**
 * Configuration for REST clients and JSON handling
 */
@Configuration
public class RestClientConfig {
    
    @Value("${openai.api.key:sk-fake-key}")
    private String openAiApiKey;
    
    @Bean
    public RestTemplate restTemplate() {
        RestTemplate restTemplate = new RestTemplate();
        
        // Configure timeout settings
        HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory();
        factory.setConnectTimeout(30000); // 30 seconds
        factory.setConnectionRequestTimeout(30000); // 30 seconds
        
        restTemplate.setRequestFactory(factory);
        return restTemplate;
    }
    
    @Bean
    public WebClient webClient() {
        return WebClient.builder()
            .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(16 * 1024 * 1024)) // 16MB
            .build();
    }
    
    @Bean
    public EmbeddingClient embeddingClient() {
        // OpenAI API를 사용한 임베딩 클라이언트
        // 실제 운영 환경에서는 올바른 API 키를 설정해야 합니다
        OpenAiApi openAiApi = new OpenAiApi(openAiApiKey);
        return new OpenAiEmbeddingClient(openAiApi);
    }
    
    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.setPropertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);
        return mapper;
    }
}
