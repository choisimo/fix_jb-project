---
title: API 명세서
category: service
date: YYYY-MM-DD
version: 1.0
author: 작성자명
last_modified: YYYY-MM-DD
tags: [api, 명세서, 엔드포인트]
status: draft
---

# API 명세서

## 1. API 개요
서비스의 API 목적과 전체 구조를 설명합니다.

## 2. 인증
API 인증 방식을 설명합니다.

```
Authorization: Bearer {access_token}
```

## 3. 공통 응답 형식

### 성공 응답
```json
{
  "success": true,
  "message": "성공 메시지",
  "data": {},
  "timestamp": "2025-07-13T10:00:00Z"
}
```

### 오류 응답
```json
{
  "success": false,
  "message": "오류 메시지",
  "errorCode": "ERROR_CODE",
  "timestamp": "2025-07-13T10:00:00Z"
}
```

## 4. API 엔드포인트

### 4.1 리소스명

#### POST /api/resource
**설명**: 리소스를 생성합니다.

**요청**
```json
{
  "field1": "string",
  "field2": "number"
}
```

**응답**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "field1": "string",
    "field2": "number"
  }
}
```

**상태 코드**
- 201: 생성 성공
- 400: 잘못된 요청
- 401: 인증 실패

## 5. 오류 코드 목록
| 코드 | 메시지 | 설명 |
|------|--------|------|
| E001 | Invalid Request | 잘못된 요청 |
| E002 | Unauthorized | 인증 실패 |