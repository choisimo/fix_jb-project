---
title: 전북 신고 플랫폼 API 명세서
category: development
tags: [api, rest, specification, endpoints]
version: 2.0
last_updated: 2025-07-13
author: 백엔드팀
status: approved
---

# 전북 신고 플랫폼 API 명세서

전북 신고 플랫폼의 RESTful API 전체 명세서입니다.

## 📋 기본 정보

### 서버 정보
- **Base URL**: `http://localhost:8080/api/v1`
- **프로덕션 URL**: `https://api.jbreport.kr/api/v1`
- **API 버전**: v1
- **문서 버전**: 2.0

### 인증 방식
- **타입**: Bearer Token (JWT)
- **헤더**: `Authorization: Bearer <token>`
- **토큰 만료**: 24시간 (Access Token), 7일 (Refresh Token)

### 요청/응답 형식
- **Content-Type**: `application/json`
- **Character Set**: UTF-8
- **날짜 형식**: ISO 8601 (YYYY-MM-DDTHH:mm:ssZ)

### 표준 응답 구조
```json
{
  "success": true,
  "data": {
    // 응답 데이터
  },
  "message": "요청이 성공적으로 처리되었습니다",
  "timestamp": "2025-07-13T10:00:00Z"
}
```

### 오류 응답 구조
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "입력 값이 올바르지 않습니다",
    "details": [
      {
        "field": "email",
        "message": "올바른 이메일 형식이 아닙니다"
      }
    ]
  },
  "timestamp": "2025-07-13T10:00:00Z"
}
```

## 🔐 인증 API

### 회원가입
사용자 신규 등록을 처리합니다.

```http
POST /auth/register
Content-Type: application/json
```

**요청 파라미터**:
| 필드 | 타입 | 필수 | 설명 | 예시 |
|------|------|------|------|------|
| email | string | Y | 이메일 주소 | user@example.com |
| password | string | Y | 비밀번호 (8자 이상) | password123 |
| name | string | Y | 사용자 이름 | 홍길동 |
| phone | string | N | 휴대폰 번호 | 010-1234-5678 |
| department | string | N | 소속 부서 | 시민 |

**요청 예시**:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동",
  "phone": "010-1234-5678",
  "department": "시민"
}
```

**응답 예시**:
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "name": "홍길동",
    "role": "USER",
    "createdAt": "2025-07-13T10:00:00Z"
  },
  "message": "회원가입이 완료되었습니다"
}
```

### 로그인
사용자 로그인 및 JWT 토큰 발급을 처리합니다.

```http
POST /auth/login
Content-Type: application/json
```

**요청 파라미터**:
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| email | string | Y | 등록된 이메일 |
| password | string | Y | 비밀번호 |

**요청 예시**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**응답 예시**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "name": "홍길동",
      "role": "USER"
    }
  },
  "message": "로그인이 완료되었습니다"
}
```

### OAuth2 소셜 로그인
Google, Kakao 소셜 로그인을 지원합니다.

```http
GET /oauth2/authorize/{provider}
```

**Path Parameters**:
- `provider`: `google` | `kakao`

**Query Parameters**:
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| redirect_uri | string | Y | 로그인 완료 후 리다이렉트 URL |

### 토큰 갱신
Refresh Token을 사용하여 새로운 Access Token을 발급받습니다.

```http
POST /auth/refresh
Content-Type: application/json
```

**요청 예시**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 로그아웃
현재 세션을 종료하고 토큰을 무효화합니다.

```http
POST /auth/logout
Authorization: Bearer <token>
```

## 📝 신고 관리 API

### 신고 생성
새로운 신고를 등록합니다. 이미지 파일과 함께 전송 가능합니다.

```http
POST /reports
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**요청 파라미터**:
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| title | string | Y | 신고 제목 |
| description | string | Y | 신고 내용 |
| category | string | Y | 신고 분류 (POTHOLE, TRASH, STREETLIGHT 등) |
| latitude | double | Y | 위도 |
| longitude | double | double | 경도 |
| address | string | N | 주소 |
| files | file[] | N | 첨부 이미지 (최대 5개) |

**응답 예시**:
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "title": "도로 파손 신고",
    "description": "인도에 큰 구멍이 생겼습니다",
    "category": "POTHOLE",
    "status": "PENDING",
    "location": {
      "latitude": 35.8219,
      "longitude": 127.1489,
      "address": "전북 전주시 덕진구 덕진동"
    },
    "attachments": [
      {
        "id": "file-uuid",
        "url": "https://storage.example.com/images/pothole_001.jpg",
        "aiAnalysis": {
          "detected": true,
          "confidence": 0.95,
          "type": "pothole"
        }
      }
    ],
    "reporter": {
      "id": "user-uuid",
      "name": "홍길동"
    },
    "createdAt": "2025-07-13T10:00:00Z"
  }
}
```

