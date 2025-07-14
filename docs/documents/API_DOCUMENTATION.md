# 전북 신고 플랫폼 API 문서
최종 업데이트: 2025-07-12

## 개요
전북 신고 플랫폼의 RESTful API 문서입니다. 모든 API는 JSON 형식으로 요청/응답하며, 인증이 필요한 엔드포인트는 JWT 토큰을 사용합니다.

## 기본 정보
- **Base URL**: `http://localhost:8080/api/v1`
- **인증 방식**: Bearer Token (JWT)
- **Content-Type**: `application/json`

## 인증 API

### 1. 회원가입
```http
POST /auth/register
```

**요청 본문**:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동",
  "phone": "010-1234-5678",
  "department": "시민"
}
```

**응답**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "홍길동",
    "role": "USER",
    "createdAt": "2025-07-12T10:00:00Z"
  }
}
```

### 2. 로그인
```http
POST /auth/login
```

**요청 본문**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**응답**:
```json
{
  "success": true,
  "data": {
    "accessToken": "jwt-token",
    "refreshToken": "refresh-token",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "홍길동",
      "role": "USER"
    }
  }
}
```

### 3. OAuth2 로그인
```http
GET /oauth2/authorize/{provider}
```
- **provider**: `google` 또는 `kakao`

### 4. 토큰 갱신
```http
POST /auth/refresh
```

**요청 본문**:
```json
{
  "refreshToken": "refresh-token"
}
```

## 리포트 API

### 1. 리포트 생성
```http
POST /reports
Authorization: Bearer {token}
```

**요청 본문**:
```json
{
  "title": "도로 파손 신고",
  "description": "중앙로 사거리 도로 파손",
  "categoryId": "uuid",
  "priority": "HIGH",
  "location": {
    "latitude": 35.8242,
    "longitude": 127.1480,
    "address": "전북 전주시 덕진구 중앙로"
  },
  "fileIds": ["file-uuid-1", "file-uuid-2"]
}
```

### 2. 리포트 목록 조회
```http
GET /reports?page=0&size=20&sort=createdAt,desc
Authorization: Bearer {token}
```

**쿼리 파라미터**:
- `page`: 페이지 번호 (0부터 시작)
- `size`: 페이지 크기
- `sort`: 정렬 기준
- `categoryId`: 카테고리 필터
- `status`: 상태 필터
- `priority`: 우선순위 필터

### 3. 리포트 상세 조회
```http
GET /reports/{reportId}
Authorization: Bearer {token}
```

### 4. 리포트 수정
```http
PUT /reports/{reportId}
Authorization: Bearer {token}
```

### 5. 리포트 삭제
```http
DELETE /reports/{reportId}
Authorization: Bearer {token}
```

### 6. 리포트 상태 변경
```http
PATCH /reports/{reportId}/status
Authorization: Bearer {token}
```

**요청 본문**:
```json
{
  "statusId": 2,
  "reason": "처리 시작"
}
```

## 파일 업로드 API

### 1. 파일 업로드
```http
POST /files/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**요청**:
- `file`: 업로드할 파일 (최대 10MB)
- `type`: 파일 타입 (`IMAGE`, `DOCUMENT`)

**응답**:
```json
{
  "success": true,
  "data": {
    "id": "file-uuid",
    "filename": "image.jpg",
    "url": "/files/file-uuid",
    "size": 1024000,
    "mimeType": "image/jpeg"
  }
}
```

### 2. 파일 다운로드
```http
GET /files/{fileId}
Authorization: Bearer {token}
```

## 댓글 API

### 1. 댓글 작성
```http
POST /reports/{reportId}/comments
Authorization: Bearer {token}
```

**요청 본문**:
```json
{
  "content": "처리 중입니다.",
  "isInternal": false,
  "parentId": null
}
```

### 2. 댓글 목록 조회
```http
GET /reports/{reportId}/comments
Authorization: Bearer {token}
```

### 3. 댓글 수정
```http
PUT /comments/{commentId}
Authorization: Bearer {token}
```

### 4. 댓글 삭제
```http
DELETE /comments/{commentId}
Authorization: Bearer {token}
```

## 카테고리 API

### 1. 카테고리 목록 조회
```http
GET /categories
```

**응답**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "도로 파손",
      "description": "도로 파손 관련 신고",
      "color": "#FF5722",
      "isActive": true
    }
  ]
}
```

