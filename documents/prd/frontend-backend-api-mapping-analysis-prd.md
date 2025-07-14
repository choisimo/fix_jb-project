# JB Platform Frontend-Backend API 매핑 분석 및 통합 PRD

## 📋 문서 개요

| 항목 | 내용 |
|------|------|
| **문서명** | Frontend-Backend API 매핑 분석 및 통합 PRD |
| **작성일** | 2025-07-13 |
| **목적** | Flutter 프론트엔드와 백엔드 서버 간 API 매핑 분석 및 통합 방안 수립 |
| **범위** | Main API Server, AI Analysis Server, Flutter App |
| **우선순위** | High (시스템 통합의 핵심 요소) |
| **상태** | Analysis Complete |

## 🎯 프로젝트 목표

### 주요 목표
1. **API 일관성 확보**: 프론트엔드-백엔드 간 API 인터페이스 표준화
2. **개발 효율성 향상**: 명확한 API 매핑으로 개발 생산성 증대
3. **유지보수성 개선**: 통합된 API 문서화 및 관리 체계 구축
4. **서비스 안정성 강화**: API Gateway 도입으로 서비스 안정성 확보

### 성공 지표
- API 호출 성공률 99% 이상
- API 응답 시간 500ms 이하
- API 문서화 완성도 100%
- 개발자 만족도 90% 이상

## 🏗️ 현재 시스템 아키텍처

### 서버 구조
```
Flutter App (Mobile Client)
    ↓
┌─────────────────────────────────┐
│         API Calls               │
├─────────────────┬───────────────┤
│ Main API Server │ AI Analysis   │
│                 │ Server        │
├─────────────────┼───────────────┤
│ • 인증 관리      │ • AI 분석     │
│ • 리포트 CRUD   │ • OCR 처리    │
│ • 사용자 관리    │ • 이미지 분석 │
│ • 파일 업로드    │ • 라우팅      │
└─────────────────┴───────────────┘
```

### 기술 스택
- **Frontend**: Flutter (Dart)
- **Backend 1**: Spring Boot (Java) - Main API Server
- **Backend 2**: Spring Boot (Java) - AI Analysis Server
- **Communication**: REST API, HTTP/HTTPS

## 📊 API 매핑 현황 분석

### 🔐 인증 관련 API

| 구분 | Flutter API 호출 | Main API Server | AI Analysis Server | 상태 |
|------|------------------|-----------------|-------------------|------|
| **로그인** | `POST /api/auth/login` | ✅ `POST /api/auth/login` | ❌ | ✅ 일치 |
| **회원가입** | `POST /api/auth/register` | ✅ `POST /api/auth/register` | ❌ | ✅ 일치 |
| **토큰 갱신** | `POST /api/auth/refresh` | ✅ `POST /api/auth/refresh` | ❌ | ✅ 일치 |
| **OAuth2 로그인** | `POST /api/auth/oauth2/mobile/{provider}` | ✅ `POST /api/auth/oauth2/mobile/{provider}` | ❌ | ✅ 일치 |
| **로그아웃** | `POST /api/auth/logout` | ✅ `POST /api/auth/logout` | ❌ | ✅ 일치 |
| **사용자 정보** | `GET /api/auth/me` | ✅ `GET /api/auth/me` | ❌ | ✅ 일치 |
| **토큰 검증** | `GET /api/auth/validate` | ✅ `GET /api/auth/validate` | ❌ | ✅ 일치 |

### 📋 리포트 관련 API

