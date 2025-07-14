# 02. 폴더/패키지 구조 통일 (최신화)

## 목적
- 모든 백엔드/AI/앱 모듈이 동일한 폴더/패키지 구조를 사용하여 일관성 및 유지보수성 강화

## 최신 작업 내역
- main-api-server, ai-analysis-server 모두 아래와 같이 통일:
  - `application/service`, `domain/entity`, `domain/repository`, `infrastructure/config`, `infrastructure/external`, `infrastructure/security`, `presentation/controller`, `presentation/dto`
- 실제 예시:
  - `/main-api-server/src/main/java/com/jeonbuk/report/application/service/AiRoutingService.java`
  - `/ai-analysis-server/src/main/java/com/jeonbuk/report/application/service/AiRoutingService.java`

## 위치
- `/main-api-server/src/main/java/com/jeonbuk/report/`
- `/ai-analysis-server/src/main/java/com/jeonbuk/report/`

## 완료 상태
- ✅ 모든 모듈 폴더/패키지 구조 통일 최신화
