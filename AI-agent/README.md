# 전북 신고 플랫폼 AI Agent Context 가이드

## 📋 개요

이 디렉토리는 AI 에이전트가 전북 신고 플랫폼 프로젝트를 완전히 이해하고 일관성 있는 작업을 수행할 수 있도록 하는 종합적인 컨텍스트 문서들을 포함합니다.

## 📁 디렉토리 구조

```
AI-agent/
├── README.md                      # 이 파일 - AI Agent 가이드
├── context/                       # 프로젝트 전체 컨텍스트
│   ├── project-overview.md        # 프로젝트 개요 및 목적
│   ├── tech-stack.md             # 기술 스택 및 의존성
│   ├── domain-knowledge.md       # 도메인 지식 (전북지역, 신고 시스템)
│   └── business-rules.md         # 비즈니스 로직 및 규칙
├── architecture/                  # 시스템 아키텍처
│   ├── system-architecture.md    # 전체 시스템 구조
│   ├── data-flow.md              # 데이터 플로우 다이어그램
│   ├── security-model.md         # 보안 모델 및 인증
│   └── deployment-architecture.md # 배포 구조
├── services/                      # 각 서비스별 상세 정보
│   ├── main-api-server.md        # Main API Server 역할
│   ├── ai-analysis-server.md     # AI Analysis Server 역할
│   ├── flutter-client.md         # Flutter Client 구조
│   └── external-services.md      # 외부 서비스 연동
├── apis/                         # API 문서
│   ├── api-overview.md           # API 전체 개요
│   ├── authentication.md        # 인증 API
│   ├── user-management.md        # 사용자 관리 API
│   ├── report-management.md      # 신고서 관리 API
│   ├── ai-routing.md            # AI 라우팅 API
│   └── admin-apis.md            # 관리자 API
├── database/                     # 데이터베이스 설계
│   ├── schema-overview.md        # 스키마 전체 개요
│   ├── entity-relationships.md   # 엔티티 관계도
│   ├── data-dictionary.md        # 데이터 사전
│   └── migration-guide.md        # 마이그레이션 가이드
├── workflows/                    # 개발 워크플로우
│   ├── coding-standards.md       # 코딩 표준 및 컨벤션
│   ├── git-workflow.md          # Git 브랜칭 전략
│   ├── testing-strategy.md      # 테스트 전략
│   └── code-review-process.md   # 코드 리뷰 프로세스
├── integrations/                 # 외부 서비스 연동
│   ├── roboflow-integration.md   # Roboflow API 연동
│   ├── openrouter-integration.md # OpenRouter API 연동
│   ├── oauth-integration.md      # OAuth 소셜 로그인
│   └── notification-services.md  # 알림 서비스
└── deployment/                   # 배포 및 운영
    ├── environment-setup.md      # 환경 설정
    ├── docker-compose.md         # Docker 구성
    ├── monitoring.md             # 모니터링 및 로깅
    └── troubleshooting.md        # 문제 해결 가이드
```

## 🎯 AI Agent를 위한 핵심 읽기 순서

### 1단계: 프로젝트 이해
1. `context/project-overview.md` - 프로젝트 전체 목적과 범위
2. `context/domain-knowledge.md` - 전북지역 신고 시스템 도메인
3. `architecture/system-architecture.md` - 전체 시스템 구조

### 2단계: 기술적 이해  
1. `context/tech-stack.md` - 사용 기술 스택
2. `services/` 디렉토리 전체 - 각 서비스 역할
3. `database/schema-overview.md` - 데이터 구조

### 3단계: 작업별 세부 사항
- **API 개발**: `apis/` 디렉토리
- **데이터베이스 작업**: `database/` 디렉토리  
- **외부 연동**: `integrations/` 디렉토리
- **배포/운영**: `deployment/` 디렉토리

### 4단계: 개발 표준
1. `workflows/coding-standards.md` - 코딩 컨벤션
2. `workflows/testing-strategy.md` - 테스트 방법론
3. `workflows/git-workflow.md` - 버전 관리

## 🔧 AI Agent 작업 가이드라인

### 코드 수정 전 필수 확인사항
1. **서비스 역할 이해**: 해당 코드가 어느 서비스에 속하는지 확인
2. **비즈니스 로직 검토**: `context/business-rules.md` 참조
3. **API 일관성**: 기존 API 패턴과 일치하는지 확인
4. **보안 요구사항**: `architecture/security-model.md` 준수
5. **데이터베이스 무결성**: 스키마 변경 시 영향도 분석

### 새 기능 개발 시 고려사항
1. **아키텍처 패턴**: 기존 레이어드 아키텍처 유지
2. **명명 규칙**: Java/Spring Boot 컨벤션 준수
3. **에러 처리**: 통일된 예외 처리 패턴 사용
4. **로깅**: 구조화된 로그 형식 유지
5. **테스트**: 단위/통합 테스트 작성

### 문제 해결 접근법
1. **로그 분석**: `deployment/monitoring.md` 참조
2. **디버깅**: `deployment/troubleshooting.md` 활용
3. **성능 최적화**: 기존 패턴 분석 후 적용
4. **보안 점검**: 취약점 및 권한 검증

## 📚 참고 자료 위치

### 실제 코드 참조
- **Main API Server**: `/main-api-server/`
- **AI Analysis Server**: `/ai-analysis-server/`
- **Flutter Client**: `/flutter_example.dart`
- **Database**: `/database/`

### 설정 파일
- **환경 설정**: `*/src/main/resources/application.yml`
- **Docker**: `docker-compose.yml` (예정)
- **데이터베이스**: `/database/schema.sql`

### 문서 자료
- **기존 분석**: `/documents/`
- **API 명세**: Swagger UI 활용
- **변경 이력**: Git 커밋 히스토리

## ⚠️ 중요 주의사항

### 절대 하지 말아야 할 것들
1. **하드코딩**: API 키, 비밀번호 등을 코드에 직접 작성
2. **스키마 변경**: 기존 테이블 구조 무분별한 수정
3. **권한 우회**: 보안 검증 로직 제거 또는 우회
4. **설정 변경**: 운영 환경 설정 무단 수정

### 반드시 해야 할 것들
1. **문서 업데이트**: 코드 변경 시 관련 문서 동기화
2. **테스트 작성**: 새 기능에 대한 테스트 코드 필수
3. **로그 추가**: 중요한 비즈니스 로직에 적절한 로깅
4. **예외 처리**: 모든 가능한 오류 상황 대응

## 🔄 문서 업데이트 정책

이 컨텍스트 문서들은 프로젝트 변경사항에 따라 지속적으로 업데이트되어야 합니다:

1. **코드 변경 시**: 관련 서비스 문서 업데이트
2. **API 추가/변경 시**: API 문서 및 예제 업데이트  
3. **스키마 변경 시**: 데이터베이스 문서 업데이트
4. **배포 방식 변경 시**: 배포 가이드 업데이트

---

*최종 업데이트: 2025년 7월 12일*  
*관리자: AI Agent Context Team*