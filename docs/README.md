---
title: 전북 신고 플랫폼 문서 센터
category: documentation
tags: [documentation, index, navigation, overview]
version: 1.0
last_updated: 2025-07-13
author: 문서화팀
status: approved
---

# 📚 전북 신고 플랫폼 문서 센터

전북 신고 플랫폼의 모든 문서가 체계적으로 정리된 중앙 문서 허브입니다.

## 🚀 빠른 시작

새로 시작하시나요? 아래 순서대로 따라해보세요:

1. **[빠른 시작 가이드](01-getting-started/quick-start-guide.md)** - 5분만에 시스템 실행
2. **[시스템 아키텍처](02-architecture/system-overview.md)** - 전체 시스템 이해
3. **[API 명세서](04-development/api/api-specification.md)** - API 사용법
4. **[개발 가이드](04-development/)** - 각 컴포넌트별 개발 방법

## 📁 문서 구조

### 📖 01. 시작하기
> 새로운 사용자와 개발자를 위한 필수 가이드

| 문서 | 설명 | 예상 소요 시간 |
|------|------|----------------|
| [빠른 시작 가이드](01-getting-started/quick-start-guide.md) | 시스템 실행 및 기본 테스트 | 10분 |

**이런 분들에게 추천**:
- 처음 시스템을 접하는 개발자
- 빠르게 데모를 실행하고 싶은 분
- 기본 기능을 테스트하고 싶은 분

### 🏗 02. 시스템 아키텍처
> 시스템의 전체 구조와 설계 철학

| 문서 | 설명 |
|------|------|
| [시스템 개요](02-architecture/system-overview.md) | 전체 아키텍처 및 구성 요소 |

**이런 분들에게 추천**:
- 시스템 아키텍처를 이해하고 싶은 개발자
- 기술 의사결정이 필요한 팀 리더
- 시스템 확장을 계획하는 아키텍트

### 📋 03. 기획 및 요구사항
> 프로젝트 기획서와 상세 요구사항 명세

#### PRD (Product Requirements Document)
```
prd/
├── core-platform/     # 핵심 플랫폼 기능
├── ai-integration/    # AI 관련 기능
├── mobile-app/        # 모바일 앱 기능 (8개 PRD)
└── infrastructure/    # 인프라 및 배포
```

**주요 PRD 문서**:
- **모바일 앱**: [사용자 인증](03-planning/prd/mobile-app/01-user-authentication-prd.md), [신고 관리](03-planning/prd/mobile-app/02-report-management-prd.md), [실시간 알림](03-planning/prd/mobile-app/03-realtime-notification-prd.md)
- **AI 통합**: [이미지 분석](03-planning/prd/ai-integration/), [텍스트 분석](03-planning/prd/ai-integration/)
- **인프라**: [프로덕션 배포](03-planning/prd/infrastructure/production-deployment.md)

### 🔧 04. 개발 가이드
> 각 기술 스택별 상세한 개발 가이드

```
04-development/
├── api/              # REST API 개발
├── backend/          # Spring Boot 백엔드
├── frontend/         # 웹 프론트엔드 (향후)
├── mobile/           # Flutter 모바일 앱
└── ai-integration/   # AI 서비스 연동
```

**추천 읽기 순서**:
1. [API 명세서](04-development/api/api-specification.md) - API 이해
2. [백엔드 개발](04-development/backend/) - 서버 개발
3. [모바일 개발](04-development/mobile/) - Flutter 앱 개발
4. [AI 통합](04-development/ai-integration/) - AI 기능 연동

### 🚀 05. 배포 및 운영
> 프로덕션 환경 배포와 운영 가이드

```
05-deployment/
├── production/       # 프로덕션 배포
├── monitoring/       # 모니터링 설정
└── troubleshooting/  # 문제 해결
```

**운영팀 필수 문서**:
- [배포 가이드](05-deployment/production/) - 프로덕션 환경 구축
- [모니터링 설정](05-deployment/monitoring/) - 시스템 모니터링
- [트러블슈팅](05-deployment/troubleshooting/common-issues.md) - 일반적인 문제 해결

### 🧪 06. 테스트
> 품질 보증을 위한 테스트 전략과 가이드

```
06-testing/
├── test-strategy.md     # 전체 테스트 전략
├── unit-testing/        # 단위 테스트
├── integration-tests/   # 통합 테스트
└── user-acceptance/     # 사용자 수용 테스트
```

### 📊 07. 분석 및 리포트
> 프로젝트 진행 상황과 성과 분석

```
07-analysis/
├── completion-status/   # 완성도 분석
├── performance-analysis/ # 성능 분석
└── error-reports/       # 오류 분석
```

