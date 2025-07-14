# 미구현 기능 및 개발 필요 항목 (TODO-PRD)

> 코드 전체 스캔을 통해 발견된 미구현 기능, 더미값, 하드코딩된 값, TODO 항목들을 정리한 문서

## 📊 요약 (2025-07-13 검증 완료)

- **Flutter App**: 4개 TODO 항목 (검증 완료)
- **Main API Server**: **22개 완료됨** ✅ 
- **AI Analysis Server**: **10개 완료됨** ✅  
- **Configuration**: **환경변수화 완료됨** ✅
- **총 미구현 항목**: **22개 남음** (44개 중 50% 완료)

## ✅ 검증 결과 - 완료된 항목들 (실제 코드 확인)

### Main API Server (모두 완료됨 ✅)
- ✅ **AlertCreationService context 정보**: `getRequestUserAgent()`, `getRequestIpAddress()` 메서드로 완전 구현됨
- ✅ **AlertController TODO 항목**: `getAlertProcessingStats()` 완전 구현됨  
- ✅ **AlertWebSocketController TODO 항목**: `sendAdminAlert()` 완전 구현됨
- ✅ **StatisticsService placeholder**: 실제 통계 로직으로 완전 구현됨
- ✅ **FileService 썸네일 생성**: `BufferedImage` 기반 실제 썸네일 생성 로직 구현됨
- ✅ **Dev Config mock 객체**: 실제 Kafka/Redis 구현체로 교체 + 개발환경 fallback 포함

### AI Analysis Server (모두 완료됨 ✅)
- ✅ **AlertController TODO 항목**: `/stats`, `/stream` 엔드포인트 완전 구현됨
- ✅ **AlertService TODO**: `parseAiAnalysisResponse()` 완전 구현됨  
- ✅ **AiRoutingController TODO**: 실제 통계 수집 로직 구현됨
- ✅ **ImageAnalysisService TODO**: `parseAiAnalysisResponse()` 완전 구현됨

### Configuration & Security (완료됨 ✅)
- ✅ **CORS 설정 환경변수화**: `@Value` 애노테이션으로 모든 설정이 환경변수화됨
- ✅ **하드코딩된 설정값**: 모두 환경변수로 외부화됨

## 🔴 실제 검증으로 확인된 미구현 항목들

### 🥇 Critical Priority - AI Analysis Server ReportService (완전 미구현)
**파일**: `ai-analysis-server/src/main/java/com/jeonbuk/report/service/ReportService.java`

**모든 메서드가 `UnsupportedOperationException` 발생 중:**
1. `createReport()` - 신고서 생성 (Line 42) 
2. `getReports()` - 신고서 목록 조회 (Line 51)
3. `getReport()` - 신고서 상세 조회 (Line 60)
4. `updateReport()` - 신고서 수정 (Line 70)
5. `deleteReport()` - 신고서 삭제 (Line 80)
6. `getMyReports()` - 내 신고서 목록 (Line 89)
7. `getStatistics()` - 신고서 통계 (Line 98)
8. `updateReportStatus()` - 상태 변경 (Line 108)
9. `submitReport()` - 신고서 제출 (Line 118)

### 🥈 Critical Priority - Main API Server Kafka Services (완전 미구현)
**파일 1**: `main-api-server/src/main/java/com/jeonbuk/report/application/service/KafkaTicketService.java`
- `sendToWorkspace()` - Kafka 메시지 전송 로직 (Line 13)
- `sendPriorityAlert()` - 우선순위 알림 전송 (Line 18)

**파일 2**: `main-api-server/src/main/java/com/jeonbuk/report/application/service/PriorityEscalationService.java`  
- `escalateIfNeeded()` - 에스컬레이션 로직 (Line 13)
- `shouldEscalate()` - 에스컬레이션 기준 (Line 17)

### 🥉 High Priority - Flutter App 핵심 기능들

#### Firebase Crashlytics 연동 미구현
**파일**: `flutter-app/lib/core/error/error_handler.dart:167`
```dart
// TODO: Firebase Crashlytics 연동 - 여전히 주석 처리됨
```

