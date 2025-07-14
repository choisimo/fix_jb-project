package com.jeonbuk.report.infrastructure.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.retry.annotation.EnableRetry;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.web.client.RestTemplate;

import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * 멀티스레딩 및 비동기 처리 설정
 * 
 * UI 스레드 블로킹 방지를 위한 다양한 스레드 풀 설정:
 * - 알림 처리용 스레드 풀
 * - 카프카 발행용 스레드 풀
 * - AI API 호출용 스레드 풀
 * - 일반 비동기 작업용 스레드 풀
 */
@Slf4j
@Configuration
@EnableAsync
@EnableRetry
public class AsyncConfig {

  /**
   * 알림 처리 전용 스레드 풀
   * CPU 집약적인 분석 작업에 최적화
   */
  @Bean("alertProcessingExecutor")
  public Executor alertProcessingExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

    // 코어 스레드 수: CPU 코어 수
    executor.setCorePoolSize(Runtime.getRuntime().availableProcessors());

    // 최대 스레드 수: CPU 코어 수 * 2
    executor.setMaxPoolSize(Runtime.getRuntime().availableProcessors() * 2);

    // 큐 용량: 대기 중인 작업 수
    executor.setQueueCapacity(100);

    // 스레드 이름 접두사
    executor.setThreadNamePrefix("AlertAnalysis-");

    // 스레드 풀 종료 시 대기 시간
    executor.setAwaitTerminationSeconds(60);
    executor.setWaitForTasksToCompleteOnShutdown(true);

