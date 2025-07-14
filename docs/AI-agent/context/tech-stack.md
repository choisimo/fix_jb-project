# 기술 스택 및 의존성 관리

## 🛠️ 전체 기술 스택 개요

전북 신고 플랫폼은 **현대적이고 확장 가능한 기술 스택**을 기반으로 구축되었으며, **마이크로서비스 아키텍처**와 **클라우드 네이티브** 원칙을 따릅니다.

## 📋 기술 스택 매트릭스

### Frontend & Mobile
```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│     Framework       │       Version       │       Purpose       │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ Flutter             │ 3.16+               │ Cross-platform App  │
│ Dart                │ 3.2+                │ Programming Language│
│ React.js (예정)     │ 18.x                │ Admin Web UI        │
│ Material Design     │ 3.x                 │ UI Components       │
│ PWA                 │ -                   │ Progressive Web App │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

### Backend Services
```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│     Framework       │       Version       │       Purpose       │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ Spring Boot         │ 3.2.x               │ Main Framework      │
│ Spring Security     │ 6.x                 │ Authentication      │
│ Spring Data JPA     │ 3.2.x               │ Data Access Layer   │
│ Spring WebSocket    │ 6.x                 │ Real-time Updates   │
│ Spring Cloud        │ 2023.0.x (예정)     │ Microservices       │
│ Java                │ 17 (LTS)            │ Programming Language│
│ Maven               │ 3.9+                │ Build Tool          │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

### Database & Storage
```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│     Technology      │       Version       │       Purpose       │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ PostgreSQL          │ 15.x                │ Primary Database    │
│ PostGIS             │ 3.4.x               │ Geospatial Extension│
│ Redis               │ 7.x                 │ Cache & Sessions    │
│ H2 Database         │ 2.x                 │ Testing Database    │
│ Local File System   │ -                   │ File Storage (Dev)  │
│ AWS S3 (예정)       │ -                   │ File Storage (Prod) │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

### Message Queue & Communication
```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│     Technology      │       Version       │       Purpose       │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ Apache Kafka        │ 3.6.x               │ Event Streaming     │
│ WebSocket (STOMP)   │ -                   │ Real-time Messaging │
│ HTTP/REST           │ -                   │ Synchronous API     │
│ Server-Sent Events  │ -                   │ Push Notifications  │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

### External AI Services
```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│     Service         │       API Version   │       Purpose       │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ Roboflow            │ v1                  │ Computer Vision     │
│ OpenRouter          │ v1                  │ LLM Text Analysis   │
│ Google Vision       │ v1 (예정)           │ Image Analysis      │
│ OpenAI GPT          │ v1 (예정)           │ Text Generation     │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

### DevOps & Infrastructure
```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│     Technology      │       Version       │       Purpose       │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ Docker              │ 24.x                │ Containerization    │
│ Docker Compose      │ 2.x                 │ Local Development   │
│ Kubernetes (예정)   │ 1.28+               │ Container Orchestration│
│ Nginx               │ 1.25.x              │ Reverse Proxy       │
│ GitHub Actions      │ -                   │ CI/CD Pipeline      │
│ Prometheus (예정)   │ 2.x                 │ Monitoring          │
│ Grafana (예정)      │ 10.x                │ Visualization       │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

## 📦 서비스별 의존성 관리

### Main API Server (main-api-server/pom.xml)