| 구분 | Flutter API 호출 | Main API Server | AI Analysis Server | 상태 |
|------|------------------|-----------------|-------------------|------|
| **리포트 생성** | `POST /api/reports` | ✅ `POST /reports` | ❌ | ⚠️ 경로 불일치 |
| **리포트 조회** | `GET /api/reports/{id}` | ✅ `GET /reports/{id}` | ❌ | ⚠️ 경로 불일치 |
| **리포트 목록** | `GET /api/reports` | ✅ `GET /reports` | ❌ | ⚠️ 경로 불일치 |
| **리포트 수정** | `PUT /api/reports/{id}` | ✅ `PUT /reports/{id}` | ❌ | ⚠️ 경로 불일치 |
| **리포트 삭제** | `DELETE /api/reports/{id}` | ✅ `DELETE /reports/{id}` | ❌ | ⚠️ 경로 불일치 |
| **리포트 제출** | `POST /api/reports/{id}/submit` | ❌ | ❌ | ❌ 미구현 |
| **댓글 조회** | `GET /api/reports/{id}/comments` | ❌ | ❌ | ❌ 미구현 |
| **댓글 추가** | `POST /api/reports/{id}/comments` | ❌ | ❌ | ❌ 미구현 |

### 🤖 AI 분석 관련 API

| 구분 | Flutter API 호출 | Main API Server | AI Analysis Server | 상태 |
|------|------------------|-----------------|-------------------|------|
| **이미지 분석** | `POST /api/ai/analyze/image` | ❌ | ✅ `POST /api/v1/ai/analyze/image` | ⚠️ 경로 불일치 |
| **OCR 처리** | `POST /api/ocr/extract` | ❌ | ✅ `POST /api/v1/ocr/extract` | ⚠️ 경로 불일치 |
| **AI 라우팅** | `POST /api/ai/routing/analyze` | ❌ | ✅ `POST /api/v1/ai/routing/analyze` | ⚠️ 경로 불일치 |
| **배치 분석** | `POST /api/ai/analyze/batch-images` | ❌ | ✅ `POST /api/v1/ai/analyze/batch-images` | ⚠️ 경로 불일치 |

### 🔔 알림 관련 API

| 구분 | Flutter API 호출 | Main API Server | AI Analysis Server | 상태 |
|------|------------------|-----------------|-------------------|------|
| **알림 목록** | `GET /api/notifications` | ✅ `NotificationController` | ❌ | ⚠️ 구현 상태 확인 필요 |
| **읽음 처리** | `POST /api/notifications/{id}/read` | ✅ | ❌ | ⚠️ 구현 상태 확인 필요 |
| **설정 업데이트** | `PUT /api/notifications/settings` | ✅ | ❌ | ⚠️ 구현 상태 확인 필요 |

### 👤 사용자 관리 API

| 구분 | Flutter API 호출 | Main API Server | AI Analysis Server | 상태 |
|------|------------------|-----------------|-------------------|------|
| **프로필 조회** | `GET /api/users/profile` | ✅ `UserController` | ✅ `UserController` | ✅ 일치 |
| **프로필 수정** | `PUT /api/users/profile` | ✅ | ✅ | ✅ 일치 |
| **비밀번호 변경** | `POST /api/users/change-password` | ✅ | ✅ | ✅ 일치 |

### 📁 파일 업로드 API

| 구분 | Flutter API 호출 | Main API Server | AI Analysis Server | 상태 |
|------|------------------|-----------------|-------------------|------|
| **파일 업로드** | `POST /api/files/upload` | ✅ `FileController` | ❌ | ✅ 일치 |
| **이미지 업로드** | `POST /api/images/upload` | ❌ | ❌ | ❌ 미구현 |

### 📊 통계 및 관리 API

| 구분 | Flutter API 호출 | Main API Server | AI Analysis Server | 상태 |
|------|------------------|-----------------|-------------------|------|
| **대시보드** | `GET /api/admin/dashboard` | ✅ `AdminController` (추정) | ❌ | ⚠️ 구현 상태 확인 필요 |
| **통계** | `GET /api/admin/statistics` | ✅ `StatisticsController` | ❌ | ✅ 일치 |

## 🚨 주요 이슈 및 문제점

### 1. ❌ API 경로 불일치
#### 리포트 API 경로 차이
- **Flutter 기대값**: `/api/reports`
- **Main API Server 실제값**: `/reports`
- **영향도**: High - 모든 리포트 관련 기능 영향