    // 거부된 작업 처리 정책: 호출자 스레드에서 실행
    executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());

    executor.initialize();

    log.info("🧵 알림 처리 스레드 풀 초기화 완료 - 코어: {}, 최대: {}",
        executor.getCorePoolSize(), executor.getMaxPoolSize());

    return executor;
  }

  /**
   * 카프카 메시지 발행 전용 스레드 풀
   * I/O 집약적인 작업에 최적화
   */
  @Bean("kafkaPublishingExecutor")
  public Executor kafkaPublishingExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

    // I/O 작업이므로 더 많은 스레드 허용
    executor.setCorePoolSize(5);
    executor.setMaxPoolSize(20);
    executor.setQueueCapacity(200);
    executor.setThreadNamePrefix("KafkaPublish-");
    executor.setAwaitTerminationSeconds(30);
    executor.setWaitForTasksToCompleteOnShutdown(true);

    // 거부된 작업은 큐에 추가 시도
    executor.setRejectedExecutionHandler(new ThreadPoolExecutor.DiscardOldestPolicy());

    executor.initialize();

    log.info("📤 카프카 발행 스레드 풀 초기화 완료 - 코어: {}, 최대: {}",
        executor.getCorePoolSize(), executor.getMaxPoolSize());

    return executor;
  }

  /**
   * AI API 호출 전용 스레드 풀
   * 외부 API 호출의 긴 대기 시간을 고려한 설정
   */
  @Bean("aiApiExecutor")
  public Executor aiApiExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

    // 외부 API 호출이므로 적당한 수의 스레드
    executor.setCorePoolSize(3);
    executor.setMaxPoolSize(10);
    executor.setQueueCapacity(50);
    executor.setThreadNamePrefix("AiApi-");
    executor.setAwaitTerminationSeconds(90); // API 응답 대기 시간 고려
    executor.setWaitForTasksToCompleteOnShutdown(true);

    // 외부 API 오류 시 무시하지 않고 로깅
    executor.setRejectedExecutionHandler((runnable, executor1) -> {
      log.warn("⚠️ AI API 스레드 풀 포화 - 작업 거부됨");
      throw new java.util.concurrent.RejectedExecutionException("AI API thread pool is full");
    });

    executor.initialize();

    log.info("🤖 AI API 스레드 풀 초기화 완료 - 코어: {}, 최대: {}",
        executor.getCorePoolSize(), executor.getMaxPoolSize());

    return executor;
  }

  /**
   * 일반 비동기 작업용 스레드 풀
   * 파일 처리, 이미지 처리 등 무거운 작업용
   */
  @Bean("heavyTaskExecutor")
  public Executor heavyTaskExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

    // 무거운 작업이므로 제한된 스레드 수
    executor.setCorePoolSize(2);
    executor.setMaxPoolSize(6);
    executor.setQueueCapacity(30);
    executor.setThreadNamePrefix("HeavyTask-");
    executor.setAwaitTerminationSeconds(120);
    executor.setWaitForTasksToCompleteOnShutdown(true);

    // 긴 작업이므로 호출자 스레드에서 실행하지 않음
    executor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy());

    executor.initialize();

    log.info("⚙️ 무거운 작업 스레드 풀 초기화 완료 - 코어: {}, 최대: {}",
        executor.getCorePoolSize(), executor.getMaxPoolSize());

    return executor;
  }

  /**
   * 이미지 처리 전용 스레드 풀
   * 메모리 집약적인 이미지 분석에 최적화
   */
  @Bean("imageProcessingExecutor")
  public Executor imageProcessingExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

    // 메모리 사용량을 고려하여 제한적인 스레드 수
    executor.setCorePoolSize(1);
    executor.setMaxPoolSize(3);
    executor.setQueueCapacity(10);
    executor.setThreadNamePrefix("ImageProcess-");
    executor.setAwaitTerminationSeconds(180); // 이미지 처리 시간 고려
    executor.setWaitForTasksToCompleteOnShutdown(true);

    executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());

    executor.initialize();

    log.info("🖼️ 이미지 처리 스레드 풀 초기화 완료 - 코어: {}, 최대: {}",
        executor.getCorePoolSize(), executor.getMaxPoolSize());

    return executor;
  }

  /**
   * RestTemplate Bean (HTTP 클라이언트)
   * 연결 풀링 및 타임아웃 설정 포함
   */
  @Bean
  public RestTemplate restTemplate() {
    RestTemplate restTemplate = new RestTemplate();

    // 연결 타임아웃 및 읽기 타임아웃 설정
    org.springframework.http.client.SimpleClientHttpRequestFactory factory = new org.springframework.http.client.SimpleClientHttpRequestFactory();

    factory.setConnectTimeout(10000); // 10초 연결 타임아웃
    factory.setReadTimeout(30000); // 30초 읽기 타임아웃

    restTemplate.setRequestFactory(factory);

    log.info("🌐 RestTemplate 초기화 완료 - 연결 타임아웃: 10s, 읽기 타임아웃: 30s");

    return restTemplate;
  }

  /**
   * 기본 비동기 실행자 (Spring @Async 기본값)
   */
  @Bean("taskExecutor")
  public Executor taskExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

    executor.setCorePoolSize(4);
    executor.setMaxPoolSize(8);
    executor.setQueueCapacity(100);
    executor.setThreadNamePrefix("DefaultAsync-");
    executor.setAwaitTerminationSeconds(60);
    executor.setWaitForTasksToCompleteOnShutdown(true);

    executor.initialize();

    log.info("🔄 기본 비동기 스레드 풀 초기화 완료");

    return executor;
  }

  /**
   * 스레드 풀 모니터링을 위한 빈
   */
  @Bean
  public ThreadPoolMonitor threadPoolMonitor() {
    return new ThreadPoolMonitor();
  }

  /**
   * 스레드 풀 상태 모니터링 클래스
   */
  public static class ThreadPoolMonitor {

    public void logThreadPoolStatus(ThreadPoolTaskExecutor executor, String poolName) {
      if (executor.getThreadPoolExecutor() != null) {
        ThreadPoolExecutor threadPool = executor.getThreadPoolExecutor();

        log.info("📊 {} 스레드 풀 상태 - " +
            "활성: {}, 풀 크기: {}, 큐 크기: {}, 완료: {}",
            poolName,
            threadPool.getActiveCount(),
            threadPool.getPoolSize(),
            threadPool.getQueue().size(),
            threadPool.getCompletedTaskCount());
      }
    }
  }
}
