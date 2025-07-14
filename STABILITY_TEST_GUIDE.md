# 전북신고 플랫폼 시스템 안정성 테스트 가이드

## 🎯 개요

전북신고 플랫폼의 모든 핵심 서비스에 대해 **최소 5회 이상**의 반복 테스트를 수행하여 시스템 안정성을 평가하는 종합 테스트 시스템입니다.

## 📊 테스트 대상 서비스

### 1. **SMS 인증 서비스** (총 22회 테스트)
- 인증번호 발송: 5회
- 인증번호 확인: 5회  
- 인증 상태 확인: 7회
- 전체 플로우: 5회

### 2. **Email 인증 서비스** (총 28회 테스트)
- 인증번호 발송: 5회
- 인증번호 확인: 5회
- 인증 상태 확인: 6회
- 전체 플로우: 5회
- 다양한 도메인: 7회

### 3. **NICE 실명인증 서비스** (총 28회 테스트)
- 인증 요청 생성: 5회
- 인증 상태 확인: 6회
- 인증 결과 처리: 5회
- 전체 플로우: 5회
- 암호화/복호화: 7회

### 4. **JWT 토큰 서비스** (총 18회 테스트)
- 토큰 생성: 5회
- 토큰 검증: 6회
- Refresh 토큰 관리: 7회

### 5. **사용자 서비스** (총 26회 테스트)
- 회원가입: 5회
- 로그인: 6회
- 정보 조회: 7회
- 정보 업데이트: 8회

### 6. **Redis 캐시 서비스** (총 11회 테스트)
- 연결: 5회
- 기본 CRUD: 6회

### 7. **통합 테스트** (총 133회 종합)
- 전체 서비스 안정성 검증

## 🚀 빠른 시작

### 1. 사전 요구사항
```bash
# Java 17+ 설치 확인
java -version

# PostgreSQL 실행 (Docker 권장)
docker run -d --name postgres-test \
  -e POSTGRES_DB=jeonbuk_report_test \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 postgres:15

# Redis 실행 (Docker 권장)
docker run -d --name redis-test \
  -p 6379:6379 redis:7-alpine
```

### 2. 환경 변수 설정
```bash
export SPRING_PROFILES_ACTIVE=test
export DATABASE_URL=jdbc:postgresql://localhost:5432/jeonbuk_report_test
export DATABASE_USERNAME=postgres
export DATABASE_PASSWORD=password
export REDIS_HOST=localhost
export JWT_SECRET=test-jwt-secret-key-for-stability-testing
```

### 3. 테스트 실행

#### 전체 시스템 안정성 테스트 (권장)
```bash
./scripts/run-stability-tests.sh all
```

#### 개별 서비스 테스트
```bash
# SMS 인증 서비스
./scripts/run-stability-tests.sh sms

# Email 인증 서비스  
./scripts/run-stability-tests.sh email

# NICE 실명인증 서비스
./scripts/run-stability-tests.sh nice

# JWT 토큰 서비스
./scripts/run-stability-tests.sh jwt

# 사용자 서비스
./scripts/run-stability-tests.sh user

# Redis 서비스
./scripts/run-stability-tests.sh redis

# 통합 테스트
./scripts/run-stability-tests.sh integration
```

## 📈 성공 기준

### 안정성 등급 기준
- 🏆 **최우수 (A+)**: 95% 이상
- 🥇 **우수 (A)**: 90% 이상  
- 🥈 **양호 (B+)**: 85% 이상
- 🥉 **보통 (B)**: 80% 이상
- ⚠️ **개선필요 (C)**: 70% 이상
- ❌ **불안정 (D)**: 70% 미만

### 서비스별 최소 기준
- **Redis 서비스**: 95% 이상
- **JWT 토큰 서비스**: 95% 이상
- **사용자 서비스**: 90% 이상
- **SMS 인증**: 80% 이상  
- **Email 인증**: 80% 이상
- **NICE 실명인증**: 85% 이상

## 🔧 Maven/Gradle 직접 실행

### Maven 사용시
```bash
# 전체 안정성 테스트
mvn test -Dtest=IntegratedStabilityTest

# 개별 서비스 테스트
mvn test -Dtest=SmsVerificationStabilityTest
mvn test -Dtest=EmailVerificationStabilityTest
mvn test -Dtest=NiceIdentityVerificationStabilityTest
mvn test -Dtest=JwtTokenServiceStabilityTest
mvn test -Dtest=UserServiceStabilityTest
mvn test -Dtest=RedisServiceStabilityTest
```

### Gradle 사용시
```bash
# 전체 안정성 테스트
./gradlew test --tests IntegratedStabilityTest

# 개별 서비스 테스트
./gradlew test --tests SmsVerificationStabilityTest
./gradlew test --tests EmailVerificationStabilityTest
./gradlew test --tests NiceIdentityVerificationStabilityTest
./gradlew test --tests JwtTokenServiceStabilityTest
./gradlew test --tests UserServiceStabilityTest
./gradlew test --tests RedisServiceStabilityTest
```