#### AI 분석 API 버전 차이
- **Flutter 기대값**: `/api/ai`
- **AI Analysis Server 실제값**: `/api/v1/ai`
- **영향도**: High - AI 기능 전체 영향

### 2. ⚠️ 미구현 API
#### 리포트 관련 미구현 기능
- `POST /api/reports/{id}/submit` - 리포트 제출
- `GET /api/reports/{id}/comments` - 댓글 조회
- `POST /api/reports/{id}/comments` - 댓글 추가
- `PUT /api/comments/{id}` - 댓글 수정
- `DELETE /api/comments/{id}` - 댓글 삭제

#### 이미지 업로드 전용 엔드포인트
- `POST /api/images/upload` - 이미지 업로드 전용
- `PUT {uploadUrl}` - 직접 업로드 처리

### 3. 🏗️ 아키텍처 복잡성
#### 서버 분리로 인한 문제
- **두 개의 백엔드 서버**: Main API + AI Analysis
- **복잡한 클라이언트 라우팅**: 서버별 다른 엔드포인트
- **인증 토큰 관리**: 서버 간 토큰 공유 이슈
- **에러 처리**: 서버별 다른 에러 응답 형식

### 4. 📚 문서화 부족
- API 스펙 불일치
- 서버별 개별 문서
- 통합 API 가이드 부재

## 💡 해결 방안

### 1. 🚪 API Gateway 도입

#### 아키텍처 개선안
```
Flutter App
    ↓
API Gateway (Spring Cloud Gateway / Nginx)
    ↓
┌─────────────────┬───────────────┐
│ Main API Server │ AI Analysis   │
│                 │ Server        │
└─────────────────┴───────────────┘
```

#### 장점
- **단일 진입점**: 클라이언트는 하나의 엔드포인트만 관리
- **라우팅 통합**: 경로 기반 서버 라우팅
- **인증 중앙화**: 토큰 검증 및 관리 통합
- **로드 밸런싱**: 트래픽 분산 및 가용성 향상

#### 구현 방안
```yaml
# API Gateway 라우팅 설정 예시
routes:
  - id: auth-route
    uri: http://main-api-server:8080
    predicates:
      - Path=/api/auth/**
  
  - id: reports-route
    uri: http://main-api-server:8080
    predicates:
      - Path=/api/reports/**
    filters:
      - RewritePath=/api/reports/(?<segment>.*), /reports/${segment}
  
  - id: ai-route
    uri: http://ai-analysis-server:8081
    predicates:
      - Path=/api/ai/**
    filters:
      - RewritePath=/api/ai/(?<segment>.*), /api/v1/ai/${segment}
```

### 2. 📐 경로 표준화

#### 표준 경로 체계
```
/api/v1/auth/*          → Main API Server
/api/v1/users/*         → Main API Server  
/api/v1/reports/*       → Main API Server
/api/v1/notifications/* → Main API Server
/api/v1/files/*         → Main API Server
/api/v1/admin/*         → Main API Server
/api/v1/ai/*            → AI Analysis Server
/api/v1/ocr/*           → AI Analysis Server
```

#### 백엔드 수정 필요사항
**Main API Server**
```java
// 현재: @RequestMapping("/reports")
// 변경: @RequestMapping("/api/v1/reports")
@RestController
@RequestMapping("/api/v1/reports")
public class ReportController {
    // ...
}
```

**AI Analysis Server**
```java
// 현재: @RequestMapping("/api/v1/ai")
// 유지: @RequestMapping("/api/v1/ai")
@RestController  
@RequestMapping("/api/v1/ai")
public class AiRoutingController {
    // ...
}
```

### 3. 🔧 미구현 API 완성

#### Phase 1: 리포트 제출 기능
```java
@PostMapping("/{id}/submit")
public ResponseEntity<Report> submitReport(@PathVariable String id) {
    // 리포트 제출 로직 구현
}
```

