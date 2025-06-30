package com.jeonbuk.report;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 전북 신고 플랫폼 메인 애플리케이션
 * 
 * 주요 기능:
 * - 신고서 생성 및 관리
 * - AI 기반 이미지 분석
 * - 실시간 알림 시스템
 * - 사용자 인증 및 권한 관리
 * - 위치 기반 서비스
 */
@SpringBootApplication
@EnableJpaAuditing
@EnableCaching
@EnableAsync
@EnableScheduling
@EnableKafka
public class JeonbukReportPlatformApplication {

  public static void main(String[] args) {
    SpringApplication.run(JeonbukReportPlatformApplication.class, args);
  }
}
