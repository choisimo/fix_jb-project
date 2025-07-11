# 전북 현장 신고 플랫폼

## 프로젝트 구조
- **flutter-app/** : Flutter 모바일 앱 (신고, 인증, AI 분석, 지도, 알림)
- **main-api-server/** : Spring Boot 통합 API 서버 (인증, 사용자, 신고, 알림, WebSocket)
- **ai-analysis-server/** : AI 이미지 분석/라우팅 서버 (Roboflow, OpenRouter, OCR)
- **database/** : PostgreSQL DB 스키마 및 초기화
- **run_demo.sh** : 통합 실행/테스트 스크립트

## 주요 기능
- 사용자 인증/인가 (JWT, OAuth2, Google/Kakao)
- 신고서 CRUD, 상태 변경, 댓글, 권한 기반 접근제어
- AI 이미지 분석, 객체 탐지, OCR, 라우팅
- 실시간/푸시 알림 (WebSocket, Kafka, FCM)
- 지도(Naver Map), 위치 기반 서비스
- 운영/배포 자동화 (Docker Compose, run_demo.sh)

## 주요 API 엔드포인트
- `/api/v1/auth/*` : 인증/회원가입/로그인/OAuth
- `/api/v1/reports` : 신고서 목록/생성/상세/수정/삭제
- `/api/v1/users` : 사용자 정보/수정/권한
- `/api/v1/notifications` : 알림 목록/수신
- `/api/v1/ai/*` : AI 분석/라우팅/상태/클래스/헬스체크
- `/api/v1/alerts/*` : AI 기반 알림 분석/배치/헬스체크

## 실행 방법
```bash
# 전체 시스템 실행
./run_demo.sh

# 개별 실행
cd main-api-server && ./gradlew bootRun  # API 서버(8080)
cd ai-analysis-server && ./gradlew bootRun  # AI 서버(8081)
cd flutter-app && flutter run  # 모바일 앱
```

## 환경설정
- `.env`, `application.yml` : API 키, DB, AI 설정
- `database/schema.sql` : DB 테이블/스키마

## 참고 문서
- QUICK_START_GUIDE.md, RUN_INSTRUCTIONS.md, IMPLEMENTATION_SUMMARY.md
- SPRING_BOOT_IMPLEMENTATION_GUIDE.md, AI_ROUTER_SPECIFICATION.md
