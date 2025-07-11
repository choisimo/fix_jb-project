# 서비스 미구현 항목 (2025-07-12)

## main-api-server

- AiRoutingService.java
  - Line 51: // TODO: AI 라우팅 핵심 로직 미구현
  - Line 56: String dominantCategory = "GENERAL"; // TODO: 임시값
- IntegratedAiAgentService.java
  - Line 170, 207: // JSON 부분 추출 (TODO): AI 에이전트 통합 미구현
- KafkaTicketService.java
  - Line 13, 18: // TODO: Kafka 티켓 처리 미구현
- GisService.java
  - Line 13, 17: // TODO: GIS 서비스 미구현
- PriorityEscalationService.java
  - Line 13, 17: // TODO: 우선순위 상승 로직 미구현
- AlertService.java
  - Line 298, 302: // TODO: 알림 서비스 미구현, 임시 JSON 파싱
- ImageAnalysisService.java
  - Line 328, 331: // TODO: 이미지 분석 미구현, 임시 JSON 파싱
- FileService.java
  - Line 150: return null; // 파일 처리 미구현
- ValidationAiAgentService.java
  - Line 105: "Complete validation passed" // 임시 메시지

## ai-analysis-server

- IntegratedAiAgentService.java
  - Line 162, 203: // JSON 부분 추출 (TODO): AI 에이전트 통합 미구현
- ReportService.java
  - Line 43, 45, 52, 54, 61, 63, 71, 73, 81, 83, 90, 92, 99, 101, 109, 111, 119, 121: // TODO, throw new UnsupportedOperationException("Not implemented yet");: 신고 서비스 주요 기능 미구현
- AlertService.java
  - Line 296, 300: // TODO: 알림 서비스 미구현, 임시 JSON 파싱
- ImageAnalysisService.java
  - Line 325, 328: // TODO: 이미지 분석 미구현, 임시 JSON 파싱
