---
title: 전북 신고 플랫폼 시작 가이드
category: getting-started
tags: [quickstart, setup, installation]
version: 1.0
last_updated: 2025-07-13
author: 개발팀
status: approved
---

# 전북 신고 플랫폼 시작 가이드

전북 신고 플랫폼을 빠르게 시작할 수 있는 종합 가이드입니다.

## 🚀 빠른 시작 (5분 설정)

### 전체 시스템 한 번에 실행
```bash
# 저장소 클론 후 이동
git clone <repository-url>
cd fix_jb-project

# 전체 서비스 시작
./scripts/start-all-services.sh

# 접속 확인
curl http://localhost:8080/actuator/health
```

### 개별 서비스 실행

#### 1단계: 인프라 서비스 시작
```bash
# Docker 컨테이너 시작 (PostgreSQL, Redis, Kafka, Zookeeper)
docker-compose up -d

# 서비스 상태 확인
docker ps
```

#### 2단계: API 서버 실행
```bash
# Main API Server 시작
cd main-api-server
java -jar build/libs/report-platform-1.0.0.jar

# 또는 Gradle로 실행
./gradlew bootRun

# 서버 실행 확인
curl http://localhost:8080/actuator/health
```

#### 3단계: AI 분석 서버 실행 (선택사항)
```bash
# AI Analysis Server 시작
cd ai-analysis-server
./gradlew bootRun

# 서버 확인
curl http://localhost:8081/actuator/health
```

#### 4단계: Flutter 앱 실행 (선택사항)
```bash
cd flutter-app
flutter pub get
flutter run
```

## 💻 시스템 요구사항

### 필수 소프트웨어
- **Java**: 17 이상
- **Flutter**: 3.0 이상 (모바일 앱 개발 시)
- **Docker**: 20.10 이상
- **Docker Compose**: 2.0 이상

### 권장 하드웨어
- **RAM**: 최소 8GB, 권장 16GB
- **Storage**: 최소 10GB 여유 공간
- **CPU**: 4코어 이상

### 개발 환경
- **IDE**: IntelliJ IDEA, VS Code, Android Studio
- **Git**: 2.30 이상
- **Node.js**: 16+ (문서 빌드 시)

## 🌐 접속 정보

### 기본 서비스 포트
| 서비스 | URL | 설명 |
|--------|-----|------|
| Main API Server | http://localhost:8080 | 메인 백엔드 API |
| AI Analysis Server | http://localhost:8081 | AI 이미지 분석 서버 |
| Swagger UI | http://localhost:8080/swagger-ui.html | API 문서 |
| Alert WebSocket | ws://localhost:8080/ws/alerts | 실시간 알림 |

### 데이터베이스 연결
| 서비스 | 정보 |
|--------|------|
| PostgreSQL | localhost:5432/jbreport |
| Redis | localhost:6379 |
| Kafka | localhost:9092 |

## 🔧 환경 설정

### 환경 변수 설정
```bash
# .env 파일 생성
cp .env.example .env

# 필수 환경 변수 설정
export DB_USERNAME=postgres
export DB_PASSWORD=your_password
export JWT_SECRET=your_jwt_secret
export ROBOFLOW_API_KEY=your_roboflow_key
```

### API 키 설정
1. Roboflow API 키 획득
2. OAuth 클라이언트 ID/Secret 설정
3. 파일 저장소 설정 (AWS S3 또는 로컬)

상세한 API 키 설정은 [API 키 설정 가이드](../02-architecture/api-keys-setup.md)를 참조하세요.

## 📋 기본 테스트

### API 테스트
```bash
# 회원가입 테스트
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "테스트 사용자"
  }'

# 로그인 테스트
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 파일 업로드 테스트
```bash
# 이미지 업로드 및 AI 분석
curl -X POST http://localhost:8080/api/v1/reports \
  -H "Authorization: Bearer <your_token>" \
  -F "file=@test_images/pothole_1.jpg" \
  -F "description=도로 파손 신고"
```

## 🎯 주요 기능 체험

### 1. 사용자 인증
- 회원가입/로그인
- OAuth 소셜 로그인 (Google, Kakao)
- JWT 토큰 기반 인증

### 2. 신고 관리
- 이미지 업로드 및 AI 분석
- 위치 정보 기반 신고
- 신고 상태 관리

### 3. 실시간 알림
- WebSocket 연결
- 푸시 알림 (모바일)
- SSE 스트리밍

### 4. 관리자 기능
- 대시보드 접속
- 신고 승인/거부
- 통계 조회

## 🔗 다음 단계

### 개발자용
- [API 명세서](../04-development/api/api-specification.md)
- [백엔드 개발 가이드](../04-development/backend/development-guide.md)
- [Flutter 앱 개발 가이드](../04-development/mobile/flutter-guide.md)

### 운영자용
- [배포 가이드](../05-deployment/production/deployment-guide.md)
- [모니터링 설정](../05-deployment/monitoring/monitoring-setup.md)
- [트러블슈팅](../05-deployment/troubleshooting/common-issues.md)

### 사용자용
- [모바일 앱 사용법](../08-references/user-manual/mobile-app-guide.md)
- [웹 관리자 가이드](../08-references/user-manual/admin-guide.md)

## ❓ 문제 해결

### 자주 발생하는 문제

#### 포트 충돌
```bash
# 포트 사용 중인 프로세스 확인
lsof -i :8080
kill -9 <PID>
```

#### Docker 관련 오류
```bash
# Docker 서비스 재시작
sudo systemctl restart docker
docker-compose down && docker-compose up -d
```

#### 데이터베이스 연결 오류
```bash
# PostgreSQL 상태 확인
docker logs fix_jb-project-postgres-1
```

더 자세한 문제 해결은 [트러블슈팅 가이드](../05-deployment/troubleshooting/common-issues.md)를 참조하세요.

## 📞 지원

- **GitHub Issues**: [프로젝트 이슈 페이지](https://github.com/your-org/fix_jb-project/issues)
- **개발팀 연락처**: dev@example.com
- **긴급 지원**: Slack #jb-platform-support

---

**다음 읽을 자료**: [시스템 아키텍처](../02-architecture/system-overview.md)