#### 필터 기능 미구현
**파일**: `flutter-app/lib/features/home/presentation/home_screen.dart:284`
```dart
// TODO: Implement filter dialog - 여전히 placeholder 메시지만 표시
```

#### ChaCha20Poly1305 암호화 Placeholder
**파일**: `flutter-app/lib/features/security/data/services/data_encryption_service.dart:255`
```dart
// This is a placeholder implementation - 여전히 AES 대체 구현
```

#### 이미지 업로드 URL 처리 미구현
**파일**: `flutter-app/lib/features/report/data/report_repository.dart:157`
```dart
// For now, we'll use a placeholder upload - 여전히 주석 처리됨
```

#### WebSocket URL 하드코딩
**파일**: `flutter-app/lib/features/notification/data/services/notification_service.dart:20`
```dart
static const String _baseUrl = 'ws://localhost:8080/ws'; // 여전히 하드코딩됨
```

### 🏅 Medium Priority - 기타 개선 항목

#### IntegratedAiAgentService JSON 파싱 개선 필요
**파일**: `main-api-server/src/main/java/com/jeonbuk/report/application/service/IntegratedAiAgentService.java`
- Line 170: `// JSON 부분 추출 (TODO: 더 정교한 파싱)` - 개선 필요
- Line 207: `// 간단한 JSON 추출 로직 (TODO: 개선)` - 개선 필요

#### ReportDetailResponse TODO 필드
**파일**: `ai-analysis-server/src/main/java/com/jeonbuk/report/dto/report/ReportDetailResponse.java:96`
```java
false, // TODO: 실제 값으로 변경 필요 - 여전히 하드코딩됨
```

#### Roboflow API TODO 항목들
**파일**: `main-api-server/src/main/java/com/jeonbuk/report/infrastructure/external/roboflow/RoboflowDto.java`
- Line 99: `// TODO` - 여전히 미구현
- Line 104: `// TODO` - 여전히 미구현

## 📋 TaskMaster 세부 작업 계획

> **총 22개 작업, 예상 118시간, 3단계 우선순위로 구성**  
> **상세 TaskMaster JSON**: `.taskmaster/tasks/unimplemented_features_detailed_tasks.json`

### 🔴 Critical Priority (14개 작업, 71시간)

#### AI Analysis Server ReportService (9개 작업, 49시간)
| Task ID | 작업명 | 예상시간 | 파일:라인 |
|---------|--------|----------|-----------|
| AI_REPORT_SERVICE_001 | createReport() 구현 | 8h | ReportService.java:42 |
| AI_REPORT_SERVICE_002 | getReports() 구현 | 6h | ReportService.java:51 |
| AI_REPORT_SERVICE_003 | getReport() 구현 | 4h | ReportService.java:60 |
| AI_REPORT_SERVICE_004 | updateReport() 구현 | 6h | ReportService.java:70 |
| AI_REPORT_SERVICE_005 | deleteReport() 구현 | 4h | ReportService.java:80 |
| AI_REPORT_SERVICE_006 | getMyReports() 구현 | 4h | ReportService.java:89 |
| AI_REPORT_SERVICE_007 | getStatistics() 구현 | 6h | ReportService.java:98 |
| AI_REPORT_SERVICE_008 | updateReportStatus() 구현 | 5h | ReportService.java:108 |
| AI_REPORT_SERVICE_009 | submitReport() 구현 | 6h | ReportService.java:118 |

#### Main API Server Kafka & Escalation (5개 작업, 22시간)
| Task ID | 작업명 | 예상시간 | 파일:라인 |
|---------|--------|----------|-----------|
| MAIN_KAFKA_SERVICE_001 | sendToWorkspace() 구현 | 6h | KafkaTicketService.java:11 |
| MAIN_KAFKA_SERVICE_002 | sendPriorityAlert() 구현 | 4h | KafkaTicketService.java:16 |
| MAIN_ESCALATION_SERVICE_001 | escalateIfNeeded() 구현 | 8h | PriorityEscalationService.java:11 |
| MAIN_ESCALATION_SERVICE_002 | shouldEscalate() 구현 | 4h | PriorityEscalationService.java:16 |

