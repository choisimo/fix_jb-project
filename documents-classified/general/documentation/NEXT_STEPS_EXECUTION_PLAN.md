# 다음 단계 실행 계획

## 🎯 우선순위 1: FastAPI 백엔드 완료 (Task 14)

### 1.1 데이터베이스 ORM 설정
```python
# requirements.txt에 추가 필요
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
alembic==1.13.1

# 구현 필요 파일들
- database/connection.py    # DB 연결 설정
- database/models.py        # SQLAlchemy 모델들
- database/migrations/      # 데이터베이스 마이그레이션
```

### 1.2 사용자 인증 시스템
```python
# 추가 의존성
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6

# 구현 필요 엔드포인트
- POST /api/auth/register
- POST /api/auth/login  
- POST /api/auth/refresh
- GET /api/auth/profile
```

### 1.3 리포트 관리 API
```python
# 구현 필요 엔드포인트
- POST /api/reports         # 리포트 생성
- GET /api/reports          # 리포트 목록 (필터링, 페이징)
- GET /api/reports/{id}     # 리포트 조회
- PUT /api/reports/{id}     # 리포트 수정
- DELETE /api/reports/{id}  # 리포트 삭제
- POST /api/reports/{id}/files  # 파일 업로드
```

## 🎯 우선순위 2: Flutter 백엔드 통합 (Task 16)

### 2.1 HTTP 서비스 구현
```dart
// lib/core/services/http_service.dart
class HttpService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // 인증 헤더 관리
  // 요청/응답 인터셉터
  // 에러 처리
}
```

### 2.2 인증 서비스 통합
```dart
// lib/core/services/auth_service.dart
class AuthService {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(UserRegistration user);
  Future<void> logout();
  Stream<AuthState> get authStateChanges;
}
```

### 2.3 리포트 서비스 연동
```dart
// lib/features/reports/data/repositories/
class ReportRepository {
  Future<List<Report>> getReports({ReportFilter? filter});
  Future<Report> getReport(String id);
  Future<Report> createReport(CreateReportRequest request);
  Future<void> uploadFiles(String reportId, List<File> files);
}
```

### 2.4 WebSocket 실시간 업데이트
```dart
// lib/core/services/websocket_service.dart
class WebSocketService {
  void connect(String reportId);
  Stream<AnalysisUpdate> get analysisUpdates;
  void disconnect();
}
```

## 🎯 우선순위 3: 통합 테스트 (Task 15)

### 3.1 테스트 시나리오
1. **사용자 등록/로그인 플로우**
2. **리포트 생성 → AI 분석 → 결과 수신**
3. **파일 업로드 → 저장 → 조회**
4. **실시간 알림 → WebSocket 연결**

### 3.2 성능 테스트
- 동시 사용자 100명 기준
- 이미지 업로드 처리 시간
- AI 분석 응답 시간

## 🛠️ 구체적인 실행 단계

### Step 1: 데이터베이스 연결 설정
```bash
# 1. 의존성 설치
pip install sqlalchemy psycopg2-binary alembic

# 2. 데이터베이스 초기화
cd database
python init_db.py

# 3. 마이그레이션 실행
alembic upgrade head
```

### Step 2: FastAPI 백엔드 개선
```bash
# 1. 필요한 모듈 구현
touch router_service_enhanced.py
touch auth/endpoints.py
touch reports/endpoints.py
touch database/models.py

# 2. 환경 변수 설정
cp .env.example .env
# DATABASE_URL, JWT_SECRET 등 설정

# 3. 서버 실행 및 테스트
uvicorn router_service_enhanced:app --reload
```

### Step 3: Flutter 통합
```bash
cd flutter-app

# 1. HTTP 클라이언트 패키지 추가
flutter pub add http dio

# 2. 상태 관리 패키지 업데이트
flutter pub add provider flutter_riverpod

# 3. 서비스 레이어 구현
mkdir -p lib/core/services
mkdir -p lib/features/reports/data/repositories

# 4. 앱 빌드 및 테스트
flutter run
```

### Step 4: 통합 테스트
```bash
# 1. 전체 시스템 시작
docker-compose up -d
python kafka_worker.py &
python router_service_enhanced.py &

# 2. Flutter 앱 실행
cd flutter-app && flutter run

# 3. 테스트 실행
python integration_test_full.py
```

## 📋 체크리스트

### 백엔드 (Task 14)
- [ ] SQLAlchemy 모델 정의
- [ ] 데이터베이스 마이그레이션
- [ ] JWT 인증 시스템
- [ ] 리포트 CRUD API
- [ ] 파일 업로드 API
- [ ] 에러 처리 및 로깅

### Flutter 통합 (Task 16)  
- [ ] HTTP 서비스 구현
- [ ] 인증 상태 관리
- [ ] 리포트 API 연동
- [ ] WebSocket 실시간 업데이트
- [ ] 로딩 상태 및 에러 처리

### 테스트 및 배포 (Task 15)
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 실행
- [ ] 성능 테스트
- [ ] 프로덕션 Docker 설정
- [ ] 모니터링 설정

## ⚡ 예상 시간표

| 단계             | 예상 시간 | 완료 조건                      |
| ---------------- | --------- | ------------------------------ |
| 데이터베이스 ORM | 4-6시간   | 모든 모델 정의 및 마이그레이션 |
| 인증 API         | 6-8시간   | 로그인/등록/토큰 관리          |
| 리포트 API       | 8-10시간  | CRUD + 파일 업로드             |
| Flutter 통합     | 10-12시간 | 모든 화면 API 연동             |
| 테스트           | 4-6시간   | 전체 플로우 테스트             |

**총 예상 시간: 32-42시간 (4-5일)**

다음 단계로 바로 Task 14의 서브태스크부터 시작하시면 됩니다!
