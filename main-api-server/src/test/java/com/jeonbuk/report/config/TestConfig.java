package com.jeonbuk.report.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;

import static org.mockito.Mockito.mock;

@TestConfiguration
public class TestConfig {
    
    @Bean
    @Primary
    public KafkaTemplate<String, Object> kafkaTemplate() {
        return mock(KafkaTemplate.class);
    }
    
    @Bean
    @Primary
    public RedisTemplate<String, String> redisTemplate() {
        return mock(RedisTemplate.class);
    }
}