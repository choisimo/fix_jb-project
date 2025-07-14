# 05. Gradle 멀티모듈 적용 (최신화)

## 목적
- Gradle 멀티모듈 구조로 공통/서비스별 의존성 분리 및 빌드/테스트 자동화

## 최신 작업 내역
- 루트 settings.gradle에서 모든 모듈 등록
  - `include 'common', 'main-api-server', 'ai-analysis-server'`
- 각 모듈별 build.gradle 작성
  - `common`은 `api`로, 각 서비스는 `implementation project(':common')`으로 의존성 추가
- 공통 의존성(lombok, spring-boot-starter 등)은 `common`에, 서비스별 의존성은 각 모듈에 분리

## 위치
- `/build.gradle`, `/settings.gradle`, 각 모듈별 `/build.gradle`

## 완료 상태
- ✅ Gradle 멀티모듈 구조 최신화