#### Phase 2: 댓글 시스템
```java
@GetMapping("/{id}/comments")
public ResponseEntity<List<Comment>> getComments(@PathVariable String id) {
    // 댓글 조회 로직
}

@PostMapping("/{id}/comments")  
public ResponseEntity<Comment> addComment(@PathVariable String id, @RequestBody CommentRequest request) {
    // 댓글 추가 로직
}
```

#### Phase 3: 이미지 업로드 전용 엔드포인트
```java
@PostMapping("/images/upload")
public ResponseEntity<ImageUploadResponse> uploadImage(@RequestParam("image") MultipartFile image) {
    // 이미지 업로드 로직
}
```

### 4. 📖 API 문서화 통합

#### OpenAPI 3.0 통합
```yaml
# 통합 API 스펙
openapi: 3.0.0
info:
  title: JB Platform API
  version: 1.0.0
servers:
  - url: https://api.jb-platform.com/api/v1
paths:
  /auth/login:
    post:
      tags: [Authentication]
      # ...
  /reports:
    get:
      tags: [Reports]
      # ...
  /ai/analyze/image:
    post:
      tags: [AI Analysis]
      # ...
```

## 📅 구현 계획

### Phase 1: 경로 표준화 (2주)
#### Week 1
- [ ] Main API Server 경로 수정
- [ ] Flutter 클라이언트 경로 업데이트
- [ ] 기본 테스트 수행

#### Week 2  
- [ ] AI Analysis Server 경로 검증
- [ ] 통합 테스트 수행
- [ ] 문서 업데이트

### Phase 2: API Gateway 구축 (3주)
#### Week 1
- [ ] API Gateway 서버 설정
- [ ] 라우팅 규칙 구성
- [ ] 인증 통합

#### Week 2
- [ ] 로드 밸런싱 설정
- [ ] 에러 처리 표준화
- [ ] 모니터링 구성

#### Week 3
- [ ] 성능 최적화
- [ ] 보안 강화
- [ ] 배포 준비

### Phase 3: 미구현 기능 완성 (4주)
#### Week 1-2: 리포트 기능 완성
- [ ] 리포트 제출 API 구현
- [ ] 상태 관리 로직 추가
- [ ] 권한 검증 구현

#### Week 3-4: 댓글 시스템 구현
- [ ] 댓글 CRUD API 구현
- [ ] 알림 연동
- [ ] 실시간 업데이트

### Phase 4: 통합 테스트 및 배포 (2주)
#### Week 1
- [ ] 전체 시스템 통합 테스트
- [ ] 성능 테스트
- [ ] 보안 테스트

#### Week 2
- [ ] 사용자 인수 테스트
- [ ] 문서 최종 검토
- [ ] 프로덕션 배포

## 📈 성공 지표 및 모니터링

### 기술적 지표
- **API 응답 시간**: 평균 300ms 이하
- **API 성공률**: 99.5% 이상
- **에러율**: 0.5% 이하
- **동시 사용자**: 1,000명 이상 지원

### 비즈니스 지표
- **개발 생산성**: API 개발 시간 50% 단축
- **버그 감소율**: API 관련 버그 70% 감소
- **문서 완성도**: 100% API 문서화
- **개발자 만족도**: 4.5/5.0 이상

### 모니터링 도구
- **APM**: Application Performance Monitoring
- **로그 분석**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **메트릭 수집**: Prometheus + Grafana
- **알림**: Slack/Email 통합

## 🔒 보안 고려사항

### API 보안 강화
- **토큰 기반 인증**: JWT 토큰 표준화
- **CORS 정책**: 적절한 도메인 제한
- **Rate Limiting**: API 호출량 제한
- **입력 검증**: 모든 입력값 검증

### 데이터 보호
- **암호화**: 민감 데이터 암호화
- **HTTPS**: 모든 통신 암호화
- **로그 마스킹**: 민감 정보 로그 제외
- **접근 제어**: 역할 기반 접근 제어

