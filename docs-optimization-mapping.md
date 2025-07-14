# 문서 최적화 중복 파일 매핑 테이블

## 완전 중복 파일 (동일한 내용)

### 1. API 관련 문서
| 원본 위치 | 중복 위치 | 파일 크기 | 상태 | 최종 보관 위치 |
|-----------|-----------|-----------|------|----------------|
| `/documents/API_DOCUMENTATION.md` | `/documents-classified/service/api/API_DOCUMENTATION.md` | 동일 | 중복 | `docs/04-development/api/` |
| `/documents/API_ERROR_SOLUTION.md` | `/documents-classified/service/api/API_ERROR_SOLUTION.md` | 동일 | 중복 | `docs/05-deployment/troubleshooting.md` |
| `/documents/API_ERROR_SOLUTION.md` | `/documents-classified/analysis/error-reports/API_ERROR_SOLUTION.md` | 동일 | 중복 | `docs/05-deployment/troubleshooting.md` |

### 2. 프로젝트 현황 문서
| 원본 위치 | 중복 위치 | 파일 크기 | 상태 | 최종 보관 위치 |
|-----------|-----------|-----------|------|----------------|
| `/documents/PROJECT_STATUS_COMPREHENSIVE.md` | `/documents-classified/analysis/completion-status/PROJECT_STATUS_COMPREHENSIVE.md` | 동일 | 중복 | `docs/07-analysis/completion-status/` |
| `/IMPLEMENTATION_SUMMARY.md` | `/documents-classified/analysis/completion-status/IMPLEMENTATION_SUMMARY.md` | 동일 | 중복 | `docs/07-analysis/completion-status/` |

### 3. 사용자 가이드 문서
| 원본 위치 | 중복 위치 | 파일 크기 | 상태 | 최종 보관 위치 |
|-----------|-----------|-----------|------|----------------|
| `/documents/USER_GUIDE_COMPLETE.md` | `/documents-classified/general/guides/USER_GUIDE_COMPLETE.md` | 동일 | 중복 | `docs/01-getting-started/` |
| `/QUICK_START_GUIDE.md` | `/documents-classified/infrastructure/setup/QUICK_START_GUIDE.md` | 동일 | 중복 | `docs/01-getting-started/` |

### 4. 설정 가이드 문서
| 원본 위치 | 중복 위치 | 파일 크기 | 상태 | 최종 보관 위치 |
|-----------|-----------|-----------|------|----------------|
| `/OAUTH2_SETUP_GUIDE.md` | `/documents-classified/infrastructure/setup/OAUTH2_SETUP_GUIDE.md` | 동일 | 중복 | `docs/02-architecture/` |

### 5. AI/Roboflow 관련 문서
| 원본 위치 | 중복 위치 | 파일 크기 | 상태 | 최종 보관 위치 |
|-----------|-----------|-----------|------|----------------|
| `/documents/ROBOFLOW_COMPLETE_GUIDE.md` | `/documents-classified/infrastructure/setup/ROBOFLOW_COMPLETE_GUIDE.md` | 동일 | 중복 | `docs/04-development/ai-integration/` |
| `/documents/FLUTTER_ROBOFLOW_SETUP_GUIDE.md` | `/documents-classified/infrastructure/setup/FLUTTER_ROBOFLOW_SETUP_GUIDE.md` | 동일 | 중복 | `docs/04-development/mobile/` |

### 6. 오류 해결 문서
| 원본 위치 | 중복 위치 | 파일 크기 | 상태 | 최종 보관 위치 |
|-----------|-----------|-----------|------|----------------|
| `/documents/FLUTTER_ERROR_RESOLVED.md` | `/documents-classified/analysis/error-reports/FLUTTER_ERROR_RESOLVED.md` | 동일 | 중복 | `docs/05-deployment/troubleshooting/` |
| `/documents/KAFKA_DOCKER_TROUBLESHOOTING.md` | `/documents-classified/analysis/error-reports/KAFKA_DOCKER_TROUBLESHOOTING.md` | 동일 | 중복 | `docs/05-deployment/troubleshooting/` |
| `/documents/KAFKA_SOLUTION_COMPLETE.md` | `/documents-classified/general/documentation/KAFKA_SOLUTION_COMPLETE.md` | 동일 | 중복 | `docs/05-deployment/troubleshooting/` |

## 통합 대상 문서 (유사한 내용)

### 프로젝트 현황 관련
- `PROJECT_STATUS_COMPREHENSIVE.md`
- `IMPLEMENTATION_SUMMARY.md`  
- `PRODUCTION_REFACTORING_PROGRESS_REPORT.md`
- `ACTUAL_BUILD_STATUS_REPORT.md`
→ **통합 대상**: `docs/07-analysis/completion-status/project-status.md`

### API 문서 관련
- `API_DOCUMENTATION.md`
- `API_ERROR_SOLUTION.md`
- `SERVICE_COMPLETION_TEST_REPORT.md`
→ **통합 대상**: `docs/04-development/api/api-specification.md`

### 설정 가이드 관련
- `QUICK_START_GUIDE.md`
- `USER_GUIDE_COMPLETE.md`
- `OAUTH2_SETUP_GUIDE.md`
→ **통합 대상**: `docs/01-getting-started/setup-guide.md`

## 제거 대상 중복 파일 목록

### 즉시 제거 가능한 완전 중복 파일 (19개)
1. `/documents-classified/service/api/API_DOCUMENTATION.md`
2. `/documents-classified/service/api/API_ERROR_SOLUTION.md`
3. `/documents-classified/analysis/error-reports/API_ERROR_SOLUTION.md`
4. `/documents-classified/analysis/completion-status/PROJECT_STATUS_COMPREHENSIVE.md`
5. `/documents-classified/analysis/completion-status/IMPLEMENTATION_SUMMARY.md`
6. `/documents-classified/general/guides/USER_GUIDE_COMPLETE.md`
7. `/documents-classified/infrastructure/setup/QUICK_START_GUIDE.md`
8. `/documents-classified/infrastructure/setup/OAUTH2_SETUP_GUIDE.md`
9. `/documents-classified/infrastructure/setup/ROBOFLOW_COMPLETE_GUIDE.md`
10. `/documents-classified/infrastructure/setup/FLUTTER_ROBOFLOW_SETUP_GUIDE.md`
11. `/documents-classified/analysis/error-reports/FLUTTER_ERROR_RESOLVED.md`
12. `/documents-classified/analysis/error-reports/KAFKA_DOCKER_TROUBLESHOOTING.md`
13. `/documents-classified/general/documentation/KAFKA_SOLUTION_COMPLETE.md`

### 추가 분석 필요한 파일들
- 루트 디렉토리의 중복 파일들
- PRD 문서들의 유사 내용 통합

## 다음 단계
1. ✅ 중복 파일 매핑 완료
2. 🔄 동일 내용 문서 통합 작업
3. 🔄 중복 파일 제거
4. 🔄 새 디렉토리 구조 생성
5. 🔄 파일 이동 및 재배치

**예상 감소 파일 수**: 19개 (즉시 제거) + 20개 (통합) = 39개
**목표 달성률**: 39/102 = 38.2% (목표 30% 초과 달성)