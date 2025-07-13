# JB Report Platform - 실제 테스트 가능 환경 구축을 위한 리팩토링 PRD

## 문서 정보
- **작성일**: 2025-07-13
- **문서 버전**: 1.0
- **대상 프로젝트**: JB Report Platform
- **목적**: 실제 테스트 실행 가능한 환경 구축

## 1. 현재 상태 분석 (Critical Issues Found)

### 1.1 빌드 실패 원인
- **패키지 구조 불일치**: 
  - 실제 구조: `com.jeonbuk.report.*`
  - 일부 파일: `com.jbreport.platform.*`
  - 빌드 에러: 53개 컴파일 에러 발생

### 1.2 환경 설정 미완료
- **API 키 누락**: 
  - `ROBOFLOW_API_KEY=your_roboflow_api_key`
  - `OPENROUTER_API_KEY=your_openrouter_api_key`
  - `GOOGLE_CLIENT_ID=your_google_client_id`
  - `KAKAO_CLIENT_ID=your_kakao_client_id`

### 1.3 검증된 실제 상태
- **서버 시작**: ❌ 실패 (빌드 에러)
- **API 테스트**: ❌ 불가능 (서버 미실행)
- **데이터베이스**: ✅ 정상 실행 중
- **Kafka**: ✅ 정상 실행 중
- **Redis**: ✅ 정상 실행 중

## 2. 리팩토링 목표

### 2.1 Primary Goals
1. **빌드 성공**: 모든 컴파일 에러 해결
2. **서버 시작**: API 서버 정상 실행
3. **실제 테스트**: 진짜 API 호출 및 응답 검증
4. **환경 분리**: 개발/테스트/운영 환경 설정

### 2.2 Success Criteria
- [ ] `./gradlew bootRun` 성공
- [ ] API 엔드포인트 200 OK 응답
- [ ] 데이터베이스 연결 확인
- [ ] JWT 인증 동작 확인
- [ ] 파일 업로드 기능 확인

## 3. 리팩토링 계획

### 3.1 Phase 1: 패키지 구조 통일 (High Priority)

#### 3.1.1 Package Structure Standardization
```
Target Structure: com.jeonbuk.report.*

현재 잘못된 구조:
- com.jbreport.platform.* (18개 파일)

목표 구조:
- com.jeonbuk.report.domain.entity.*
- com.jeonbuk.report.domain.repository.*
- com.jeonbuk.report.application.service.*
- com.jeonbuk.report.presentation.controller.*
- com.jeonbuk.report.infrastructure.*
```

#### 3.1.2 필요 작업
1. **패키지 이름 변경**:
   - `com.jbreport.platform` → `com.jeonbuk.report`
   - 모든 import 문 수정
   - 패키지 선언문 수정

2. **파일 이동**:
   - 잘못된 위치의 파일들을 올바른 디렉토리로 이동
   - 중복 파일 제거 또는 병합

3. **의존성 수정**:
   - Import 문 업데이트
   - Bean 참조 수정

### 3.2 Phase 2: 환경 설정 정리 (High Priority)

#### 3.2.1 Development Environment Setup
```properties
# .env.dev (개발용)
# Database Configuration
DATABASE_USERNAME=jbreport
DATABASE_PASSWORD=test_password_123
DATABASE_URL=jdbc:postgresql://localhost:5432/jbreport_dev

# Mock API Keys (개발용)
ROBOFLOW_API_KEY=mock_roboflow_key_for_testing
OPENROUTER_API_KEY=mock_openrouter_key_for_testing
AI_ANALYSIS_ENABLED=false

# OAuth2 (Mock)
GOOGLE_CLIENT_ID=mock_google_client_id
GOOGLE_CLIENT_SECRET=mock_google_secret
```

#### 3.2.2 Test Environment Setup
```properties
# .env.test (테스트용)
# H2 In-Memory Database
DATABASE_URL=jdbc:h2:mem:testdb
DATABASE_USERNAME=sa
DATABASE_PASSWORD=

# Mock Services
EXTERNAL_API_MOCK=true
KAFKA_ENABLED=false
REDIS_ENABLED=false
```

### 3.3 Phase 3: 빌드 및 실행 환경 개선 (Medium Priority)

#### 3.3.1 Gradle Build Improvements
1. **Profile 기반 빌드**:
   ```gradle
   profiles {
       dev {
           activation { activeByDefault = true }
       }
       test {}
       prod {}
   }
   ```

2. **Mock Service Integration**:
   - AI 분석 서비스 Mock 구현
   - 외부 API 호출 Mock 처리
   - 개발 환경용 더미 데이터

#### 3.3.2 Application Profiles
```yaml
# application-dev.yml
spring:
  profiles:
    active: dev
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
  
ai:
  analysis:
    enabled: false
    mock-response: true

external:
  apis:
    mock-enabled: true
```

### 3.4 Phase 4: 테스트 가능한 API 엔드포인트 구현

#### 3.4.1 Core API Endpoints
1. **Health Check API**:
   ```
   GET /api/health
   Response: { "status": "UP", "timestamp": "2025-07-13T10:00:00Z" }
   ```

2. **Authentication API**:
   ```
   POST /api/auth/login
   POST /api/auth/register
   GET /api/auth/me
   ```

3. **Report Management API**:
   ```
   GET /api/reports
   POST /api/reports
   GET /api/reports/{id}
   PUT /api/reports/{id}
   ```

#### 3.4.2 Mock Service Implementation
1. **AI Analysis Mock**:
   ```java
   @Profile("dev")
   @Service
   public class MockAiAnalysisService implements AiAnalysisService {
       public AnalysisResult analyze(MultipartFile image) {
           return AnalysisResult.builder()
               .category("POTHOLE")
               .confidence(0.85)
               .location(new Point(127.123, 35.456))
               .build();
       }
   }
   ```

