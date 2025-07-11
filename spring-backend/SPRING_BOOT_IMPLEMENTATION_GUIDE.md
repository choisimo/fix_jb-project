# Spring Boot 프로젝트 구조 및 구현 가이드

## 인증/인가
- JWT 기반 인증 및 Spring Security 적용
- UserService가 UserDetailsService 구현
- 주요 API:
  - `/users/login` (POST): 로그인
  - `/users/register` (POST): 회원가입
  - `/users/profile` (GET): 프로필 조회/수정

## 리포트 관리
- ReportService, ReportController로 CRUD 제공
- 주요 API:
  - `/reports` (POST): 보고서 생성
  - `/reports` (GET): 보고서 목록 조회
  - `/reports/{id}` (PUT): 보고서 수정
  - `/reports/{id}` (DELETE): 보고서 삭제

## WebSocket 알림
- WebSocketConfig, NotificationController로 실시간 알림 제공
- 주요 엔드포인트:
  - `/ws` 엔드포인트 (STOMP)
  - `/topic/notifications` 브로드캐스트

## Flutter 연동
- `lib/app/api/api_client.dart`, `websocket_service.dart`로 REST/WebSocket 연동
- 테스트: `test/api_client_test.dart`, `websocket_service_test.dart` 등 통합테스트 제공

## DB 구조
- 상세 스키마는 `database/schema.sql` 참고
- 주요 테이블: users, reports, report_files, comments, notifications 등

## 환경설정
- 환경 변수 및 설정 파일: `application.yml`, `.env` 등
- Docker Compose로 통합 배포 지원

## 참고 문서
- [database/schema.sql](../database/schema.sql)
- [documents/README.md](../documents/README.md)
