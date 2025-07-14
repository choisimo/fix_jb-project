# 01. 공통 모듈 분리 및 통합 (최신화)

## 목적
- Entity, DTO, Repository, Exception, Util 등 중복/공통 코드를 별도 `/common` 모듈로 분리하여 재사용성과 유지보수성 강화

## 최신 작업 내역
- `/common/domain/entity`: User, Report, Status, Category, Notification 등 공통 Entity 최신화
- `/common/domain/repository`: UserRepository, ReportRepository 등 공통 Repository 최신화
- `/common/dto/request`, `/common/dto/response`: ApiResponse, AuthResponse, UserResponse 등 공통 DTO 최신화
- `/common/exception`, `/common/util`: 공통 Exception, Util 클래스 최신화
- 각 서비스(Spring, AI, Flutter)에서 공통 모듈 의존성 추가 및 활용

## 위치
- `/main-api-server/src/main/java/com/jeonbuk/report/common`
- `/ai-analysis-server/src/main/java/com/jeonbuk/report/domain/common`

## 완료 상태
- ✅ 모든 공통 Entity/Repository/DTO/Exception/Util 분리 및 통합 최신화
