---
title: 전북 신고 플랫폼 트러블슈팅 가이드
category: deployment
tags: [troubleshooting, errors, solutions, debugging]
version: 1.0
last_updated: 2025-07-13
author: 개발팀
status: approved
---

# 전북 신고 플랫폼 트러블슈팅 가이드

시스템 운영 중 발생할 수 있는 일반적인 문제들과 해결 방법을 안내합니다.

## 🚨 긴급 문제 해결

### 시스템 전체 중단
```bash
# 모든 서비스 상태 확인
docker ps -a
systemctl status docker

# 전체 시스템 재시작
./scripts/stop-all-services.sh
./scripts/start-all-services.sh

# 로그 확인
docker-compose logs -f
```

### 데이터베이스 연결 실패
```bash
# PostgreSQL 상태 확인
docker logs fix_jb-project-postgres-1

# 데이터베이스 재시작
docker-compose restart postgres

# 연결 테스트
psql -h localhost -U postgres -d jbreport
```

## 🔧 API 서버 문제

### 1. 서버 시작 실패

#### 포트 충돌 문제
```bash
# 포트 사용 중인 프로세스 확인
lsof -i :8080
lsof -i :8081

# 프로세스 종료
kill -9 <PID>

# 서버 재시작
cd main-api-server
./gradlew bootRun
```

#### JVM 메모리 부족
```bash
# JVM 옵션 추가
export JAVA_OPTS="-Xmx2g -Xms1g"
java $JAVA_OPTS -jar build/libs/report-platform-1.0.0.jar
```

### 2. API 응답 오류

#### 인증 토큰 오류 (401)
```json
// 오류 응답
{
  "success": false,
  "error": {
    "code": "AUTH_003",
    "message": "토큰이 만료되었습니다"
  }
}
```

**해결 방법**:
```bash
# 토큰 갱신 API 호출
curl -X POST http://localhost:8080/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "your_refresh_token"}'
```

#### 파일 업로드 오류 (413)
```bash
# Nginx 설정 확인 및 수정
nginx.conf:
client_max_body_size 10M;

# Nginx 재시작
sudo systemctl reload nginx
```

### 3. 데이터베이스 쿼리 오류

#### 연결 풀 부족
```yaml
# application.yml 설정 수정
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 10
```

#### 느린 쿼리 최적화
```sql
-- 인덱스 확인
SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;

-- 쿼리 실행 계획 확인
EXPLAIN ANALYZE SELECT * FROM reports WHERE category = 'POTHOLE';
```

## 📱 모바일 앱 문제

### 1. Flutter 빌드 오류

#### Gradle 빌드 실패
```bash
# Gradle 캐시 정리
cd flutter-app
flutter clean
flutter pub get

# Android 빌드 재시도
flutter build apk --debug
```

#### iOS 빌드 오류
```bash
# CocoaPods 업데이트
cd ios
pod install --repo-update

# Xcode 캐시 정리
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### 2. 네트워크 연결 문제

#### API 연결 실패
```dart
// lib/core/network/dio_client.dart
final dio = Dio();
dio.options.connectTimeout = Duration(seconds: 30);
dio.options.receiveTimeout = Duration(seconds: 30);

// 연결 상태 확인
await Connectivity().checkConnectivity();
```

#### SSL 인증서 오류
```dart
// 개발 환경에서 SSL 검증 비활성화 (주의: 운영 환경 금지)
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
  client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  return client;
};
```

## 🤖 AI 분석 서버 문제

### 1. 컴파일 오류

#### Entity getter/setter 누락
```java
// ai-analysis-server/src/main/java/kr/jb/report/ai/entity/AnalysisResult.java
@Entity
@Table(name = "ai_analysis_results")
public class AnalysisResult {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    // getter/setter 메서드 추가 필요
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
}
```

#### Gradle 빌드 오류
```bash
cd ai-analysis-server
./gradlew clean build --stacktrace

# 의존성 충돌 해결
./gradlew dependencyInsight --dependency <library-name>
```

### 2. Roboflow API 연동 문제

#### API 키 설정 오류
```bash
# 환경 변수 확인
echo $ROBOFLOW_API_KEY

# .env 파일 설정
ROBOFLOW_API_KEY=your_api_key_here
ROBOFLOW_WORKSPACE=your_workspace
ROBOFLOW_PROJECT=your_project
```

#### API 응답 오류
```java
// 응답 로깅 추가
@RestController
public class AIAnalysisController {
    private static final Logger logger = LoggerFactory.getLogger(AIAnalysisController.class);
    
    @PostMapping("/analyze")
    public ResponseEntity<?> analyzeImage(@RequestParam MultipartFile file) {
        try {
            // 분석 로직
            logger.info("Image analysis started for file: {}", file.getOriginalFilename());
        } catch (Exception e) {
            logger.error("Analysis failed: ", e);
            return ResponseEntity.status(500).body("분석 실패");
        }
    }
}
```

## 🔄 실시간 시스템 문제

### 1. WebSocket 연결 문제

#### 연결 끊김 현상
```javascript
// 자동 재연결 로직
const ws = new WebSocket('ws://localhost:8080/ws/alerts');
let reconnectInterval = 1000;