## 4. 실행 계획

### 4.1 Sprint 1: Package Restructuring (2-3 days)
1. **Day 1**: 패키지 구조 분석 및 매핑 계획
2. **Day 2**: 파일 이동 및 import 수정
3. **Day 3**: 빌드 테스트 및 오류 수정

### 4.2 Sprint 2: Environment Setup (1-2 days)
1. **Day 1**: 환경별 설정 파일 생성
2. **Day 2**: Mock 서비스 구현 및 테스트

### 4.3 Sprint 3: Integration Testing (1-2 days)
1. **Day 1**: API 엔드포인트 테스트
2. **Day 2**: 통합 테스트 및 문서화

## 5. 품질 검증 계획

### 5.1 자동화된 검증
```bash
# 빌드 검증
./gradlew clean build

# 서버 시작 검증
./gradlew bootRun &
sleep 10
curl -f http://localhost:8080/api/health

# API 테스트
./scripts/run-integration-tests.sh
```

### 5.2 수동 검증 체크리스트
- [ ] 모든 Java 파일 컴파일 성공
- [ ] Spring Boot 애플리케이션 시작 성공
- [ ] 데이터베이스 연결 성공
- [ ] Health Check API 200 OK 응답
- [ ] 인증 API 정상 동작
- [ ] 보고서 생성 API 정상 동작
- [ ] 파일 업로드 기능 정상 동작

## 6. 위험 요소 및 대응 방안

### 6.1 High Risk Issues
1. **패키지 이동 시 누락**:
   - 대응: 자동화 스크립트 사용
   - 검증: 컴파일 및 테스트 실행

2. **데이터베이스 스키마 불일치**:
   - 대응: Migration 스크립트 검증
   - 테스트: H2 인메모리 DB로 검증

3. **외부 API 의존성**:
   - 대응: Mock 서비스 우선 구현
   - 실제 API는 별도 테스트

### 6.2 Medium Risk Issues
1. **성능 이슈**:
   - 모니터링: 응답 시간 측정
   - 최적화: 필요시 캐싱 적용

2. **보안 설정**:
   - 검증: 개발 환경 전용 설정 확인
   - 운영: 민감 정보 분리

## 7. 완료 후 기대 효과

### 7.1 개발 생산성 향상
- 빌드 시간 단축 (컴파일 에러 해결)
- 로컬 개발 환경 구축 시간 단축
- 실제 테스트 가능한 환경 제공

### 7.2 품질 보증
- 실제 API 응답 검증 가능
- 통합 테스트 실행 가능
- CI/CD 파이프라인 구축 기반 마련

### 7.3 운영 준비도 향상
- 환경별 설정 분리 완료
- 모니터링 및 로깅 기반 구축
- 실제 배포 가능한 상태 달성

## 8. Next Steps

### 8.1 Immediate Actions (Today)
1. **패키지 구조 분석 완료**
2. **리팩토링 스크립트 작성**
3. **개발 환경 설정 파일 생성**

### 8.2 Short Term (This Week)
1. **전체 리팩토링 실행**
2. **빌드 및 실행 검증**
3. **기본 API 테스트 완료**

### 8.3 Medium Term (Next Week)
1. **통합 테스트 스위트 구축**
2. **문서화 완료**
3. **CI/CD 파이프라인 설정**

---

## 부록

### A. 파일 이동 매핑 테이블
```
Source → Target

com/jbreport/platform/controller/HealthController.java
→ com/jeonbuk/report/presentation/controller/HealthController.java

com/jbreport/platform/controller/AlertController.java  
→ com/jeonbuk/report/presentation/controller/AlertController.java

com/jbreport/platform/service/AlertService.java
→ com/jeonbuk/report/application/service/AlertService.java

com/jbreport/platform/repository/AlertRepository.java
→ com/jeonbuk/report/domain/repository/AlertRepository.java

com/jbreport/platform/entity/Alert.java
→ com/jeonbuk/report/domain/entity/Alert.java
```

### B. 환경 변수 매핑
```
Development:
- 모든 외부 API → Mock
- Database → PostgreSQL (로컬)
- Cache → Redis (로컬)
- File Storage → 로컬 디스크

Test:
- 모든 외부 API → Mock  
- Database → H2 (인메모리)
- Cache → 인메모리
- File Storage → 임시 디렉토리

Production:
- 실제 API 키 사용
- Database → PostgreSQL (RDS)
- Cache → Redis (ElastiCache)  
- File Storage → S3
```

### C. 스크립트 예시
```bash
#!/bin/bash
# 패키지 구조 변경 스크립트

# 1. 패키지 디렉토리 생성
mkdir -p src/main/java/com/jeonbuk/report/presentation/controller
mkdir -p src/main/java/com/jeonbuk/report/application/service
mkdir -p src/main/java/com/jeonbuk/report/domain/repository
mkdir -p src/main/java/com/jeonbuk/report/domain/entity

# 2. 파일 이동
find src -name "*.java" -path "*/jbreport/platform/*" | while read file; do
    target=$(echo $file | sed 's/jbreport\/platform/jeonbuk\/report/')
    mv "$file" "$target"
done

# 3. Import 문 수정
find src -name "*.java" -exec sed -i 's/com.jbreport.platform/com.jeonbuk.report/g' {} \;

echo "패키지 구조 변경 완료"
```

이 PRD를 기반으로 실제 테스트 가능한 환경을 구축할 수 있습니다.