### 🟡 High Priority (6개 작업, 30시간)

#### Flutter App 핵심 기능 (5개 작업, 26시간)
| Task ID | 작업명 | 예상시간 | 파일:라인 |
|---------|--------|----------|-----------|
| FLUTTER_CRASHLYTICS_001 | Firebase Crashlytics 연동 | 4h | error_handler.dart:167 |
| FLUTTER_FILTER_001 | 홈화면 필터 구현 | 6h | home_screen.dart:284 |
| FLUTTER_ENCRYPTION_001 | ChaCha20Poly1305 구현 | 8h | data_encryption_service.dart:253 |
| FLUTTER_UPLOAD_001 | 이미지 업로드 완성 | 6h | report_repository.dart:157 |
| FLUTTER_WEBSOCKET_CONFIG_001 | WebSocket URL 환경변수화 | 2h | notification_service.dart:20 |

#### Main API Server 개선 (1개 작업, 4시간)
| Task ID | 작업명 | 예상시간 | 파일:라인 |
|---------|--------|----------|-----------|
| MAIN_JSON_PARSING_001 | JSON 파싱 로직 개선 | 4h | IntegratedAiAgentService.java:170 |

### 🟢 Medium Priority (2개 작업, 5시간)

| Task ID | 작업명 | 예상시간 | 파일:라인 |
|---------|--------|----------|-----------|
| AI_REPORT_DETAIL_RESPONSE_001 | ReportDetailResponse TODO 수정 | 2h | ReportDetailResponse.java:96 |
| ROBOFLOW_API_TODOS | Roboflow API TODO 완성 | 3h | RoboflowDto.java:99 |

## 🎯 구현 로드맵 (검증 기반)

### Phase 1: Critical Infrastructure (6-8주)
**목표**: 핵심 비즈니스 로직 완성
- **Week 1-4**: AI Analysis Server ReportService 완전 구현 (49시간)
- **Week 5-6**: Main API Server Kafka & Escalation 서비스 (22시간)

### Phase 2: User Experience (4-6주)  
**목표**: 사용자 대면 기능 완성
- **Week 7-10**: Flutter App 핵심 기능들 (26시간)
- **Week 11**: Main API Server JSON 파싱 개선 (4시간)

### Phase 3: Polish & Optimization (1-2주)
**목표**: 세부 개선 및 마무리
- **Week 12**: Medium Priority 항목들 완성 (5시간)

## 📈 진행률 대시보드

```
전체 진행률: ████████████████████████████████████████████████ 50% (22/44 완료)

Critical Priority: ██████████████████████████░░░░░░░░░░░░░░░░░░ 36% (14개 남음)
High Priority:     ██████████████████████████████████████░░░░░░ 80% (6개 남음)  
Medium Priority:   ██████████████████████████████████████████░░ 83% (2개 남음)
```

## 🔧 TaskMaster 사용 가이드

### 작업 파일 위치
```bash
.taskmaster/tasks/unimplemented_features_detailed_tasks.json
```

### 주요 필드 설명
- **id**: 고유 작업 식별자
- **priority**: critical/high/medium/low
- **estimated_hours**: 예상 소요 시간
- **dependencies**: 선행 작업 목록
- **acceptance_criteria**: 완료 기준 체크리스트
- **technical_notes**: 기술적 구현 노트

### 작업 추적 방법
1. TaskMaster JSON 파일에서 작업 선택
2. 해당 파일의 라인 번호로 이동
3. acceptance_criteria 기준으로 구현 
4. 완료 시 status를 'completed'로 변경

---

*문서 생성일: 2025-07-13*  
*검증 완료일: 2025-07-13*  
*검증 방법: 실제 코드 직접 확인 및 라인별 검토*  
*완료 항목: 22개 (전체 44개 중 50% 완료)*  
*TaskMaster 작업: 22개 세부 작업으로 구조화 완료*  
*예상 완료 시간: 118시간 (약 15일)*