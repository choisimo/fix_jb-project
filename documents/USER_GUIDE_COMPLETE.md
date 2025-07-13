# 전북 신고 플랫폼 - 종합 사용자 가이드
**최종 업데이트: 2025-07-13**

---

## 📋 목차

1. [빠른 시작](#빠른-시작)
2. [시스템 요구사항](#시스템-요구사항)
3. [설치 및 실행](#설치-및-실행)
4. [API 사용법](#api-사용법)
5. [Flutter 앱 사용법](#flutter-앱-사용법)
6. [문제 해결](#문제-해결)

---

## 🚀 빠른 시작

### 즉시 실행하기
```bash
# 1. 인프라 서비스 시작
docker-compose up -d

# 2. API 서버 실행
cd main-api-server
java -jar build/libs/report-platform-1.0.0.jar

# 3. Flutter 앱 실행 (별도 터미널)
cd flutter-app
flutter run
```

### 접속 정보
- **API Server**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Alert WebSocket**: ws://localhost:8080/ws/alerts

---

## 💻 시스템 요구사항

### 필수 소프트웨어
- **Java**: 17 이상
- **Flutter**: 3.0 이상
- **Docker**: 20.10 이상
- **PostgreSQL**: 13 이상

### 권장 하드웨어
- **RAM**: 최소 8GB
- **Storage**: 최소 10GB 여유 공간
- **CPU**: 멀티코어 권장

---

## ⚙️ 설치 및 실행

### 1. 환경 설정
```bash
# 프로젝트 클론
git clone [repository-url]
cd fix_jb-project

# 환경변수 설정
cp .env.example .env
# .env 파일 편집하여 실제 값 입력
```

### 2. 데이터베이스 설정
```bash
# Docker 컨테이너 시작
docker-compose up -d postgres redis kafka zookeeper

# 데이터베이스 초기화 (자동)
# 서버 첫 실행 시 자동으로 스키마 생성됨
```

### 3. 백엔드 실행
```bash
cd main-api-server

# Gradle 빌드 (필요시)
./gradlew build

# 서버 실행
java -jar build/libs/report-platform-1.0.0.jar
```

### 4. Flutter 앱 실행
```bash
cd flutter-app

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

---

## 🔗 API 사용법

### 인증
모든 API는 JWT 토큰 기반 인증을 사용합니다.

```http
# 로그인
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### 리포트 관리
```http
# 리포트 생성
POST /api/v1/reports
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "title": "포트홀 발견",
  "description": "도로에 큰 포트홀이 발견되었습니다.",
  "category": "ROAD_DAMAGE",
  "priority": "HIGH",
  "latitude": 35.8219,
  "longitude": 127.1489,
  "images": [file1, file2]
}
```

### Alert 시스템
```http
# Alert 목록 조회
GET /api/v1/alerts?page=0&size=10
Authorization: Bearer {token}

# Alert 읽음 처리
PUT /api/v1/alerts/{alertId}/read
Authorization: Bearer {token}
```

### WebSocket 연결
```javascript
// Alert 실시간 수신
const socket = new WebSocket('ws://localhost:8080/ws/alerts');
socket.onmessage = function(event) {
    const alert = JSON.parse(event.data);
    console.log('새 Alert:', alert);
};
```

---

## 📱 Flutter 앱 사용법

### 1. 초기 설정
1. 앱 실행 후 회원가입 또는 로그인
2. 프로필 정보 입력
3. 위치 권한 허용
4. 카메라 권한 허용

### 2. 리포트 작성
1. 홈 화면에서 "+" 버튼 클릭
2. 사진 촬영 또는 갤러리에서 선택
3. AI 자동 분석 결과 확인
4. 필요시 내용 수정
5. 위치 정보 확인
6. 제출

### 3. 리포트 관리
- **목록 보기**: 작성한 리포트 목록 조회
- **필터링**: 카테고리, 상태별 필터
- **상세 보기**: 리포트 세부 정보 및 처리 상태
- **댓글**: 담당자와 소통

### 4. 설정
- **프로필**: 개인정보 수정
- **알림**: 푸시 알림 설정
- **테마**: 다크모드/라이트모드
- **언어**: 한국어/영어 선택

---

## 🛠 문제 해결

### 일반적인 문제

#### 1. 서버 연결 실패
```bash
# 서버 상태 확인
curl http://localhost:8080/actuator/health

# Docker 컨테이너 상태 확인
docker ps

# 로그 확인
docker logs [container-name]
```

#### 2. 데이터베이스 연결 오류
```bash
# PostgreSQL 연결 테스트
docker exec -it postgres psql -U postgres -d reportdb

# 연결 정보 확인
docker logs postgres
```

#### 3. Flutter 빌드 실패
```bash
# 클린 빌드
flutter clean
flutter pub get
flutter run

# 의존성 문제 해결
flutter doctor
```

#### 4. AI 분석 실패
```bash
# 환경변수 확인
echo $ROBOFLOW_API_KEY

# API 연결 테스트
curl -X GET "https://detect.roboflow.com" -I
```

### 로그 확인 방법

#### 백엔드 로그
```bash
# 애플리케이션 로그
tail -f logs/application.log

# 특정 패키지 로그 레벨 조정
# application.properties에서 설정
logging.level.com.jeonbuk.report=DEBUG
```

#### Flutter 디버그 로그
```bash
# 디버그 모드 실행
flutter run --debug

# 로그 출력
flutter logs
```

### 성능 최적화

#### 1. 데이터베이스 최적화
```sql
-- 인덱스 확인
SELECT * FROM pg_indexes WHERE tablename = 'reports';

-- 쿼리 성능 분석
EXPLAIN ANALYZE SELECT * FROM reports WHERE status = 'PENDING';
```

#### 2. 이미지 최적화
- 업로드 전 이미지 압축
- 적절한 해상도 사용 (최대 1920x1080)
- WebP 포맷 사용 고려

---

## 📊 모니터링

### 시스템 상태 확인
```bash
# API 서버 상태
curl http://localhost:8080/actuator/health

# 데이터베이스 상태
docker exec postgres pg_isready

# 메모리 사용량
docker stats
```

### 주요 메트릭
- **API 응답 시간**: < 500ms
- **데이터베이스 연결**: < 100ms
- **메모리 사용량**: < 2GB
- **CPU 사용률**: < 80%

---

## 🔐 보안 설정

### JWT 토큰 관리
- 토큰 만료 시간: 24시간
- 리프레시 토큰: 7일
- 안전한 저장: 앱 내부 보안 저장소 사용

### API 보안
- HTTPS 사용 권장
- CORS 설정 확인
- Rate Limiting 적용

### 데이터 보안
- 개인정보 암호화
- 이미지 메타데이터 제거
- 정기적인 백업

---

## 📞 지원 및 연락처

### 기술 지원
- **개발팀**: 개발팀
- **이슈 신고**: GitHub Issues
- **문서**: `/documents/` 폴더 참조

### 관련 문서
- `PROJECT_STATUS_COMPREHENSIVE.md` - 프로젝트 전체 현황
- `ROBOFLOW_COMPLETE_GUIDE.md` - AI 통합 가이드
- `API_DOCUMENTATION.md` - API 상세 명세서

---

**최종 업데이트**: 2025-07-13  
**버전**: 1.0.0  
**라이센스**: MIT