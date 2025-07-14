# 전북 리포트 플랫폼 - 분류된 문서 인덱스

분류 완료 시간: 2025-07-13 15:50:00

## 📊 분류 통계 요약

- **총 분류된 문서**: 99개
- **카테고리**: 6개 주요 분류
- **분류 성공률**: 97% (102개 중 99개 분류 완료)

## 📁 카테고리별 문서 현황

### 📋 Planning (40개) - 40.4%
기획, PRD, 요구사항 관련 문서들
- `prd/` - Product Requirements Documents (35개)
- `requirements/` - 요구사항 문서
- `features/` - 기능 명세서

### 🔧 Service (21개) - 21.2%
서비스 개발 및 API 관련 문서들
- `api/` - API 명세서 및 문서 (5개)
- `implementation/` - 구현 관련 문서 (16개)

### 📊 Analysis (15개) - 15.2%
분석 보고서 및 오류 해결 문서들
- `error-reports/` - 오류 분석 보고서 (7개)
- `completion-status/` - 완성도 분석 (8개)

### 📚 General (13개) - 13.1%
일반 문서 및 가이드
- `guides/` - 사용자 가이드 (1개)
- `documentation/` - 기타 문서 (12개)

### 🏗️ Infrastructure (6개) - 6.1%
인프라 설정 및 배포 관련
- `setup/` - 설정 가이드 (4개)
- `database/` - 데이터베이스 관련 (1개)
- `deployment/` - 배포 관련 (1개)

### 🧪 Testing (3개) - 3.0%
테스트 및 검증 문서
- `validation/` - 검증 문서 (3개)

## 🔍 빠른 탐색 가이드

### 프로젝트 시작하기
```bash
cd documents-classified/infrastructure/setup
# QUICK_START_GUIDE.md, API_KEYS_GUIDE.md 확인
```

### API 개발 참고
```bash
cd documents-classified/service/api
# API 명세서 및 구현 가이드 확인
```

### 오류 해결
```bash
cd documents-classified/analysis/error-reports
# 기존 오류 해결 사례 확인
```

### 기획 문서 검토
```bash
cd documents-classified/planning/prd
# PRD 및 기능 명세서 확인
```

## 📋 문서 검색 방법

### 키워드로 검색
```bash
# 전체 문서에서 특정 키워드 검색
grep -r "API" documents-classified/

# 특정 카테고리에서 검색
grep -r "OAuth" documents-classified/service/
```

### 최근 수정된 문서
```bash
find documents-classified -name "*.md" -type f -exec ls -lt {} + | head -10
```

### 파일 크기별 정렬
```bash
find documents-classified -name "*.md" -exec ls -lS {} + | head -10
```

## 🎯 활용 권장사항

1. **새 팀원 온보딩**: `infrastructure/setup/` 디렉토리부터 시작
2. **기능 개발**: `planning/prd/` 에서 요구사항 확인 후 `service/` 참고
3. **문제 해결**: `analysis/error-reports/` 에서 유사 사례 검색
4. **테스트**: `testing/validation/` 에서 기존 테스트 케이스 참고

## 📞 문의 및 개선

문서 분류 관련 문의사항이나 개선 제안은 프로젝트 관리자에게 연락하세요.

---

**마지막 업데이트**: 2025-07-13 15:50:00  
**분류 시스템**: 자동화된 키워드 기반 분류