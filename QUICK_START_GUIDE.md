# 전북 신고 플랫폼 빠른 실행 가이드

## 🚀 빠른 시작

### 1단계: 인프라 서비스 시작
```bash
# Docker 컨테이너 시작 (PostgreSQL, Redis, Kafka, Zookeeper)
docker-compose up -d

# 서비스 상태 확인
docker ps
```

### 2단계: 백엔드 서버 실행
```bash
# Main API Server 시작
cd main-api-server
java -jar build/libs/report-platform-1.0.0.jar

# 서버 실행 확인
curl http://localhost:8080/actuator/health
```

### 3단계: API 테스트
```bash
# Swagger UI 접속
open http://localhost:8080/swagger-ui.html

# 회원가입 테스트
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "테스트 사용자"
  }'
```

### 4단계: Flutter 앱 실행 (선택사항)
```bash
cd flutter-app
flutter pub get
flutter run
```

## 📋 주요 엔드포인트

| 기능 | 메서드 | URL | 설명 |
|------|--------|-----|------|
| 회원가입 | POST | `/api/v1/auth/register` | 새 사용자 등록 |
| 로그인 | POST | `/api/v1/auth/login` | 사용자 로그인 |
| 리포트 목록 | GET | `/api/v1/reports` | 신고 목록 조회 |
| 리포트 생성 | POST | `/api/v1/reports` | 새 신고 작성 |
| 파일 업로드 | POST | `/api/v1/files/upload` | 이미지 업로드 |

## 🐳 Docker 서비스

현재 실행 중인 필수 서비스:
- **PostgreSQL**: 포트 5432 (메인 데이터베이스)
- **Redis**: 포트 6380 (캐시)
- **Kafka**: 포트 9092 (메시지 큐)
- **Zookeeper**: 포트 2181 (Kafka 코디네이터)

## ⚠️ 알려진 문제

1. **AI 분석 서버**: 현재 컴파일 오류로 빌드 실패
2. **통합 테스트**: E2E 테스트 환경 구축 필요
3. **성능 최적화**: 부하 테스트 미완료

## 📞 지원

문제 발생 시 다음 문서를 참조하세요:
- 종합 문서: `COMPREHENSIVE_PROJECT_DOCUMENTATION.md`
- API 문서: `API_DOCUMENTATION.md`
- 프로젝트 현황: `documents/2025-07-12/PROJECT_STATUS_REPORT.md`