ws.onclose = function() {
    setTimeout(() => {
        reconnectWebSocket();
        reconnectInterval = Math.min(reconnectInterval * 2, 30000);
    }, reconnectInterval);
};

function reconnectWebSocket() {
    const newWs = new WebSocket('ws://localhost:8080/ws/alerts');
    // 연결 설정 재적용
}
```

#### CORS 오류
```java
// WebSocketConfig.java
@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(new AlertWebSocketHandler(), "/ws/alerts")
                .setAllowedOrigins("*"); // 운영에서는 특정 도메인만 허용
    }
}
```

### 2. Kafka 메시지 처리 문제

#### 메시지 손실
```yaml
# docker-compose.yml Kafka 설정
kafka:
  environment:
    KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
    KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
    KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'true'
```

#### 컨슈머 지연
```java
// KafkaConsumerConfig.java
@Bean
public ConsumerFactory<String, String> consumerFactory() {
    Map<String, Object> props = new HashMap<>();
    props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
    props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 100);
    props.put(ConsumerConfig.FETCH_MIN_BYTES_CONFIG, 1024);
    return new DefaultKafkaConsumerFactory<>(props);
}
```

## 🐳 Docker 및 인프라 문제

### 1. Docker 컨테이너 문제

#### 컨테이너 시작 실패
```bash
# 로그 확인
docker logs <container_name>

# 볼륨 권한 확인
sudo chown -R 999:999 ./postgres-data

# 포트 바인딩 확인
netstat -tulpn | grep :5432
```

#### 메모리 부족
```yaml
# docker-compose.yml
services:
  postgres:
    mem_limit: 1g
    memswap_limit: 1g
  redis:
    mem_limit: 512m
```

### 2. 네트워크 문제

#### 컨테이너 간 통신 실패
```bash
# 네트워크 확인
docker network ls
docker network inspect fix_jb-project_default

# 컨테이너 IP 확인
docker inspect <container_name> | grep IPAddress
```

#### DNS 해결 문제
```yaml
# docker-compose.yml
services:
  main-api:
    depends_on:
      - postgres
      - redis
    links:
      - postgres:database
      - redis:cache
```

## 📊 성능 문제

### 1. 응답 시간 지연

#### 데이터베이스 최적화
```sql
-- 슬로우 쿼리 확인
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- 인덱스 추가
CREATE INDEX CONCURRENTLY idx_reports_created_at ON reports(created_at);
CREATE INDEX CONCURRENTLY idx_reports_category ON reports(category);
```

#### 캐싱 전략
```java
// Spring Cache 설정
@Cacheable(value = "reports", key = "#category")
public List<Report> getReportsByCategory(String category) {
    return reportRepository.findByCategory(category);
}
```

### 2. 메모리 사용량 증가

#### JVM 힙 덤프 분석
```bash
# 힙 덤프 생성
jcmd <pid> GC.run_finalization
jcmd <pid> VM.classloader_stats

# 메모리 분석 도구 사용
jvisualvm
```

#### 가비지 컬렉션 튜닝
```bash
# JVM 옵션 최적화
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+PrintGC
-XX:+PrintGCDetails
```

## 🔍 로그 분석

### 1. 로그 레벨 설정
```yaml
# application.yml
logging:
  level:
    kr.jb.report: DEBUG
    org.springframework.web: INFO
    org.hibernate.SQL: DEBUG
  pattern:
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
```

### 2. 중요 로그 위치
```bash
# 애플리케이션 로그
./logs/application.log
./logs/error.log

# Docker 로그
docker logs main-api-server
docker logs ai-analysis-server

# 시스템 로그
/var/log/nginx/access.log
/var/log/nginx/error.log
```

## 📞 지원 및 에스컬레이션

### 긴급 상황 연락처
- **시스템 관리자**: sysadmin@jbreport.kr
- **개발팀 리드**: dev-lead@jbreport.kr
- **24시간 지원**: +82-10-XXXX-XXXX

### 이슈 리포팅
1. **GitHub Issues**: 버그 및 기능 요청
2. **Slack #emergency**: 긴급 상황
3. **이메일**: 상세한 기술 문의

### 문제 해결 체크리스트
- [ ] 로그 파일 확인
- [ ] 시스템 리소스 사용량 점검
- [ ] 네트워크 연결 상태 확인
- [ ] 최근 변경사항 검토
- [ ] 백업 데이터 확인
- [ ] 모니터링 대시보드 점검

---

## 📄 관련 문서

- [시스템 모니터링](../monitoring/monitoring-setup.md)
- [로그 관리](../monitoring/log-management.md)
- [백업 및 복구](../production/backup-recovery.md)
- [성능 최적화](../../07-analysis/performance-analysis/optimization-guide.md)
- [보안 가이드](../../08-references/best-practices/security-guidelines.md)

**마지막 업데이트**: 2025-07-13  
**문서 관리자**: DevOps 팀