#### Core Dependencies
```xml
<dependencies>
    <!-- Spring Boot Starters -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        <version>3.2.x</version>
    </dependency>
    
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
        <version>3.2.x</version>
    </dependency>
    
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
        <version>3.2.x</version>
    </dependency>
    
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-websocket</artifactId>
        <version>3.2.x</version>
    </dependency>
    
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-oauth2-client</artifactId>
        <version>3.2.x</version>
    </dependency>
    
    <!-- Database Drivers -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <version>42.7.x</version>
    </dependency>
    
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-redis</artifactId>
        <version>3.2.x</version>
    </dependency>
    
    <!-- Geospatial Support -->
    <dependency>
        <groupId>org.hibernate</groupId>
        <artifactId>hibernate-spatial</artifactId>
        <version>6.4.x</version>
    </dependency>
    
    <!-- Kafka Integration -->
    <dependency>
        <groupId>org.springframework.kafka</groupId>
        <artifactId>spring-kafka</artifactId>
        <version>3.1.x</version>
    </dependency>
    
    <!-- JWT Support -->
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.12.x</version>
    </dependency>
    
    <!-- Validation -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
        <version>3.2.x</version>
    </dependency>
    
    <!-- API Documentation -->
    <dependency>
        <groupId>org.springdoc</groupId>
        <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
        <version>2.2.x</version>
    </dependency>
    
    <!-- Utility Libraries -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.x</version>
        <scope>provided</scope>
    </dependency>
    
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.16.x</version>
    </dependency>
    
    <!-- Testing -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <version>3.2.x</version>
        <scope>test</scope>
    </dependency>
    
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>postgresql</artifactId>
        <version>1.19.x</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

#### Build Configuration
```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <version>3.2.x</version>
            <configuration>
                <excludes>
                    <exclude>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                    </exclude>
                </excludes>
            </configuration>
        </plugin>
        
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.11.x</version>
            <configuration>
                <source>17</source>
                <target>17</target>
            </configuration>
        </plugin>
        
        <!-- Jacoco for Test Coverage -->
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.8.x</version>
        </plugin>
    </plugins>
</build>
```

### AI Analysis Server (ai-analysis-server/build.gradle)

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.2.x'
    id 'io.spring.dependency-management' version '1.1.x'
    id 'jacoco'
}

java {
    sourceCompatibility = '17'
}

dependencies {
    // Spring Boot Core
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    
    // Database
    runtimeOnly 'org.postgresql:postgresql'
    implementation 'org.springframework.boot:spring-boot-starter-data-redis'
    
    // HTTP Client for External APIs
    implementation 'org.springframework.boot:spring-boot-starter-webflux'
    implementation 'org.apache.httpcomponents.client5:httpclient5:5.2.x'
    
    // JSON Processing
    implementation 'com.fasterxml.jackson.core:jackson-databind'
    implementation 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310'
    
    // Async & Retry
    implementation 'org.springframework.retry:spring-retry'
    implementation 'org.springframework:spring-aspects'
    
    // Lombok
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    
    // API Documentation
    implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.2.x'
    
    // Testing
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.testcontainers:junit-jupiter'
    testImplementation 'org.testcontainers:postgresql'
    testImplementation 'com.github.tomakehurst:wiremock-jre8:2.35.x'
}

test {
    useJUnitPlatform()
    finalizedBy jacocoTestReport
}

jacocoTestReport {
    dependsOn test
    reports {
        xml.required = true
        html.required = true
    }
}
```

### Flutter Client (pubspec.yaml)

```yaml
name: jeonbuk_report_platform
description: 전북 신고 플랫폼 모바일 앱
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  riverpod: ^2.4.9
  
  # HTTP & Networking
  http: ^1.1.2
  dio: ^5.4.0
  web_socket_channel: ^2.4.0
  
  # Image & Camera
  image_picker: ^1.0.4
  camera: ^0.10.5
  image: ^4.1.3
  
  # Location & Maps
  geolocator: ^10.1.0
  google_maps_flutter: ^2.5.0
  location: ^5.0.3
  
  # Storage & Cache
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1
  
  # Authentication
  google_sign_in: ^6.1.5
  kakao_flutter_sdk: ^1.7.0
  
  # UI Components
  cupertino_icons: ^1.0.6
  material_design_icons_flutter: ^7.0.7296
  flutter_svg: ^2.0.7
  cached_network_image: ^3.3.0
  
  # Utilities
  intl: ^0.18.1
  uuid: ^4.1.0
  url_launcher: ^6.2.1
  permission_handler: ^11.0.1
  
  # Notifications
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.2.0
  
  # Development Tools
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  
  # Testing
  mockito: ^5.4.2
  integration_test:
    sdk: flutter
  
  # Linting
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/config/
  
  fonts:
    - family: NotoSansKR
      fonts:
        - asset: assets/fonts/NotoSansKR-Regular.ttf
        - asset: assets/fonts/NotoSansKR-Bold.ttf
          weight: 700
```

## 🔧 환경별 설정 관리

### 개발 환경 (application-dev.yml)
```yaml
spring:
  profiles:
    active: dev
  
  datasource:
    url: jdbc:postgresql://localhost:5432/jeonbuk_report_dev
    username: postgres
    password: password
  
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  
  data:
    redis:
      host: localhost
      port: 6379

logging:
  level:
    com.jeonbuk.report: DEBUG
    org.springframework.security: DEBUG
    org.hibernate.SQL: DEBUG

app:
  roboflow:
    api-key: dev-roboflow-key
  openrouter:
    api:
      key: dev-openrouter-key

# Mock 서비스 활성화
mock:
  enabled: true
  roboflow: true
  openrouter: true
```

