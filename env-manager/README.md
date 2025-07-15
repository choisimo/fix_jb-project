# JB Project 환경변수 관리 시스템

모든 마이크로서비스의 환경변수를 한 곳에서 효율적으로 관리할 수 있는 웹 기반 대시보드입니다.

## 🚀 주요 기능

- **통합 관리**: 모든 서비스의 환경변수를 한 페이지에서 관리
- **다양한 형식 지원**: .env 파일과 YAML 설정 파일 모두 지원
- **실시간 저장**: 변경사항을 즉시 파일에 저장
- **서비스 재시작**: 웹 인터페이스에서 직접 컨테이너 재시작
- **검색 기능**: 환경변수명이나 값으로 빠른 검색
- **보안 강화**: 민감한 정보(비밀번호, API 키 등) 숨김 처리
- **백업 기능**: 전체 환경변수 JSON 백업 다운로드

## 📁 관리되는 파일들

- **메인 환경변수**: `.env` (프로젝트 루트)
- **Main API Server**: 
  - `.env` 파일
  - `application.yml` 파일
- **AI Analysis Server**: 
  - `.env` 파일
  - `application.yml` 파일

## 🛠️ 설치 및 실행

### 1. Docker Compose로 실행 (권장)

```bash
# 환경변수 관리 시스템만 실행
cd env-manager
docker-compose up -d

# 또는 전체 시스템과 함께 실행
docker-compose up -d env-manager
```

### 2. 개별 실행

```bash
cd env-manager
docker build -t jb-env-manager .
docker run -d -p 8888:8888 \
  -v $(pwd)/../.env:/app/data/.env:rw \
  -v $(pwd)/../projects/main-api-server/.env:/app/data/main-api-server/.env:rw \
  -v $(pwd)/../projects/main-api-server/src/main/resources/application.yml:/app/data/main-api-server/application.yml:rw \
  -v $(pwd)/../projects/ai-analysis-server/.env:/app/data/ai-analysis-server/.env:rw \
  -v $(pwd)/../projects/ai-analysis-server/src/main/resources/application.yml:/app/data/ai-analysis-server/application.yml:rw \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --name jb-env-manager \
  jb-env-manager
```

## 🌐 사용법

1. **접속**: 웹 브라우저에서 `http://localhost:8888` 접속

2. **환경변수 편집**:
   - 각 서비스별로 탭이 구분되어 있습니다
   - 변수명과 값을 직접 수정할 수 있습니다
   - 민감한 정보는 자동으로 마스킹됩니다

3. **저장**: 각 서비스별로 "저장" 버튼을 클릭하여 변경사항 적용

4. **서비스 재시작**: "재시작" 버튼으로 해당 서비스 컨테이너 재시작

5. **검색**: 상단 검색창으로 특정 환경변수 빠른 찾기

6. **백업**: "전체 백업" 버튼으로 모든 환경변수 JSON 파일로 다운로드

## 🔧 환경변수 구성

### 지원하는 파일 형식

#### 1. .env 파일
```bash
# 섹션별로 자동 분류
API_KEY=your_api_key
DATABASE_URL=postgresql://localhost:5432/db
```

#### 2. YAML 파일
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/db
    username: user
server:
  port: 8080
```

### 보안 기능

- `password`, `secret`, `key`가 포함된 변수명은 자동으로 마스킹
- 눈 모양 아이콘 클릭으로 값 표시/숨김 토글
- Docker 소켓은 읽기 전용으로 마운트

## 📊 시스템 요구사항

- **Docker**: 20.10 이상
- **Docker Compose**: 2.0 이상
- **메모리**: 최소 512MB
- **포트**: 8888 (변경 가능)

## 🚨 주의사항

1. **백업**: 중요한 환경변수 변경 전에는 반드시 백업을 받으세요
2. **권한**: Docker 소켓 접근을 위해 적절한 권한이 필요합니다
3. **보안**: 프로덕션 환경에서는 HTTPS와 인증을 추가하는 것을 권장합니다

## 🛡️ 보안 고려사항

- 모든 환경변수 파일은 읽기/쓰기 권한으로 마운트됩니다
- Docker 소켓은 읽기 전용으로 제한됩니다
- 민감한 정보는 자동으로 마스킹 처리됩니다
- 백업 파일에는 모든 환경변수가 평문으로 포함되므로 안전하게 보관하세요

## 📝 개발자 정보

이 시스템은 JB Project의 복잡한 마이크로서비스 아키텍처에서 환경변수를 효율적으로 관리하기 위해 개발되었습니다.

### 기술 스택
- **Backend**: Python Flask
- **Frontend**: Bootstrap 5, JavaScript
- **Container**: Docker
- **파일 처리**: PyYAML, python-dotenv

### 확장 가능성
- 새로운 서비스 추가는 `app.py`의 `ENV_FILES_CONFIG`에서 설정
- UI 커스터마이징은 `templates/dashboard.html` 수정
- 추가 기능은 Flask 라우트로 확장 가능