## 🚀 기대 효과

### 개발팀 관점
- **개발 효율성 향상**: 명확한 API 스펙으로 개발 속도 증가
- **버그 감소**: 표준화된 인터페이스로 오류 감소
- **유지보수성 향상**: 통합된 문서와 표준 체계

### 비즈니스 관점
- **서비스 안정성**: API Gateway를 통한 안정적인 서비스 제공
- **확장성**: 마이크로서비스 아키텍처의 유연한 확장
- **개발 비용 절감**: 표준화를 통한 개발 비용 최적화

### 사용자 관점
- **응답 속도 개선**: 최적화된 라우팅으로 빠른 응답
- **서비스 안정성**: 장애 대응 능력 향상
- **기능 완성도**: 미구현 기능 추가로 사용자 경험 개선

## 📋 체크리스트

### 개발 완료 체크리스트
- [ ] API Gateway 구축 완료
- [ ] 모든 경로 표준화 완료
- [ ] 미구현 API 모든 완성
- [ ] 통합 API 문서 완성
- [ ] 자동화 테스트 구축
- [ ] 모니터링 시스템 구축
- [ ] 보안 검증 완료
- [ ] 성능 테스트 통과

### 배포 준비 체크리스트
- [ ] 프로덕션 환경 설정
- [ ] 백업 및 롤백 계획
- [ ] 장애 대응 매뉴얼
- [ ] 운영 가이드 문서
- [ ] 팀 교육 완료

## 📞 연락처 및 책임자

| 역할 | 담당자 | 연락처 |
|------|--------|--------|
| **프로젝트 매니저** | [담당자명] | [이메일] |
| **백엔드 리드** | [담당자명] | [이메일] |
| **프론트엔드 리드** | [담당자명] | [이메일] |
| **DevOps 엔지니어** | [담당자명] | [이메일] |

---

## 🚀 JB Platform 완성을 위한 구현 계획

### 📋 구현 계획 정보

| 항목 | 내용 |
|------|------|
| **문서명** | JB Platform 핵심 기능 구현 계획 |
| **버전** | v2.0 |
| **작성일** | 2025-07-14 |
| **목적** | 기존 코드 유지하며 누락 기능 구현 |

### 🎯 구현 원칙

1. **기존 코드 절대 삭제 금지**
   - 모든 기존 API와 기능은 그대로 유지
   - 새로운 기능은 추가로만 구현
   
2. **하위 호환성 100% 보장**
   - 기존 클라이언트가 정상 동작하도록 보장
   - API 버전 관리를 통한 점진적 전환
   
3. **점진적 마이그레이션**
   - Feature Flag를 통한 단계적 활성화
   - 롤백 가능한 구조로 구현

### 🔧 Backend 구현 계획

#### 1. ReportController 확장
```java
// 기존 엔드포인트 유지하면서 새 기능 추가
@RestController
@RequestMapping("/reports")
public class ReportController {
    // ...existing methods...
    
    // 새로운 제출 API 추가
    @PostMapping("/{id}/submit")
    public ResponseEntity<Report> submitReport(@PathVariable String id) {
        // 구현
    }
}

// V1 API를 위한 새로운 컨트롤러 (기존 것과 병행)
@RestController
@RequestMapping("/api/v1/reports")
public class ReportV1Controller extends ReportController {
    // 상속을 통해 기존 기능 재사용
}
```

#### 2. 댓글 도메인 추가
```java
// 새로운 댓글 엔티티
@Entity
@Table(name = "comments")
public class Comment {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @ManyToOne
    @JoinColumn(name = "report_id")
    private Report report;
    
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User author;
    
    private String content;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

// 댓글 컨트롤러
@RestController
@RequestMapping("/reports/{reportId}/comments")
public class CommentController {
    @GetMapping
    public ResponseEntity<List<Comment>> getComments(@PathVariable String reportId) {
        // 구현
    }
    
    @PostMapping
    public ResponseEntity<Comment> addComment(
        @PathVariable String reportId,
        @RequestBody CommentRequest request
    ) {
        // 구현
    }
}
```

