package com.jeonbuk.report.infrastructure.config;

import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.kafka.support.serializer.JsonSerializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import org.springframework.kafka.support.SendResult;
import java.util.concurrent.CompletableFuture;
import java.util.HashMap;
import java.util.Map;

/**
 * Development configuration for fallback services
 * Provides in-memory implementations when external services are not available
 */
@Slf4j
@Configuration
@Profile("dev")
public class DevConfig {

    @Value("${kafka.bootstrap-servers:localhost:9092}")
    private String bootstrapServers;
    
    @Value("${spring.redis.host:localhost}")
    private String redisHost;
    
    @Value("${spring.redis.port:6379}")
    private int redisPort;
    
    @Value("${kafka.enabled:true}")
    private boolean kafkaEnabled;
    
    @Value("${redis.enabled:true}")
    private boolean redisEnabled;

    /**
     * Producer factory for development
     */
    @Bean
    @Primary
    @Profile("dev")
    public ProducerFactory<String, Object> devProducerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);
        
        // Development-specific settings for resilience
        configProps.put(ProducerConfig.RETRIES_CONFIG, 1);
        configProps.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, 5000);
        configProps.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, 10000);
        
        return new DefaultKafkaProducerFactory<>(configProps);
    }

    /**
     * Kafka template for development
     */
    @Bean
    @Primary
    @Profile("dev")
    public KafkaTemplate<String, Object> devKafkaTemplate() {
        if (!kafkaEnabled) {
            log.warn("Kafka is disabled in development mode. Messages will be logged instead of sent.");
            return new LoggingKafkaTemplate<>();
        }
        
        KafkaTemplate<String, Object> kafkaTemplate = new KafkaTemplate<>(devProducerFactory());
        
        // KafkaTemplate is ready for development use
        return kafkaTemplate;
    }

    /**
     * Redis connection factory for development
     */
    @Bean
    @Primary
    @Profile("dev")
    public RedisConnectionFactory devRedisConnectionFactory() {
        return new LettuceConnectionFactory(redisHost, redisPort);
    }

    /**
     * Redis template for development
     */
    @Bean
    @Primary
    @Profile("dev")
    public RedisTemplate<String, String> devRedisTemplate() {
        if (!redisEnabled) {
            log.warn("Redis is disabled in development mode. Operations will use in-memory fallback.");
            return new SimpleInMemoryRedisTemplate();
        }
        
        RedisTemplate<String, String> template = new RedisTemplate<>();
        template.setConnectionFactory(devRedisConnectionFactory());
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new StringRedisSerializer());
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(new StringRedisSerializer());
        template.afterPropertiesSet();
        return template;
    }

    /**
     * Logging Kafka Template for development when Kafka is disabled
     */
    private static class LoggingKafkaTemplate<K, V> extends KafkaTemplate<K, V> {
        
        public LoggingKafkaTemplate() {
            super(new DefaultKafkaProducerFactory<>(new HashMap<>()));
        }
        
        @Override
        public CompletableFuture<SendResult<K, V>> send(String topic, K key, V data) {
            log.info("DEV MODE - Kafka message would be sent to topic '{}' with key '{}': {}", topic, key, data);
            return CompletableFuture.completedFuture(null);
        }
        
        @Override
        public CompletableFuture<SendResult<K, V>> send(String topic, V data) {
            log.info("DEV MODE - Kafka message would be sent to topic '{}': {}", topic, data);
            return CompletableFuture.completedFuture(null);
        }
    }

    /**
     * Simple In-Memory Redis Template for development
     */
    private static class SimpleInMemoryRedisTemplate extends RedisTemplate<String, String> {
        
        private final Map<String, String> inMemoryStorage = new HashMap<>();
        
        // Override only essential methods to avoid interface complexity
        public void setInMemory(String key, String value) {
            inMemoryStorage.put(key, value);
            log.debug("DEV MODE - Redis operation: SET {} = {}", key, value);
        }
        
        public String getInMemory(String key) {
            String value = inMemoryStorage.get(key);
            log.debug("DEV MODE - Redis operation: GET {} = {}", key, value);
            return value;
        }
        
        public boolean hasKeyInMemory(String key) {
            return inMemoryStorage.containsKey(key);
        }
        
        public void deleteInMemory(String key) {
            inMemoryStorage.remove(key);
            log.debug("DEV MODE - Redis operation: DELETE {}", key);
        }
    }
}