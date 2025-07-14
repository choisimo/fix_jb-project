# Spring Boot 프로젝트 구조 및 구현 가이드

## 인증/인가
- JWT 기반 인증 및 Spring Security 적용
- UserService가 UserDetailsService 구현
- 주요 API:
  - `/api/v1/auth/login` (POST): 로그인
  - `/api/v1/auth/register` (POST): 회원가입
  - `/api/v1/auth/oauth2/authorization/{provider}` (GET): OAuth2 로그인
  - `/api/v1/auth/refresh` (POST): 토큰 갱신
  - `/api/v1/auth/logout` (POST): 로그아웃

## 사용자 관리
- UserController, UserService로 CRUD 제공
- 주요 API:
  - `/api/v1/users` (GET): 사용자 목록
  - `/api/v1/users/{id}` (GET/PUT): 사용자 정보/수정
  - `/api/v1/users/{id}/role` (PUT): 권한 변경
  - `/api/v1/users/{id}/toggle-active` (PUT): 활성/비활성 전환

## 신고 관리
- ReportService, ReportController로 CRUD 제공
- 주요 API:
  - `/api/v1/reports` (POST/GET): 신고서 생성/목록
  - `/api/v1/reports/{id}` (GET/PUT/DELETE): 상세/수정/삭제
  - `/api/v1/reports/{id}/comments` (GET/POST): 댓글 관리

## 알림/실시간
- NotificationController, WebSocketConfig로 실시간 알림 제공
- 주요 API:
  - `/api/v1/notifications` (GET): 알림 목록
  - `/ws` (STOMP): 실시간 알림
  - `/topic/notifications`: 브로드캐스트

## AI 분석/라우팅
- AiRoutingController, RoboflowService로 AI 분석/라우팅 제공
- 주요 API:
  - `/api/v1/ai/routing/analyze` (POST): AI 라우팅 분석
  - `/api/v1/ai/analyze/image` (POST): 이미지 분석
  - `/api/v1/ai/analyze/image-async` (POST): 비동기 이미지 분석
  - `/api/v1/ai/analyze/status/{jobId}` (GET): 분석 작업 상태
  - `/api/v1/ai/classes` (GET): 지원 객체 클래스
  - `/api/v1/ai/health` (GET): 헬스체크

## DB 구조
- `database/schema.sql` 참고
- users, reports, report_files, comments, notifications, statuses, categories, user_sessions 등
- PostGIS, JSONB, 트리거/인덱스/제약조건 활용

## 환경설정
- `application.yml`, `.env` : API 키, DB, AI 설정
- Docker Compose로 통합 배포 지원

## 참고 문서
- database/schema.sql
- documents/README.md
