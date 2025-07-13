# API 전체 개요 및 엔드포인트 매핑

## 🎯 API 아키텍처 개요

전북 신고 플랫폼은 **RESTful API 설계 원칙**을 따르며, **마이크로서비스 간 명확한 책임 분리**를 통해 확장 가능하고 유지보수가 용이한 API 구조를 제공합니다.

## 🏗️ API 서비스 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway Layer                        │
│                 (Load Balancer + Nginx)                     │
└─────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┴─────────────┐
                │                           │
┌─────────────────────────────┐   ┌─────────────────────────────┐
│     Main API Server         │   │   AI Analysis Server        │
│     (Port: 8080)            │   │     (Port: 8081)            │
│                             │   │                             │
│ • 사용자 관리 API            │   │ • 이미지 분석 API            │
│ • 신고 관리 API             │   │ • AI 모델 라우팅 API         │
│ • 인증/권한 API             │   │ • 객체 감지 API             │
│ • 알림 API                  │   │ • 테스트 시나리오 API        │
│ • 파일 관리 API             │   │ • 성능 메트릭 API           │
│ • WebSocket API             │   │                             │
└─────────────────────────────┘   └─────────────────────────────┘
```

## 📋 API 엔드포인트 전체 목록

### Main API Server (Port: 8080)

#### 1. 인증 관리 API
```http
POST   /auth/login                    # 일반 로그인
POST   /auth/oauth/google             # Google OAuth 로그인
POST   /auth/oauth/kakao              # Kakao OAuth 로그인
POST   /auth/refresh                  # 토큰 갱신
POST   /auth/logout                   # 로그아웃
GET    /auth/me                       # 현재 사용자 정보
```

#### 2. 사용자 관리 API
```http
# 사용자 기본 관리
GET    /users/profile                 # 사용자 프로필 조회
PUT    /users/{userId}                # 사용자 정보 수정
DELETE /users/{userId}                # 사용자 삭제
POST   /users/change-password         # 비밀번호 변경

# 관리자 전용
POST   /users/register-admin          # 관리자가 사용자 등록
GET    /users                         # 사용자 목록 조회 (관리자)
GET    /users/stats                   # 사용자 통계
PUT    /users/{userId}/role           # 사용자 권한 변경
```

#### 3. 신고 관리 API
```http
# 신고 CRUD
POST   /reports                       # 신고 생성
GET    /reports                       # 신고 목록 조회 (페이징)
GET    /reports/{reportId}            # 특정 신고 조회
PUT    /reports/{reportId}            # 신고 수정
DELETE /reports/{reportId}            # 신고 삭제

# 신고 파일 관리
POST   /reports/{reportId}/files      # 파일 업로드
GET    /reports/{reportId}/files      # 파일 목록 조회
DELETE /reports/{reportId}/files/{fileId} # 파일 삭제

# 신고 상태 관리
PUT    /reports/{reportId}/status     # 상태 변경
GET    /reports/{reportId}/history    # 상태 변경 이력
POST   /reports/{reportId}/assign     # 담당자 배정

# 신고 부가 기능
POST   /reports/{reportId}/comments   # 댓글 작성
GET    /reports/{reportId}/comments   # 댓글 목록
GET    /reports/stats                 # 신고 통계
GET    /reports/nearby               # 주변 신고 조회
```

#### 4. 알림 관리 API
```http
GET    /notifications                 # 알림 목록 조회
POST   /notifications/{id}/read       # 알림 읽음 처리
DELETE /notifications/{id}            # 알림 삭제
GET    /notifications/unread-count    # 읽지 않은 알림 수
POST   /notifications/batch-read      # 일괄 읽음 처리
```

#### 5. AI 라우팅 API
```http
POST   /ai-routing/analyze            # AI 분석 및 라우팅
POST   /ai-routing/analyze/simple     # 간단 분석
POST   /ai-routing/analyze/batch      # 배치 분석
GET    /ai-routing/health             # AI 서비스 상태
GET    /ai-routing/stats              # AI 분석 통계
GET    /ai-routing/rules              # 라우팅 규칙 조회
```

#### 6. 카테고리 관리 API
```http
GET    /categories                    # 카테고리 목록
POST   /categories                    # 카테고리 생성 (관리자)
PUT    /categories/{categoryId}       # 카테고리 수정 (관리자)
DELETE /categories/{categoryId}       # 카테고리 삭제 (관리자)
```

#### 7. 관리자 API (예정)
```http
# 시스템 설정 관리
GET    /admin/settings                # 시스템 설정 조회
PUT    /admin/settings/{key}          # 설정 값 변경
POST   /admin/settings/api-keys/validate # API 키 유효성 검증
POST   /admin/settings/refresh        # 설정 갱신

# 대시보드 API
GET    /admin/dashboard/stats         # 대시보드 통계
GET    /admin/dashboard/recent-reports # 최근 신고 목록
GET    /admin/dashboard/alerts        # 시스템 알림
```

#### 8. 파일 관리 API
```http
POST   /files/upload                  # 파일 업로드
GET    /files/{fileId}                # 파일 다운로드
GET    /files/{fileId}/thumbnail      # 썸네일 조회
DELETE /files/{fileId}                # 파일 삭제
```

#### 9. WebSocket API
```http
WS     /ws                           # WebSocket 연결
       /topic/reports/{userId}        # 개인 신고 알림
       /topic/admin-alerts           # 관리자 알림
       /topic/system-notifications   # 시스템 공지
```

### AI Analysis Server (Port: 8081, Context: /api/v1)

#### 1. 이미지 분석 API
```http
# 동기 분석
POST   /api/v1/analyze               # 단일 이미지 분석
POST   /api/v1/analyze/batch         # 배치 이미지 분석

