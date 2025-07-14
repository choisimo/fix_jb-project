package com.jbreport.platform.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/actuator")
@RequiredArgsConstructor
public class HealthController implements HealthIndicator {
    
    private final JdbcTemplate jdbcTemplate;
    private final KafkaTemplate<String, String> kafkaTemplate;
    
    @GetMapping("/health")
    public Health getHealth() {
        return health();
    }
    
    @Override
    public Health health() {
        Map<String, Object> details = new HashMap<>();
        
        // Check database
        try {
            jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            details.put("database", "UP");
        } catch (Exception e) {
            details.put("database", "DOWN");
            return Health.down().withDetails(details).build();
        }
        
        // Check Kafka
        try {
            kafkaTemplate.send("health-check", "test").get();
            details.put("kafka", "UP");
        } catch (Exception e) {
            details.put("kafka", "DOWN");
        }
        
        // Add version info
        details.put("version", "1.0.0");
        details.put("service", "main-api-server");
        
        return Health.up().withDetails(details).build();
    }
}
