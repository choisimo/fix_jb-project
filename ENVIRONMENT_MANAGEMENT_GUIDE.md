# 환경변수 관리 가이드

## 개요

JB Report Platform은 모든 서비스(Spring Boot, Flutter, Docker, 스크립트)의 환경변수를 단일 파일에서 중앙 관리할 수 있도록 설계되었습니다. 이를 통해 **관리자 편의성과 업무 효율성을 대폭 향상**시킬 수 있습니다.

## 📁 환경변수 파일 구조

```
프로젝트 루트/
├── .env                # 기본 환경변수 파일 (현재 개발환경)
├── .env.dev           # 개발 환경
├── .env.staging       # 스테이징 환경  
├── .env.prod          # 프로덕션 환경
├── .env.template      # 템플릿 파일 (참고용)
├── .env.example       # 예시 파일 (참고용)
└── flutter-app/.env   # Flutter 앱 전용 환경변수 파일
```

## 🚀 주요 기능 및 장점

### 1. 단일 파일 중앙 관리
- **모든 서비스의 환경변수를 하나의 파일에서 관리**
- Spring Boot 서버, Flutter 앱, Docker, 스크립트 모두 동일한 환경변수 파일 사용
- 환경변수 수정 시 **한 곳만 변경**하면 모든 서비스에 반영

### 2. 환경별 설정 분리
- 개발(dev), 스테이징(staging), 프로덕션(prod) 환경별 설정 파일
- 환경 전환 시 파일만 변경하면 즉시 적용
- 실수로 인한 환경 간 설정 혼용 방지

### 3. 자동화된 검증 시스템
- 필수 환경변수 누락 시 자동 감지 및 오류 출력
- 스크립트 실행 전 환경변수 유효성 검사
- 설정 실수로 인한 서비스 장애 사전 방지

## 📋 환경변수 카테고리

### 🔧 시스템 설정
| 변수명 | 설명 | 예시값 |
|--------|------|--------|
| `ENVIRONMENT` | 실행 환경 | `development`, `staging`, `production` |
| `SPRING_PROFILES_ACTIVE` | Spring Boot 프로파일 | `dev`, `staging`, `prod` |

### 🗄️ 데이터베이스 설정
| 변수명 | 설명 | 예시값 |
|--------|------|--------|
| `DATABASE_URL` | 데이터베이스 연결 URL | `jdbc:postgresql://localhost:5432/jbreport_prod` |
| `DATABASE_USERNAME` | 데이터베이스 사용자명 | `jbreport` |
| `DATABASE_PASSWORD` | 데이터베이스 비밀번호 | `your_secure_password` |

### 🔐 보안 설정
| 변수명 | 설명 | 예시값 |
|--------|------|--------|
| `JWT_SECRET` | JWT 토큰 시크릿 키 | `your_jwt_secret_key_here` |
| `REDIS_PASSWORD` | Redis 비밀번호 | `your_redis_password` |

### 🤖 AI 서비스 설정
| 변수명 | 설명 | 예시값 |
|--------|------|--------|
| `ROBOFLOW_API_KEY` | Roboflow API 키 | `your_roboflow_api_key` |
| `OPENROUTER_API_KEY` | OpenRouter API 키 | `your_openrouter_api_key` |

### 📱 앱 설정 (Flutter)
| 변수명 | 설명 | 예시값 |
|--------|------|--------|
| `DEV_BASE_URL` | 개발 환경 API URL | `http://localhost:8080` |
| `PROD_BASE_URL` | 프로덕션 API URL | `https://api.jbreport.com` |
| `ENABLE_DEBUG_MODE` | 디버그 모드 활성화 | `true`, `false` |

## 🛠️ 사용 방법

### 1. 환경별 설정 파일 선택

#### 개발 환경
```bash
# .env.dev 파일 사용
cp .env.dev .env
# 또는 환경변수로 지정
export ENVIRONMENT=development
```

#### 스테이징 환경
```bash
# .env.staging 파일 사용
cp .env.staging .env
# 또는 환경변수로 지정  
export ENVIRONMENT=staging
```

#### 프로덕션 환경
```bash
# .env.prod 파일 사용
cp .env.prod .env
# 또는 환경변수로 지정
export ENVIRONMENT=production
```

### 2. 스크립트 실행

모든 스크립트는 자동으로 환경변수를 로드합니다:

```bash
# 모든 서비스 시작 (환경변수 자동 로드)
./scripts/start-all-services.sh

# 프로덕션 배포 (프로덕션 환경변수 자동 로드)
./scripts/deploy-production.sh

# 개발 환경으로 실행
ENVIRONMENT=development ./scripts/start-all-services.sh
```

### 3. Flutter 앱 빌드

Flutter 앱은 빌드 시 환경변수를 읽어옵니다:

```bash
# 개발 환경으로 빌드
cd flutter-app
# .env 파일이 자동으로 로드됨
flutter run

# 프로덕션 빌드
# flutter-app/.env 파일에서 ENVIRONMENT=production 설정 후
flutter build apk --release
```