### 테스트 환경 (application-test.yml)
```yaml
spring:
  profiles:
    active: test
  
  datasource:
    url: jdbc:h2:mem:testdb;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE
    driver-class-name: org.h2.Driver
  
  jpa:
    hibernate:
      ddl-auto: create-drop
    database-platform: org.hibernate.dialect.H2Dialect
  
  data:
    redis:
      host: localhost
      port: 16379  # 테스트용 Redis 포트

# 테스트용 설정
testcontainers:
  reuse:
    enable: true

app:
  jwt:
    secret: test-secret-key-for-testing-only
  roboflow:
    api-key: test-roboflow-key
  openrouter:
    api:
      key: test-openrouter-key
```

### 운영 환경 (application-prod.yml)
```yaml
spring:
  profiles:
    active: prod
  
  datasource:
    url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
  
  data:
    redis:
      host: ${REDIS_HOST}
      port: ${REDIS_PORT}
      password: ${REDIS_PASSWORD}
      ssl: true

logging:
  level:
    com.jeonbuk.report: INFO
    org.springframework.security: WARN
    org.hibernate.SQL: WARN
  
  file:
    name: /var/log/jeonbuk-report/application.log
    max-size: 100MB
    max-history: 30

# 운영 환경 보안 설정
server:
  ssl:
    enabled: true
    key-store: ${SSL_KEYSTORE_PATH}
    key-store-password: ${SSL_KEYSTORE_PASSWORD}

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: never
```

## 🔒 보안 의존성 관리

### 취약점 스캔 도구
```xml
<!-- OWASP Dependency Check -->
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>8.4.x</version>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
        <skipTestScope>true</skipTestScope>
    </configuration>
</plugin>

<!-- Snyk Vulnerability Scanner -->
<plugin>
    <groupId>io.snyk</groupId>
    <artifactId>snyk-maven-plugin</artifactId>
    <version>2.2.x</version>
</plugin>
```

### 보안 라이브러리
```xml
<!-- JWT 보안 -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.x</version>
    <scope>runtime</scope>
</dependency>

<!-- 암호화 -->
<dependency>
    <groupId>org.bouncycastle</groupId>
    <artifactId>bcprov-jdk18on</artifactId>
    <version>1.76</version>
</dependency>

<!-- Rate Limiting -->
<dependency>
    <groupId>com.github.vladimir-bukhtoyarov</groupId>
    <artifactId>bucket4j-core</artifactId>
    <version>7.6.x</version>
</dependency>
```

## 📊 모니터링 및 관찰성

### APM 도구
```xml
<!-- Micrometer for Metrics -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
    <version>1.12.x</version>
</dependency>

<!-- Zipkin for Distributed Tracing -->
<dependency>
    <groupId>io.zipkin.brave</groupId>
    <artifactId>brave-spring-boot-starter</artifactId>
    <version>5.17.x</version>
</dependency>

<!-- Actuator for Health Checks -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
    <version>3.2.x</version>
</dependency>
```

### 로깅 설정
```xml
<!-- Logback Configuration -->
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>7.4</version>
</dependency>

<!-- Structured Logging -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.16.x</version>
</dependency>
```

## 🔄 버전 관리 전략

### Semantic Versioning
```
MAJOR.MINOR.PATCH
예: 1.2.3

MAJOR: 호환되지 않는 API 변경
MINOR: 하위 호환되는 새 기능 추가
PATCH: 하위 호환되는 버그 수정
```

### 의존성 업데이트 정책
```
Critical Security Updates: 즉시 적용
Major Version Updates: 분기별 검토
Minor Version Updates: 월간 검토
Patch Updates: 주간 검토
```

### Maven/Gradle 버전 관리
```xml
<!-- Maven Versions Plugin -->
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>versions-maven-plugin</artifactId>
    <version>2.16.x</version>
</plugin>
```

```groovy
// Gradle Versions Plugin
plugins {
    id 'com.github.ben-manes.versions' version '0.49.x'
}
```

---

*문서 버전: 1.0*  
*최종 업데이트: 2025년 7월 12일*  
*작성자: 기술 아키텍처 팀*