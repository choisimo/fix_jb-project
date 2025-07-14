# **JB Report Platform 코드 문제점 상세 분석 및 수정 요구사항 (PRD)**

**문서 정보**
- **작성일**: 2025-07-13
- **버전**: 1.0
- **작성자**: System Analysis
- **문서 유형**: Product Requirements Document (PRD)
- **우선순위**: CRITICAL

---

## **1. Main API Server 치명적 문제점**

### **1.1 패키지 구조 불일치 문제**
**문제 위치**: `main-api-server/src/main/java/com/jbreport/platform/`
**심각도**: CRITICAL

**문제 상세**:
```java
// AlertController.java:4
import com.jbreport.platform.entity.Alert;  // ❌ 경로 불일치

// 실제 Alert 엔티티 위치
// Path 1: /com/jbreport/platform/entity/Alert.java
// Path 2: /com/jeonbuk/report/domain/entity/Alert.java  ← 실제 사용되는 경로
```

**수정 요구사항**:
1. **패키지 구조 통일**: 모든 컨트롤러에서 `com.jeonbuk.report.domain.entity` 패키지 사용
2. **중복 엔티티 제거**: `com.jbreport.platform.entity` 패키지 전체 삭제
3. **Import 문 수정**: 55개 파일에서 패키지 경로 변경

### **1.2 JPA Auditing 중복 설정**
**문제 위치**: `main-api-server/build.gradle:109`, Configuration 클래스들
**심각도**: CRITICAL

**에러 로그**:
```
Bean 'jpaAuditingHandler' could not be registered. A bean with that name has already been defined
```

**수정 요구사항**:
1. **Configuration 클래스 통합**: JPA Auditing 설정을 단일 Configuration으로 통합
2. **@EnableJpaAuditing 중복 제거**: 여러 Configuration 클래스에서 중복 선언 제거
3. **Bean Definition Override 설정**: `spring.main.allow-bean-definition-overriding=false` 유지

## **2. AI Analysis Server 호환성 문제**

### **2.1 Java 버전 불일치**
**문제 위치**: `ai-analysis-server/build.gradle:11-14`, `ai-analysis-server/Dockerfile:1`
**심각도**: CRITICAL

**문제 상세**:
```gradle
// build.gradle
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)  // ❌ Java 21로 컴파일
    }
}
```

```dockerfile
# Dockerfile
FROM eclipse-temurin:21-jre-alpine  // ❌ 그러나 JAR 파일명 불일치
COPY build/libs/demo-1.0.0.jar app.jar  // ❌ 실제 파일명과 다름
```

**수정 요구사항**:
1. **Java 버전 통일**: AI Analysis Server를 Java 17로 다운그레이드
2. **JAR 파일명 수정**: `demo-1.0.0.jar` → 실제 빌드되는 파일명으로 변경
3. **Docker 이미지 통일**: `eclipse-temurin:17-jre-alpine` 사용

### **2.2 Lombok Builder 미적용**
**문제 위치**: Record 클래스들에서 `@Builder` 어노테이션 사용 시도
**심각도**: HIGH

**문제 상세**:
```java
// CategoryDto.java:40-48
return CategoryResponse.builder()  // ❌ Record 클래스에서 Builder 사용 불가
    .id(category.getId())          // ❌ getId() 메소드 누락
    .name(category.getName())      // ❌ getName() 메소드 누락
```

**수정 요구사항**:
1. **Record를 Class로 변경**: 모든 Response DTO를 일반 클래스로 변경
2. **Lombok 어노테이션 추가**: `@Data`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`
3. **생성자 호출 수정**: Builder 패턴 대신 생성자 직접 호출

## **3. Flutter App 미완성 문제**

### **3.1 핵심 파일 누락**
**문제 위치**: `flutter-app/lib/` 디렉토리
**심각도**: CRITICAL

**누락된 파일들**:
```
lib/core/theme/app_theme.dart                      ❌ 누락
lib/core/utils/app_initializer.dart                ❌ 누락
lib/features/auth/presentation/login_screen.dart   ❌ 누락
lib/features/auth/presentation/register_screen.dart ❌ 누락
lib/features/report/presentation/providers/report_providers.dart ❌ 누락
lib/shared/widgets/error_view.dart                 ❌ 누락
lib/shared/widgets/loading_view.dart               ❌ 누락
... 총 20개 이상 파일 누락
```

**수정 요구사항**:
1. **테마 시스템 구현**: `AppTheme.lightTheme`, `AppTheme.darkTheme` 생성
2. **앱 초기화 로직**: `AppInitializer.initialize()` 메소드 구현
3. **Riverpod Provider 구현**: 모든 상태관리 Provider 생성
4. **공통 위젯 구현**: LoadingView, ErrorView, ReportCard 등 생성
5. **화면 구현**: 모든 Screen 클래스 생성

### **3.2 의존성 버전 충돌**
**문제 위치**: `flutter-app/pubspec.yaml:60`
**심각도**: HIGH

**문제 상세**:
```yaml
dependencies:
  intl: ^0.18.1  # ❌ flutter_localizations와 충돌
  