### 신고 목록 조회
신고 목록을 페이징으로 조회합니다.

```http
GET /reports
Authorization: Bearer <token>
```

**Query Parameters**:
| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| page | int | 0 | 페이지 번호 |
| size | int | 20 | 페이지 크기 |
| category | string | - | 신고 분류 필터 |
| status | string | - | 상태 필터 |
| keyword | string | - | 검색 키워드 |

### 신고 상세 조회
특정 신고의 상세 정보를 조회합니다.

```http
GET /reports/{reportId}
Authorization: Bearer <token>
```

### 신고 수정
신고 내용을 수정합니다. (작성자만 가능)

```http
PUT /reports/{reportId}
Authorization: Bearer <token>
Content-Type: application/json
```

### 신고 삭제
신고를 삭제합니다. (작성자 또는 관리자만 가능)

```http
DELETE /reports/{reportId}
Authorization: Bearer <token>
```

## 👥 사용자 관리 API

### 사용자 프로필 조회
현재 로그인한 사용자의 프로필을 조회합니다.

```http
GET /users/me
Authorization: Bearer <token>
```

### 사용자 프로필 수정
사용자 프로필 정보를 수정합니다.

```http
PUT /users/me
Authorization: Bearer <token>
Content-Type: application/json
```

### 비밀번호 변경
사용자 비밀번호를 변경합니다.

```http
PUT /users/me/password
Authorization: Bearer <token>
Content-Type: application/json
```

## 🔧 관리자 API

### 신고 상태 변경
관리자가 신고의 상태를 변경합니다.

```http
PUT /admin/reports/{reportId}/status
Authorization: Bearer <token>
Content-Type: application/json
```

**요청 예시**:
```json
{
  "status": "APPROVED",
  "comment": "처리 완료되었습니다"
}
```

### 사용자 관리
관리자가 사용자 정보를 관리합니다.

```http
GET /admin/users
PUT /admin/users/{userId}/role
DELETE /admin/users/{userId}
```

### 통계 조회
시스템 통계 정보를 조회합니다.

```http
GET /admin/statistics
Authorization: Bearer <token>
```

## 🚨 실시간 알림 API

### WebSocket 연결
실시간 알림을 위한 WebSocket 연결입니다.

```javascript
const ws = new WebSocket('ws://localhost:8080/ws/alerts');
ws.onmessage = function(event) {
  const alert = JSON.parse(event.data);
  console.log('새 알림:', alert);
};
```

### Server-Sent Events
HTTP 기반 실시간 스트리밍입니다.

```http
GET /events/stream
Authorization: Bearer <token>
Accept: text/event-stream
```

## 📊 공통 응답 코드

### HTTP 상태 코드
| 코드 | 설명 |
|------|------|
| 200 | 성공 |
| 201 | 생성 성공 |
| 400 | 잘못된 요청 |
| 401 | 인증 실패 |
| 403 | 권한 없음 |
| 404 | 리소스 없음 |
| 409 | 중복 데이터 |
| 422 | 유효성 검증 실패 |
| 500 | 서버 오류 |

### 비즈니스 오류 코드
| 코드 | 설명 |
|------|------|
| AUTH_001 | 이메일 중복 |
| AUTH_002 | 잘못된 비밀번호 |
| AUTH_003 | 토큰 만료 |
| REPORT_001 | 파일 크기 초과 |
| REPORT_002 | 지원하지 않는 파일 형식 |
| ADMIN_001 | 관리자 권한 필요 |

## 🔗 관련 문서

- [인증 설정 가이드](../../02-architecture/authentication-setup.md)
- [파일 업로드 설정](../../02-architecture/file-upload-setup.md)
- [실시간 알림 설정](../../04-development/backend/realtime-notifications.md)
- [API 테스트 가이드](../../06-testing/api-testing.md)
- [오류 처리 가이드](../../05-deployment/troubleshooting/api-errors.md)

---

**업데이트 히스토리**:
- v2.0 (2025-07-13): OAuth2 지원 추가, 실시간 알림 API 추가
- v1.1 (2025-07-12): 파일 업로드 API 개선
- v1.0 (2025-07-10): 초기 버전