**주요 분석 문서**:
- [프로젝트 현황](07-analysis/completion-status/project-status.md) - 전체 진행 상황 (95% 완성)
- [성능 분석](07-analysis/performance-analysis/) - 시스템 성능 지표
- [오류 리포트](07-analysis/error-reports/) - 발생한 문제들과 해결책

### 📖 08. 참고 자료
> 외부 API, 라이브러리, 베스트 프랙티스

```
08-references/
├── external-apis/       # 외부 API 문서
├── libraries-frameworks/ # 사용한 라이브러리 설명
└── best-practices/      # 개발 베스트 프랙티스
```

## 🎯 역할별 추천 문서

### 👩‍💻 신규 개발자
**첫 주에 읽을 문서들**:
1. [빠른 시작 가이드](01-getting-started/quick-start-guide.md)
2. [시스템 아키텍처](02-architecture/system-overview.md)
3. [API 명세서](04-development/api/api-specification.md)
4. [프로젝트 현황](07-analysis/completion-status/project-status.md)

### 🏗 아키텍트 / 시니어 개발자
**검토할 주요 문서들**:
- [시스템 아키텍처](02-architecture/system-overview.md)
- [인프라 PRD](03-planning/prd/infrastructure/)
- [성능 분석](07-analysis/performance-analysis/)
- [배포 가이드](05-deployment/production/)

### 🚀 DevOps 엔지니어
**운영 관련 문서들**:
- [배포 가이드](05-deployment/production/)
- [모니터링 설정](05-deployment/monitoring/)
- [트러블슈팅](05-deployment/troubleshooting/common-issues.md)
- [성능 최적화](07-analysis/performance-analysis/)

### 📱 모바일 개발자
**Flutter 관련 문서들**:
- [모바일 앱 PRD](03-planning/prd/mobile-app/)
- [Flutter 개발 가이드](04-development/mobile/)
- [모바일 테스트](06-testing/)

### 🤖 AI 개발자
**AI 통합 관련 문서들**:
- [AI 통합 PRD](03-planning/prd/ai-integration/)
- [AI 개발 가이드](04-development/ai-integration/)
- [Roboflow 연동](04-development/ai-integration/roboflow-integration-guide.md)

### 🔧 프로젝트 매니저
**프로젝트 관리 문서들**:
- [프로젝트 현황](07-analysis/completion-status/project-status.md)
- [전체 PRD 목록](03-planning/prd/)
- [완성도 분석](07-analysis/completion-status/)

## 📈 프로젝트 현황 (2025-07-13 기준)

### 🎯 전체 완성도: **95%**
| 컴포넌트 | 완성도 | 상태 |
|----------|--------|------|
| 백엔드 API | 95% | ✅ 완료 |
| 모바일 앱 | 100% | ✅ 완료 |
| AI 통합 | 70% | 🔄 진행 중 |
| 실시간 시스템 | 100% | ✅ 완료 |
| 배포 환경 | 90% | 🔄 거의 완료 |

### 🚧 현재 작업 중
- **AI 분석 서버**: 컴파일 오류 수정 중
- **성능 최적화**: 데이터베이스 튜닝
- **배포 파이프라인**: CI/CD 자동화

자세한 현황은 [프로젝트 현황 보고서](07-analysis/completion-status/project-status.md)를 참조하세요.

## 🔍 문서 검색 팁

### 빠른 검색
- **기능별**: `grep -r "키워드" docs/`
- **파일 이름**: `find docs/ -name "*키워드*"`
- **특정 카테고리**: `docs/카테고리번호-이름/`

### 자주 찾는 문서들
```bash
# API 관련
docs/04-development/api/

# 트러블슈팅
docs/05-deployment/troubleshooting/

# 프로젝트 현황
docs/07-analysis/completion-status/

# 시작 가이드
docs/01-getting-started/
```

## 📞 문서 관련 지원

### 문서 기여하기
1. 새로운 문서 추가 시 메타데이터 헤더 포함
2. 링크 검증 후 PR 생성
3. 표준 템플릿 사용

### 문제 신고
- **문서 오류**: GitHub Issues 사용
- **링크 깨짐**: DevOps 팀에 연락
- **접근 권한**: 관리자에게 문의

### 연락처
- **문서 관리자**: docs@jbreport.kr
- **기술 문의**: dev@jbreport.kr
- **긴급 지원**: Slack #docs-support

---

## 📋 문서 업데이트 히스토리

- **v1.0 (2025-07-13)**: 전체 문서 구조 재편성
  - 중복 문서 39개 제거
  - 8개 카테고리로 체계화
  - 표준화된 메타데이터 적용

---

**Happy coding! 🚀**

좋은 문서는 좋은 코드만큼 중요합니다. 이 문서들이 여러분의 개발 여정에 도움이 되길 바랍니다.