### 4. Docker 실행

Docker Compose는 자동으로 .env 파일을 읽습니다:

```bash
# 개발 환경
docker-compose up -d

# 프로덕션 환경
docker-compose -f docker-compose.prod.yml up -d
```

## 🔄 환경변수 변경 워크플로우

### 1. 새로운 환경변수 추가
```bash
# 1. 모든 환경 파일에 변수 추가
echo "NEW_VARIABLE=value" >> .env.dev
echo "NEW_VARIABLE=prod_value" >> .env.prod
echo "NEW_VARIABLE=staging_value" >> .env.staging

# 2. Flutter 앱에서 사용하는 경우 AppConfig 클래스에도 추가
# flutter-app/lib/core/config/app_config.dart 편집

# 3. 서비스 재시작
./scripts/stop-all-services.sh
./scripts/start-all-services.sh
```

### 2. 기존 환경변수 수정
```bash
# 1. 해당 환경 파일만 수정
vim .env.prod

# 2. 해당 환경 서비스만 재시작
ENVIRONMENT=production ./scripts/start-all-services.sh
```

## 🛡️ 보안 고려사항

### 1. 민감한 정보 관리
- **프로덕션 환경변수 파일(.env.prod)는 반드시 별도 보안 저장소에서 관리**
- Git에는 템플릿 파일(.env.template)만 포함
- 실제 API 키, 비밀번호는 개발팀/운영팀만 접근 가능한 위치에 저장

### 2. 파일 권한 설정
```bash
# 환경변수 파일 권한을 소유자만 읽기/쓰기로 제한
chmod 600 .env.prod
chmod 600 .env.staging
```

### 3. .gitignore 설정
```gitignore
# 실제 환경변수 파일들은 Git 추적에서 제외
.env
.env.local
.env.*.local
```

## 🚨 문제 해결

### 1. 환경변수 로딩 실패
```bash
# 환경변수 파일 존재 확인
ls -la .env*

# 환경변수 파일 내용 확인 (민감하지 않은 부분만)
grep -v "PASSWORD\|SECRET\|KEY" .env

# 스크립트 실행 권한 확인
chmod +x scripts/*.sh
```

### 2. 필수 환경변수 누락
```bash
# 스크립트 실행 시 자동으로 누락된 변수 표시됨
./scripts/start-all-services.sh

# 수동으로 검증하려면
source scripts/env-utils.sh
validate_required_vars "DATABASE_PASSWORD" "JWT_SECRET"
```

### 3. 환경별 설정 확인
```bash
# 현재 로드된 환경변수 확인
source scripts/env-utils.sh
load_env_by_environment "production"
print_env_info
```

## 📈 성능 최적화 팁

### 1. 환경별 최적화 설정
- **개발환경**: 상세한 로깅, 긴 타임아웃, Mock 데이터 활성화
- **스테이징환경**: 프로덕션과 유사하지만 디버깅 가능한 설정
- **프로덕션환경**: 최소한의 로깅, 최적화된 타임아웃, 보안 강화

### 2. 캐싱 최적화
```bash
# Redis 설정 최적화 (프로덕션)
REDIS_TIMEOUT=2000
REDIS_POOL_MAX_ACTIVE=8

# 개발환경에서는 더 관대한 설정
REDIS_TIMEOUT=5000
REDIS_POOL_MAX_ACTIVE=16
```

## 🎯 관리자를 위한 주요 명령어

### 빠른 환경 전환
```bash
# 개발 → 스테이징
cp .env.staging .env && ./scripts/start-all-services.sh

# 스테이징 → 프로덕션  
cp .env.prod .env && ./scripts/deploy-production.sh
```

### 환경변수 백업 및 복구
```bash
# 현재 설정 백업
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)

# 백업에서 복구
cp .env.backup.20240126_143000 .env
```

### 전체 환경 상태 확인
```bash
# 모든 환경 파일의 주요 설정 비교
echo "=== Development ===" && grep "ENVIRONMENT\|DATABASE_URL\|API_BASE_URL" .env.dev
echo "=== Staging ===" && grep "ENVIRONMENT\|DATABASE_URL\|API_BASE_URL" .env.staging  
echo "=== Production ===" && grep "ENVIRONMENT\|DATABASE_URL\|API_BASE_URL" .env.prod
```

---

## 📞 지원 및 문의

환경변수 설정과 관련하여 문제가 있거나 새로운 요구사항이 있는 경우:

1. **문서 확인**: 이 가이드 문서 참조
2. **스크립트 도움말**: `./scripts/env-utils.sh` 실행
3. **로그 확인**: `logs/` 디렉토리의 서비스 로그 파일 확인
4. **개발팀 문의**: 기술적 이슈나 새로운 환경변수 추가 요청

이 가이드를 통해 **단일 파일에서 모든 환경변수를 효율적으로 관리**하여 업무 효율성을 크게 향상시킬 수 있습니다.