# 비동기 분석
POST   /api/v1/analyze/async         # 비동기 분석 시작
GET    /api/v1/analyze/result/{jobId} # 분석 결과 조회
GET    /api/v1/analyze/status/{jobId} # 분석 상태 조회
```

#### 2. 테스트 및 모니터링 API
```http
# 테스트 시나리오
POST   /api/v1/test/{scenario}       # 시나리오별 테스트 분석
GET    /api/v1/test/scenarios        # 지원 시나리오 목록

# 시스템 상태
GET    /api/v1/health                # 서비스 상태 확인
GET    /api/v1/metrics               # 성능 메트릭 조회
GET    /api/v1/classes               # 지원 클래스 목록

# 관리자 기능
GET    /api/v1/admin/stats           # AI 서비스 통계
POST   /api/v1/admin/cache/clear     # 캐시 초기화
```

## 🔐 API 보안 및 인증

### 인증 방식
```
1. JWT Bearer Token 인증
   Authorization: Bearer <jwt_token>

2. OAuth 2.0 (Google, Kakao)
   - 소셜 로그인 시 사용
   - 내부적으로 JWT 토큰 발급

3. API Key 인증 (서버 간 통신)
   X-API-Key: <api_key>
```

### 권한 레벨
```
PUBLIC:    인증 불필요 (로그인, 건강 상태 확인 등)
USER:      일반 사용자 권한 (자신의 신고 관리)
MANAGER:   담당자 권한 (배정된 신고 관리)
ADMIN:     관리자 권한 (전체 시스템 관리)
SYSTEM:    시스템 간 통신 (서버 간 API 호출)
```

### 권한 매트릭스
```
┌─────────────────────┬─────┬──────┬─────────┬───────┐
│      Endpoint       │USER │MANAGER│  ADMIN  │SYSTEM │
├─────────────────────┼─────┼───────┼─────────┼───────┤
│POST /reports        │  ✅  │   ✅   │    ✅    │   ❌   │
│GET /reports (own)   │  ✅  │   ✅   │    ✅    │   ❌   │
│GET /reports (all)   │  ❌  │   ✅   │    ✅    │   ✅   │
│PUT /reports/status  │  ❌  │   ✅   │    ✅    │   ❌   │
│GET /admin/settings  │  ❌  │   ❌   │    ✅    │   ✅   │
│POST /ai-routing/*   │  ❌  │   ❌   │    ✅    │   ✅   │
└─────────────────────┴─────┴───────┴─────────┴───────┘
```

## 📊 API 요청/응답 형식

### 표준 요청 헤더
```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer <jwt_token>
X-Request-ID: <unique_request_id>  # 요청 추적용
X-Client-Version: <client_version>  # 클라이언트 버전
```

### 표준 응답 형식

#### 성공 응답
```json
{
  "success": true,
  "message": "요청이 성공적으로 처리되었습니다.",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "도로 파손 신고",
    "status": "PENDING"
  },
  "meta": {
    "requestId": "req_123456789",
    "timestamp": "2025-07-12T14:30:00Z",
    "version": "v1.0"
  }
}
```

#### 오류 응답
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "입력 데이터가 유효하지 않습니다.",
    "details": [
      {
        "field": "title",
        "message": "제목은 필수 항목입니다."
      },
      {
        "field": "description",
        "message": "설명은 10자 이상이어야 합니다."
      }
    ]
  },
  "meta": {
    "requestId": "req_123456789",
    "timestamp": "2025-07-12T14:30:00Z",
    "version": "v1.0"
  }
}
```

#### 페이징 응답
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "도로 파손 신고"
      }
    ],
    "pageable": {
      "page": 0,
      "size": 20,
      "sort": "createdAt,desc"
    },
    "totalElements": 150,
    "totalPages": 8,
    "first": true,
    "last": false
  }
}
```

## 🔄 API 버전 관리

### 버전 관리 전략
```
URL Path Versioning: /api/v1/reports
Header Versioning: Accept: application/vnd.jeonbuk.v1+json

현재 버전: v1
지원 정책:
- 현재 버전 (v1): 완전 지원
- 이전 버전: 6개월 지원 후 deprecated
- 다음 버전 (v2): 개발 중
```

### API 변경 정책
```
Breaking Changes:
- 메이저 버전 업그레이드 (v1 → v2)
- 최소 3개월 사전 공지
- 마이그레이션 가이드 제공

Non-breaking Changes:
- 마이너 버전 업그레이드 (v1.0 → v1.1)
- 새 필드 추가 (선택적)
- 새 엔드포인트 추가

Patch Changes:
- 버그 수정
- 성능 개선
- 보안 패치
```

## 📈 API 사용량 및 제한

### Rate Limiting
```
일반 사용자:
- 분당 60회 요청
- 시간당 1,000회 요청

관리자:
- 분당 120회 요청
- 시간당 2,000회 요청

시스템 간 통신:
- 제한 없음 (모니터링만)
```

### 사용량 헤더
```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1641024000
```

## 🧪 API 테스트 및 문서화

### API 문서화 도구
```
Swagger UI: /swagger-ui.html
OpenAPI Spec: /api-docs
Postman Collection: /docs/postman/
```

### 테스트 환경
```
Development: https://dev-api.jeonbuk-report.kr
Staging: https://staging-api.jeonbuk-report.kr
Production: https://api.jeonbuk-report.kr
```

### 예제 요청/응답
모든 API 엔드포인트에 대한 상세한 예제는 각 서비스별 API 문서에서 확인할 수 있습니다:

- `apis/user-management.md`
- `apis/report-management.md`
- `apis/ai-routing.md`
- `apis/admin-apis.md`

---

*문서 버전: 1.0*  
*최종 업데이트: 2025년 7월 12일*  
*작성자: API 설계팀*