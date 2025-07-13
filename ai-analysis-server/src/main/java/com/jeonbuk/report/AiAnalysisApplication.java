package com.jeonbuk.report;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class AiAnalysisApplication {
    public static void main(String[] args) {
        SpringApplication.run(AiAnalysisApplication.class, args);
    }
}