#### 3. API Gateway 경로 호환성 설정
```yaml
# API Gateway 설정 - 기존 경로와 새 경로 모두 지원
spring:
  cloud:
    gateway:
      routes:
        # 기존 경로 유지
        - id: legacy-reports
          uri: http://main-api:8080
          predicates:
            - Path=/reports/**
            
        # 새 경로 추가
        - id: v1-reports
          uri: http://main-api:8080
          predicates:
            - Path=/api/v1/reports/**
          filters:
            - RewritePath=/api/v1/reports/(?<segment>.*), /reports/${segment}
```

### 📱 Flutter 점진적 마이그레이션

#### 1. API 클라이언트 버전 관리
```dart
// 기존 API 클라이언트 유지
class ApiClient {
  // ...existing code...
}

// 새로운 버전의 API 클라이언트 추가
class ApiClientV2 extends ApiClient {
  // 새로운 엔드포인트 지원
  Future<Report> submitReport(String reportId) async {
    return await post('/api/v1/reports/$reportId/submit');
  }
  
  Future<List<Comment>> getComments(String reportId) async {
    return await get('/api/v1/reports/$reportId/comments');
  }
}

// Feature Flag로 버전 전환
class ApiService {
  static ApiClient getClient() {
    if (FeatureFlags.useApiV2) {
      return ApiClientV2();
    }
    return ApiClient();
  }
}
```

#### 2. 권한 관리 래퍼
```dart
// 권한 요청을 추상화하여 플랫폼별 처리
abstract class PermissionService {
  Future<bool> requestCameraPermission();
  Future<bool> requestStoragePermission();
  Future<bool> requestNotificationPermission();
}

// Android 구현
class AndroidPermissionService extends PermissionService {
  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
}

// iOS 구현 (권한 불필요한 경우 자동 승인)
class IOSPermissionService extends PermissionService {
  @override
  Future<bool> requestStoragePermission() async {
    // iOS는 스토리지 권한 불필요
    return true;
  }
}
```

#### 3. Firebase 조건부 활성화
```dart
// Firebase 서비스 래퍼
class NotificationService {
  static bool _useFirebase = false;
  
  static Future<void> initialize() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Firebase.initializeApp();
        _useFirebase = true;
      }
    } catch (e) {
      // Firebase 사용 불가 시 로컬 알림 사용
      _useFirebase = false;
    }
  }
  
  static Future<void> showNotification(String title, String body) async {
    if (_useFirebase) {
      // Firebase 알림
    } else {
      // 로컬 알림 폴백
      await _showLocalNotification(title, body);
    }
  }
}
```

### 📊 구현 우선순위 및 일정

#### Phase 1: 핵심 API 구현 (1주)

| 작업 | 우선순위 | 예상 시간 | 담당 | 상태 |
|------|----------|-----------|------|------|
| Report Submit API | P0 | 8h | Backend | ⏳ |
| Comment CRUD API | P0 | 12h | Backend | ⏳ |
| 댓글 도메인 모델 | P0 | 4h | Backend | ⏳ |
| DB 마이그레이션 | P0 | 2h | Backend | ⏳ |

#### Phase 2: Flutter 연동 (1주)

| 작업 | 우선순위 | 예상 시간 | 담당 | 상태 |
|------|----------|-----------|------|------|
| API Client v2 | P0 | 4h | Frontend | ⏳ |
| 권한 서비스 구현 | P0 | 6h | Frontend | ⏳ |
| Submit 화면 연동 | P0 | 8h | Frontend | ⏳ |
| 댓글 UI 구현 | P1 | 8h | Frontend | ⏳ |

#### Phase 3: 통합 및 안정화 (3일)

