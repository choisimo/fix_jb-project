# API 키 중앙 관리 시스템

이제 모든 API 키를 하나의 파일에서 손쉽게 관리할 수 있습니다.

## 🚀 빠른 시작

### 1. API 키 설정
```bash
# 1. 중앙 설정 파일 편집
vi config/api-keys.env

# 2. 실제 API 키로 교체
ROBOFLOW_API_KEY=your_actual_roboflow_api_key
OPENROUTER_API_KEY=your_actual_openrouter_api_key

# 3. 모든 서비스에 설정 적용
./scripts/setup-api-keys.sh
```

### 2. 설정 검증
```bash
# API 키 연결 테스트
./scripts/test-api-keys.sh
```

## 📁 파일 구조

```
├── config/
│   └── api-keys.env          # 🎯 중앙 API 키 관리 파일
├── scripts/
│   ├── setup-api-keys.sh     # 설정 적용 스크립트
│   └── test-api-keys.sh      # 연결 테스트 스크립트
├── .env                      # 프로젝트 루트 환경변수
├── main-api-server/.env      # Main API 서버 환경변수
└── ai-analysis-server/.env   # AI 분석 서버 환경변수
```

## ⚙️ 지원하는 API 키

### 🤖 AI 서비스
- **Roboflow**: 이미지 객체 감지 및 분석
- **OpenRouter**: 멀티모달 AI 분석

### 🔐 인증 서비스
- **Google OAuth2**: 구글 소셜 로그인
- **Kakao OAuth2**: 카카오 소셜 로그인
- **JWT**: 토큰 기반 인증

### 🗄️ 인프라 서비스
- **PostgreSQL**: 데이터베이스
- **Redis**: 캐시 및 세션 관리
- **Kafka**: 메시지 큐

## 🔧 사용법

### 실제 API 키 설정
1. `config/api-keys.env` 파일 편집
2. 플레이스홀더 값을 실제 API 키로 교체:
   ```env
   # 변경 전
   ROBOFLOW_API_KEY=your_roboflow_api_key_here
   
   # 변경 후
   ROBOFLOW_API_KEY=rf_1234567890abcdef
   ```

### 설정 적용
```bash
# 모든 서비스에 설정 자동 적용
./scripts/setup-api-keys.sh
```

### 연결 테스트
```bash
# API 키 유효성 및 연결 상태 확인
./scripts/test-api-keys.sh
```

## 🎯 Roboflow API 사용법

### 기본 설정
```env
ROBOFLOW_API_KEY=your_actual_api_key
ROBOFLOW_WORKSPACE=jeonbuk-reports
ROBOFLOW_PROJECT=integrated-detection
ROBOFLOW_MODEL_ID=integrated-detection/1
```

### API 호출 방식
```java
// RoboflowApiClient에서 자동으로 다음 URL 구성:
// https://detect.roboflow.com/{modelId}?api_key={apiKey}&confidence={confidence}&overlap={overlap}
```

### 지원 기능
- ✅ 비동기 이미지 분석
- ✅ 배치 이미지 처리
- ✅ 자동 재시도 로직
- ✅ 오류 복구 및 폴백
- ✅ 멀티스레딩 지원

## 🔍 문제 해결

### API 키 설정 오류
```bash
# 설정 상태 확인
./scripts/test-api-keys.sh

# 설정 재적용
./scripts/setup-api-keys.sh
```

### Roboflow API 연결 실패
1. API 키 유효성 확인
2. 네트워크 연결 확인
3. Roboflow 서비스 상태 확인

### 환경변수 로드 실패
1. `.env` 파일 존재 확인
2. 파일 권한 확인
3. 서비스 재시작

## 🚀 배포 시 주의사항

### 보안
- `.env` 파일을 Git에 커밋하지 마세요
- 프로덕션에서는 환경변수 직접 설정 권장
- API 키 정기적 로테이션

### Docker 배포
```bash
# Docker Compose에서 자동으로 .env 파일 사용
docker-compose up -d
```

## 📈 모니터링

### API 사용량 확인
- Roboflow 대시보드에서 사용량 모니터링
- OpenRouter 대시보드에서 토큰 사용량 확인

### 로그 확인
```bash
# 서비스 로그 확인
docker-compose logs -f main-api-server
docker-compose logs -f ai-analysis-server
```