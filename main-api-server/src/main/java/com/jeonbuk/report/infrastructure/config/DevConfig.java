package com.jeonbuk.report.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;

import static org.mockito.Mockito.mock;

@Configuration
@Profile("dev")
public class DevConfig {
    
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