## 📋 테스트 결과 분석

### 출력 예시
```
=================================================================
           전북신고 플랫폼 시스템 안정성 종합 결과
=================================================================
테스트 기간: 2025-01-13 14:30:00 ~ 2025-01-13 14:35:20

📊 서비스별 안정성 결과:
-----------------------------------------------------------------
🔹 Redis 서비스: ✅ 우수 (성공률: 95.5%, 테스트: 21/22)
🔹 JWT 토큰 서비스: ✅ 우수 (성공률: 94.4%, 테스트: 17/18)
🔹 사용자 서비스: ✅ 우수 (성공률: 92.3%, 테스트: 24/26)
🔹 SMS 인증 서비스: ⚠️ 양호 (성공률: 86.4%, 테스트: 19/22)
🔹 Email 인증 서비스: ⚠️ 양호 (성공률: 85.7%, 테스트: 24/28)
🔹 NICE 실명인증 서비스: ✅ 우수 (성공률: 89.3%, 테스트: 25/28)

🎯 전체 시스템 안정성 평가:
-----------------------------------------------------------------
총 실행된 테스트: 133 회
성공한 테스트: 120 회
실패한 테스트: 13 회
전체 성공률: 90.23%
총 소요시간: 325.40 초

🏅 시스템 안정성 등급: 🥇 우수 (A)

✅ 모든 서비스가 안정성 기준을 충족했습니다!
```

## 🐛 문제 해결

### 일반적인 문제들

#### 1. 데이터베이스 연결 오류
```bash
# PostgreSQL 컨테이너 상태 확인
docker ps | grep postgres

# 로그 확인
docker logs postgres-test

# 재시작
docker restart postgres-test
```

#### 2. Redis 연결 오류
```bash
# Redis 컨테이너 상태 확인  
docker ps | grep redis

# 연결 테스트
redis-cli ping

# 재시작
docker restart redis-test
```

#### 3. Java 메모리 부족
```bash
# JVM 옵션 설정
export MAVEN_OPTS="-Xmx2g -Xms1g"
export GRADLE_OPTS="-Xmx2g -Xms1g"
```

#### 4. 테스트 시간 초과
```bash
# 타임아웃 설정 증가
export TEST_TIMEOUT=300000  # 5분
```

## 📁 테스트 파일 구조

```
main-api-server/src/test/java/com/jeonbuk/report/test/stability/
├── StabilityTestFramework.java          # 테스트 프레임워크 코어
├── SmsVerificationStabilityTest.java    # SMS 인증 테스트
├── EmailVerificationStabilityTest.java  # Email 인증 테스트  
├── NiceIdentityVerificationStabilityTest.java  # NICE 실명인증 테스트
├── JwtTokenServiceStabilityTest.java    # JWT 토큰 테스트
├── UserServiceStabilityTest.java        # 사용자 서비스 테스트
├── RedisServiceStabilityTest.java       # Redis 캐시 테스트
└── IntegratedStabilityTest.java         # 통합 안정성 테스트
```

## 🎭 목적 및 특징

### 주요 목적
1. **안정성 검증**: 각 서비스가 최소 5회 이상 연속 성공하는지 확인
2. **부하 테스트**: 동시 접근 시 시스템 안정성 검증
3. **성능 측정**: 응답 시간 및 처리량 측정
4. **장애 감지**: 잠재적 문제점 사전 발견

### 핵심 특징
- ⚡ **빠른 실행**: 평균 5-10분 내 완료
- 🔄 **반복 테스트**: 최소 5회 이상 동일 테스트 수행
- 📊 **상세 리포트**: 성공률, 응답시간, 오류 분석
- 🎯 **맞춤 검증**: 서비스별 특성에 맞는 테스트 기준
- 🚀 **자동화**: 스크립트를 통한 완전 자동화

## 🚀 CI/CD 통합

### GitHub Actions 예시
```yaml
name: Stability Tests
on: [push, pull_request]

jobs:
  stability-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: jeonbuk_report_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Run Stability Tests
      run: ./scripts/run-stability-tests.sh all
      env:
        DATABASE_URL: jdbc:postgresql://localhost:5432/jeonbuk_report_test
        DATABASE_USERNAME: postgres
        DATABASE_PASSWORD: password
        REDIS_HOST: localhost
        JWT_SECRET: test-jwt-secret-key
```

이 종합 안정성 테스트 시스템을 통해 전북신고 플랫폼의 모든 서비스가 실제 운영 환경에서 안정적으로 작동할 수 있음을 보장할 수 있습니다.