# Error Message:
# Because jb_report_app depends on flutter_localizations from sdk 
# which depends on intl 0.20.2, intl 0.20.2 is required.
```

**수정 요구사항**:
1. **intl 버전 업그레이드**: `^0.18.1` → `^0.20.2`
2. **의존성 호환성 검증**: 모든 패키지 버전 호환성 확인
3. **pubspec.lock 재생성**: `flutter pub deps`로 의존성 트리 검증

## **4. Docker 설정 문제**

### **4.1 JAR 파일명 불일치**
**문제 위치**: 각 서비스의 Dockerfile
**심각도**: HIGH

**문제 상세**:
```dockerfile
# main-api-server/Dockerfile:14
COPY build/libs/report-platform-*.jar app.jar  # ❌ 실제: report-platform-1.0.0.jar

# ai-analysis-server/Dockerfile:14  
COPY build/libs/demo-1.0.0.jar app.jar        # ❌ 실제: ai-analysis-server-1.0.0.jar
```

**수정 요구사항**:
1. **JAR 파일명 통일**: 각 프로젝트의 실제 빌드 결과물명으로 수정
2. **Build Script 검증**: `./gradlew build` 결과물 확인 후 수정
3. **Docker Build 검증**: 각 이미지 빌드 성공 확인

### **4.2 환경 설정 불일치**
**문제 위치**: `docker-compose.yml`, 각 서비스 설정
**심각도**: MEDIUM

**수정 요구사항**:
1. **DB 사용자 설정**: PostgreSQL 초기 사용자 생성 스크립트 추가
2. **Redis 인증 설정**: 패스워드 설정 통일
3. **네트워크 포트 충돌**: 기존 사용 중인 포트와 충돌 방지

## **5. 우선순위별 수정 계획**

### **Phase 1 (CRITICAL - 즉시 수정 필요)**
1. **Main API Server 패키지 구조 통일**
   - 예상 소요 시간: 1일
   - 담당자: Backend Developer
   - 완료 기준: 빌드 에러 0개, 서비스 정상 기동

2. **AI Analysis Server Java 버전 다운그레이드**
   - 예상 소요 시간: 0.5일
   - 담당자: Backend Developer
   - 완료 기준: Docker 컨테이너 정상 실행

3. **JPA Auditing 중복 설정 해결**
   - 예상 소요 시간: 0.5일
   - 담당자: Backend Developer
   - 완료 기준: Bean 충돌 에러 해결

4. **Docker JAR 파일명 수정**
   - 예상 소요 시간: 0.5일
   - 담당자: DevOps Engineer
   - 완료 기준: 모든 컨테이너 정상 빌드

### **Phase 2 (HIGH - 1주 내 수정)**
1. **Flutter 핵심 파일 구현**
   - 예상 소요 시간: 4일
   - 담당자: Frontend Developer
   - 완료 기준: 앱 빌드 성공, 기본 화면 표시

2. **Lombok Builder 문제 해결**
   - 예상 소요 시간: 2일
   - 담당자: Backend Developer
   - 완료 기준: 모든 DTO 클래스 정상 동작

3. **의존성 버전 충돌 해결**
   - 예상 소요 시간: 1일
   - 담당자: Frontend Developer
   - 완료 기준: flutter pub get 성공

### **Phase 3 (MEDIUM - 2주 내 수정)**
1. **환경 설정 최적화**
   - 예상 소요 시간: 2일
   - 담당자: DevOps Engineer
   - 완료 기준: 모든 환경에서 안정적 실행

2. **테스트 코드 작성**
   - 예상 소요 시간: 2일
   - 담당자: QA Engineer
   - 완료 기준: 단위 테스트 커버리지 80% 이상

3. **문서화 보완**
   - 예상 소요 시간: 1일
   - 담당자: Technical Writer
   - 완료 기준: API 문서, 배포 가이드 완성

## **6. 예상 수정 소요 시간**
- **Phase 1**: 2.5일 (개발자 1명 기준)
- **Phase 2**: 7일 (개발자 2명 기준)  
- **Phase 3**: 5일 (팀 전체 기준)
- **총 소요 시간**: 14.5일

## **7. 수정 완료 후 예상 완성도**
- **현재 완성도**: 28%
- **Phase 1 완료 후**: 45%
- **Phase 2 완료 후**: 75%
- **Phase 3 완료 후**: 90%

## **8. 리스크 및 대응방안**

### **기술적 리스크**
1. **Spring Boot 버전 호환성**: 의존성 충돌 시 버전 다운그레이드 고려
2. **Flutter 상태관리**: Riverpod 복잡성으로 인한 개발 지연 가능
3. **Docker 환경**: 로컬 개발 환경과 운영 환경 차이

### **일정 리스크**
1. **개발자 리소스**: Phase 2에서 Frontend 개발자 집중 투입 필요
2. **테스트 시간**: 통합 테스트로 인한 추가 시간 소요 가능

### **대응방안**
1. **점진적 수정**: Phase별 완료 후 즉시 통합 테스트 실시
2. **백업 계획**: 각 Phase 완료 후 코드 백업 및 롤백 계획 수립
3. **모니터링**: 각 수정 사항의 시스템 영향도 실시간 모니터링

## **9. 성공 기준**
1. **모든 서비스 정상 기동**: Docker Compose로 전체 시스템 실행 성공
2. **API 응답 정상**: 모든 REST API 엔드포인트 200 응답
3. **앱 빌드 성공**: Flutter 앱 APK 빌드 및 설치 성공
4. **기본 기능 동작**: 신고 생성, 조회, 관리 기능 정상 동작

---

**문서 승인**
- **기술 검토**: [ ] 완료
- **프로젝트 매니저 승인**: [ ] 대기
- **최종 승인**: [ ] 대기