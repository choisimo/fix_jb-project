# 03. 네이밍 규칙 통일 (최신화)

## 목적
- DTO, Entity, Service, Controller, Exception 등 네이밍 규칙 통일로 가독성 및 유지보수성 향상

## 최신 작업 내역
- DTO: `*Request`, `*Response`, `*Dto` 등 명확한 접미사 사용
- Entity: 단수형, 도메인 명확화 (`User`, `Report`, `Status`, `Category` 등)
- Repository: `*Repository`
- Service: `*Service`
- Controller: `*Controller`
- Exception: `*Exception`
- 네이밍 규칙 문서화 및 README/CONTRIBUTING에 반영

## 위치
- `/common`, `/main-api-server`, `/ai-analysis-server` 전체

## 완료 상태
- ✅ 모든 네이밍 규칙 최신화