| 작업 | 우선순위 | 예상 시간 | 담당 | 상태 |
|------|----------|-----------|------|------|
| E2E 테스트 | P0 | 8h | QA | ⏳ |
| 성능 최적화 | P1 | 4h | 전체 | ⏳ |
| 문서 업데이트 | P1 | 4h | 전체 | ⏳ |

### 🔍 위험 요소 및 대응 방안

#### 기술적 위험

1. **API 버전 충돌**
   - **대응**: URL 패턴으로 버전 구분
   - `/reports` → v0 (기존)
   - `/api/v1/reports` → v1 (신규)

2. **Flutter 권한 이슈**
   - **대응**: 플랫폼별 조건부 처리
   - Fallback UI 제공
   - 권한 거부 시 대체 플로우

3. **Firebase 의존성**
   - **대응**: Feature Flag로 on/off
   - Local notification 대체
   - 오프라인 모드 지원

#### 일정 위험

1. **Backend 개발 지연**
   - **대응**: Mock API 서버 구축
   - Critical path 우선 개발
   - 병렬 개발 가능한 구조

2. **테스트 부족**
   - **대응**: 자동화 테스트 병행
   - QA 조기 참여
   - 단계별 배포 및 검증

### ✅ 완료 기준

#### Backend
- [ ] 모든 API 엔드포인트 구현 완료
- [ ] 통합 테스트 커버리지 80% 이상
- [ ] API 문서 100% 작성
- [ ] 성능 테스트 통과 (응답시간 < 300ms)

#### Frontend
- [ ] 모든 화면 API 연동 완료
- [ ] 권한 요청 플로우 구현
- [ ] 오프라인 모드 지원
- [ ] 크래시 리포트 0건

#### 공통
- [ ] E2E 시나리오 테스트 통과
- [ ] 사용자 매뉴얼 작성
- [ ] 배포 가이드 작성

### 🛠️ 구현 예시 코드

#### Backend: 리포트 제출 API
```java
@PostMapping("/{id}/submit")
@Transactional
public ResponseEntity<Report> submitReport(
    @PathVariable String id,
    @AuthenticationPrincipal UserDetails userDetails
) {
    Report report = reportRepository.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException("Report not found"));
    
    // 권한 검증
    if (!report.getAuthor().getEmail().equals(userDetails.getUsername())) {
        throw new AccessDeniedException("Not authorized");
    }
    
    // 상태 변경
    report.setStatus(ReportStatus.SUBMITTED);
    report.setSubmittedAt(LocalDateTime.now());
    
    Report savedReport = reportRepository.save(report);
    
    // 알림 발송
    notificationService.sendSubmissionNotification(savedReport);
    
    return ResponseEntity.ok(savedReport);
}
```

#### Flutter: 제출 화면 구현
```dart
class ReportSubmitScreen extends StatelessWidget {
  final String reportId;
  
  Future<void> _submitReport(BuildContext context) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );
      
      // API 호출
      final apiClient = ApiService.getClient();
      final report = await apiClient.submitReport(reportId);
      
      // 성공 처리
      Navigator.of(context).pop(); // 로딩 닫기
      Navigator.of(context).pop(report); // 화면 닫기
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리포트가 성공적으로 제출되었습니다.')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 닫기
      
      // 에러 처리
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('제출 실패'),
          content: Text('리포트 제출 중 오류가 발생했습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }
}
```

### 📞 구현 담당자

| 역할 | 담당자 | 책임 |
|------|--------|------|
| **Tech Lead** | - | 전체 아키텍처, 코드 리뷰 |
| **Backend Dev** | - | API 구현, DB 설계 |
| **Frontend Dev** | - | Flutter 개발, UI/UX |
| **QA Engineer** | - | 테스트 계획, 자동화 |

---

**핵심**: 기존 코드를 삭제하지 않고 확장만으로 구현 완성. 하위 호환성 유지하며 점진적 마이그레이션.

**문서 버전**: v2.0  
**최종 업데이트**: 2025-07-14  
**검토자**: [검토자명]  
**승인자**: [승인자명]