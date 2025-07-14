# 파일 및 디렉토리 생성/정리 지침서

이 문서는 프로젝트 내 파일 및 디렉토리 생성 시 혼잡을 방지하고, 일관된 구조를 유지하기 위한 규칙을 안내합니다. AI agent 및 모든 개발자는 아래 지침을 반드시 준수해야 합니다.

## 1. 파일 유형별 저장 위치

- **테스트 코드 및 테스트 데이터**
  - 모든 테스트 관련 파일(코드, 리포트, 테스트 이미지 등)은 반드시 `test/` 디렉토리 하위에 저장
  - 예: `test/report/`, `test/images/`, `test/<feature>_test.py`

- **문서 파일**
  - 모든 문서(가이드, 회의록, 분석, PRD 등)는 `docs/` 디렉토리 하위에 저장
  - AI agent 참고용 문서는 `docs/AI-agent/` 하위에 저장
  - 예: `docs/AI-agent/FILE_ORGANIZATION_GUIDE.md`, `docs/01-getting-started/quick-start-guide.md`

- **스크립트 파일**
  - 빌드, 배포, 데이터 초기화 등 자동화/운영 스크립트는 `shellscript/` 디렉토리 하위에 저장
  - 예: `shellscript/build.sh`, `shellscript/init-scripts/01-create-database.sql`

- **소스 코드**
  - 각 서비스별 소스코드는 해당 서비스 디렉토리(예: `main-api-server/`, `ai-analysis-server/`, `flutter-app/`) 하위에 저장

## 2. 네이밍 및 구조 규칙

- 새 폴더/파일 생성 시 의미 있는 이름 사용 (예: `user_management_test.dart`, `database-migration-guide.md`)
- 임시/실험 파일은 반드시 삭제하거나, `tmp/` 또는 `.temp/` 하위에만 생성
- 불필요한 중복 파일, 오래된 파일은 주기적으로 정리

## 3. 금지 및 주의 사항

- 프로젝트 루트(최상위)에 파일을 직접 생성하지 않는다 (README, .env 등 필수 파일 제외)
- 테스트, 문서, 스크립트 파일이 섞여 있지 않도록 반드시 분리
- 대용량 데이터, 민감 정보는 별도 관리 지침에 따름

## 4. 예시

**올바른 예시**
- `test/images/sample1.png`
- `docs/AI-agent/FILE_ORGANIZATION_GUIDE.md`
- `shellscript/deploy-production.sh`
- `main-api-server/src/main/java/...`

**잘못된 예시**
- `테스트코드.java` (루트에 생성)
- `deploy.sh` (루트에 생성)
- `문서.txt` (루트에 생성)

---

이 지침서는 프로젝트 유지보수와 협업 효율성을 높이기 위해 반드시 준수해야 합니다. 추가 문의나 예외 상황은 `docs/AI-agent/` 내에 별도 문서로 기록 바랍니다.