## 알림 API

### 1. 알림 목록 조회
```http
GET /notifications
Authorization: Bearer {token}
```

### 2. 알림 읽음 처리
```http
PATCH /notifications/{notificationId}/read
Authorization: Bearer {token}
```

### 3. 실시간 알림 (WebSocket)
```
ws://localhost:8080/ws/notifications
```

**연결 시 헤더**:
```
Authorization: Bearer {token}
```

### 4. SSE 알림 스트림
```http
GET /notifications/stream
Authorization: Bearer {token}
```

## AI 분석 API

### 1. 이미지 분석 요청
```http
POST /ai/analyze/image
Authorization: Bearer {token}
```

**요청 본문**:
```json
{
  "imageUrl": "https://example.com/image.jpg",
  "reportId": "report-uuid"
}
```

**응답**:
```json
{
  "success": true,
  "data": {
    "analysisId": "analysis-uuid",
    "status": "PROCESSING"
  }
}
```

### 2. 분석 결과 조회
```http
GET /ai/analysis/{analysisId}
Authorization: Bearer {token}
```

**응답**:
```json
{
  "success": true,
  "data": {
    "analysisId": "analysis-uuid",
    "status": "COMPLETED",
    "results": {
      "category": "도로 파손",
      "confidence": 0.95,
      "objects": [
        {
          "class": "pothole",
          "confidence": 0.95,
          "bbox": [100, 100, 200, 200]
        }
      ],
      "description": "도로에 큰 구멍이 발견되었습니다."
    }
  }
}
```

## 사용자 API

### 1. 프로필 조회
```http
GET /users/profile
Authorization: Bearer {token}
```

### 2. 프로필 수정
```http
PUT /users/profile
Authorization: Bearer {token}
```

**요청 본문**:
```json
{
  "name": "홍길동",
  "phone": "010-1234-5678",
  "department": "시민"
}
```

### 3. 비밀번호 변경
```http
POST /users/change-password
Authorization: Bearer {token}
```

**요청 본문**:
```json
{
  "currentPassword": "old-password",
  "newPassword": "new-password"
}
```

## 통계 API

### 1. 대시보드 통계
```http
GET /statistics/dashboard
Authorization: Bearer {token}
```

**응답**:
```json
{
  "success": true,
  "data": {
    "totalReports": 150,
    "pendingReports": 45,
    "completedReports": 100,
    "averageProcessingTime": 48,
    "reportsByCategory": {
      "도로 파손": 50,
      "불법 주정차": 30,
      "쓰레기 무단투기": 20
    }
  }
}
```

## 에러 응답

모든 API는 다음과 같은 형식의 에러 응답을 반환합니다:

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "인증이 필요합니다.",
    "details": null
  }
}
```

### 에러 코드
- `BAD_REQUEST`: 잘못된 요청
- `UNAUTHORIZED`: 인증 실패
- `FORBIDDEN`: 권한 없음
- `NOT_FOUND`: 리소스를 찾을 수 없음
- `CONFLICT`: 충돌 (중복 등)
- `INTERNAL_SERVER_ERROR`: 서버 오류

## Swagger UI

API 문서는 Swagger UI를 통해서도 확인할 수 있습니다:
- URL: `http://localhost:8080/swagger-ui.html`

## 인증 토큰 사용 예시

```bash
# 로그인
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# 인증이 필요한 API 호출
curl -X GET http://localhost:8080/api/v1/reports \
  -H "Authorization: Bearer {jwt-token}"
```