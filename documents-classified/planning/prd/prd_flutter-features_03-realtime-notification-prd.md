# Flutter 실시간 알림 시스템 PRD

## 1. 개요
**목적**: 사용자에게 즉시성 있는 알림 서비스 제공  
**대상**: 신고자, 관리자, 관련 담당자  
**우선순위**: 높음 (High)

## 2. 현재 상태
- **기존 구현**: `WebSocketService` 기본 구조만 존재
- **구현률**: 5% (연결 코드만)
- **누락 기능**: 알림 UI, 푸시 알림, 상태 관리, 알림 센터

## 3. 상세 요구사항

### 3.1 실시간 알림 수신 (`NotificationService`)
```yaml
WebSocket 연동:
  - 서버 연결 관리 (/ws/notifications)
  - 자동 재연결 로직
  - 연결 상태 모니터링
  - 메시지 큐 관리

알림 타입:
  - REPORT_STATUS: 신고서 상태 변경
  - COMMENT_NEW: 새 댓글 작성
  - COMMENT_REPLY: 댓글 답글
  - ADMIN_MESSAGE: 관리자 메시지
  - SYSTEM_NOTICE: 시스템 공지
  - EMERGENCY: 긴급 알림

실시간 처리:
  - 즉시 알림 표시
  - 배지 카운트 업데이트
  - 소리/진동 알림
  - 화면 상단 토스트 표시
```

### 3.2 푸시 알림 시스템 (`PushNotificationService`)
```yaml
Firebase 연동:
  - FCM 토큰 관리
  - 토큰 갱신 처리
  - 플랫폼별 설정 (iOS/Android)
  - 권한 요청 관리

알림 형태:
  - 일반 푸시 (제목, 내용, 액션)
  - 리치 푸시 (이미지, 버튼)
  - 그룹 푸시 (카테고리별 묶기)
  - 조용한 푸시 (백그라운드 업데이트)

개인화:
  - 사용자별 알림 설정
  - 카테고리별 ON/OFF
  - 시간대 설정 (방해금지)
  - 우선순위별 알림 방식

기술 구현:
  - firebase_messaging: ^14.7.9
  - flutter_local_notifications: ^16.3.0
  - permission_handler: ^11.1.0
```

### 3.3 알림 센터 화면 (`NotificationCenterScreen`)
```yaml
알림 목록:
  - 시간순 정렬 (최신순)
  - 읽음/안읽음 상태 표시
  - 카테고리별 아이콘
  - 중요도별 색상 코딩

상호작용:
  - 개별 알림 읽음 처리
  - 전체 읽음 처리
  - 알림 삭제 (스와이프)
  - 관련 화면으로 이동

필터링:
  - 전체/안읽음/읽음
  - 카테고리별 필터
  - 날짜별 필터
  - 중요도별 필터

검색 기능:
  - 알림 내용 검색
  - 발신자별 검색
  - 날짜 범위 검색
  - 저장된 검색어
```

### 3.4 인앱 알림 표시 (`InAppNotificationWidget`)
```yaml
표시 방식:
  - 상단 슬라이드 다운 (기본)
  - 하단 스낵바
  - 중앙 다이얼로그 (중요)
  - 플로팅 버블 (지속)

애니메이션:
  - 부드러운 슬라이드 인/아웃
  - 페이드 효과
  - 바운스 효과 (중요 알림)
  - 맥박 애니메이션 (긴급)

자동 숨김:
  - 일반 알림: 3초
  - 중요 알림: 5초
  - 긴급 알림: 수동 닫기
  - 사용자 설정 가능

터치 액션:
  - 탭: 관련 화면 이동
  - 스와이프: 알림 닫기
  - 길게 누르기: 상세 정보
  - 더블 탭: 즉시 처리
```

### 3.5 알림 설정 화면 (`NotificationSettingsScreen`)
```yaml
전역 설정:
  - 알림 전체 ON/OFF
  - 푸시 알림 허용
  - 소리 설정
  - 진동 설정
  - LED 알림 (Android)

카테고리별 설정:
  - 신고서 상태 알림
  - 댓글 알림
  - 관리자 메시지 알림
  - 시스템 공지 알림

시간 설정:
  - 방해금지 시간 설정
  - 주말/휴일 설정
  - 즉시/배치 발송 선택
  - 시간대별 우선순위

고급 설정:
  - 알림 그룹화
  - 중복 알림 방지
  - 스마트 알림 (AI 기반)
  - 예약 알림 취소
```

## 4. 알림 데이터 모델

### 4.1 Notification 모델
```dart
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationType type,
    required String title,
    required String message,
    String? imageUrl,
    Map<String, dynamic>? data,
    required DateTime createdAt,
    @Default(false) bool isRead,
    @Default(NotificationPriority.normal) NotificationPriority priority,
    String? actionUrl,
    List<NotificationAction>? actions,
  }) = _AppNotification;
}

enum NotificationType {
  reportStatus,
  commentNew,
  commentReply,
  adminMessage,
  systemNotice,
  emergency,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}
```

### 4.2 NotificationAction 모델
```dart
@freezed
class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    required String id,
    required String title,
    required String actionType,
    Map<String, dynamic>? data,
  }) = _NotificationAction;
}
```

## 5. 상태 관리 구조

### 5.1 NotificationState
```dart
@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default([]) List<AppNotification> notifications,
    @Default(0) int unreadCount,
    @Default(false) bool isConnected,
    @Default(false) bool isLoading,
    NotificationSettings? settings,
    String? error,
  }) = _NotificationState;
}
```

### 5.2 NotificationNotifier
```dart
class NotificationNotifier extends StateNotifier<NotificationState> {
  Future<void> initialize();
  Future<void> connectWebSocket();
  void handleWebSocketMessage(Map<String, dynamic> message);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> updateSettings(NotificationSettings settings);
}
```

## 6. WebSocket 통신 프로토콜

### 6.1 연결 관리
```yaml
연결 URL: ws://localhost:8080/ws/notifications
인증: JWT 토큰 헤더 전송
하트비트: 30초마다 ping/pong
재연결: 지수 백오프 (1s, 2s, 4s, 8s, 16s)
```

### 6.2 메시지 형태
```json
{
  "type": "NOTIFICATION",
  "data": {
    "id": "notif_123",
    "type": "REPORT_STATUS",
    "title": "신고서 처리 완료",
    "message": "귀하의 신고서가 처리 완료되었습니다.",
    "priority": "normal",
    "createdAt": "2025-07-13T10:30:00Z",
    "data": {
      "reportId": "report_456",
      "status": "completed"
    }
  }
}
```

## 7. 푸시 알림 구현

### 7.1 Firebase 설정
```yaml
Android 설정:
  - google-services.json 추가
  - Firebase SDK 초기화
  - 알림 채널 설정
  - 아이콘/색상 설정

iOS 설정:
  - GoogleService-Info.plist 추가
  - APNs 인증서 설정
  - Info.plist 권한 설정
  - Notification Service Extension
```

### 7.2 토큰 관리
```dart
class FCMTokenManager {
  Future<String?> getToken();
  Future<void> refreshToken();
  void onTokenRefresh(Function(String) callback);
  Future<void> deleteToken();
}
```

## 8. 로컬 알림 구현

### 8.1 스케줄링
```yaml
즉시 알림:
  - 앱 포그라운드: 인앱 알림
  - 앱 백그라운드: 로컬 푸시

예약 알림:
  - 특정 시간 알림
  - 반복 알림 (일일/주간)
  - 위치 기반 알림
  - 조건부 알림

알림 채널:
  - 일반 알림 (기본 소리)
  - 중요 알림 (높은 소리)
  - 긴급 알림 (연속 알림)
  - 조용한 알림 (진동만)
```

### 8.2 플랫폼별 차이점
```yaml
Android:
  - 알림 채널 관리
  - 적응형 아이콘
  - 액션 버튼 (최대 3개)
  - 대형 텍스트/이미지

iOS:
  - 카테고리 기반 그룹화
  - 3D Touch 미리보기
  - 액션 버튼 지원
  - 리치 알림 확장
```

## 9. 성능 최적화

### 9.1 메모리 관리
```yaml
알림 캐싱:
  - 최근 100개 알림만 메모리 유지
  - 오래된 알림 자동 정리
  - 이미지 캐시 제한 (50MB)
  - WeakReference 사용

배치 처리:
  - 알림 일괄 읽기 처리
  - WebSocket 메시지 큐잉
  - 백그라운드 동기화
  - 중복 요청 방지
```

### 9.2 배터리 최적화
```yaml
스마트 폴링:
  - 앱 사용 패턴 학습
  - 적응형 폴링 간격
  - 배터리 상태 고려
  - 도즈 모드 대응

효율적 연결:
  - WebSocket 연결 풀링
  - 연결 상태 최적화
  - 불필요한 재연결 방지
  - 네트워크 상태 모니터링
```

## 10. 접근성 및 사용성

### 10.1 접근성 지원
```yaml
시각 장애인:
  - TalkBack/VoiceOver 지원
  - 알림 내용 음성 읽기
  - 고대비 모드 지원
  - 큰 글꼴 대응

청각 장애인:
  - 시각적 알림 강화
  - 진동 패턴 다양화
  - LED 알림 활용
  - 화면 플래시 옵션
```

### 10.2 사용자 경험
```yaml
직관적 인터페이스:
  - 명확한 알림 분류
  - 일관된 디자인 언어
  - 쉬운 설정 접근
  - 도움말 및 튜토리얼

개인화:
  - 사용자 학습 기반 추천
  - 커스텀 알림 톤
  - 개인별 우선순위 설정
  - 사용 패턴 분석
```

## 11. 보안 및 개인정보

### 11.1 데이터 보호
```yaml
암호화:
  - 알림 내용 암호화 저장
  - 전송 중 암호화 (TLS)
  - 민감 정보 마스킹
  - 로컬 DB 암호화

권한 관리:
  - 최소 권한 원칙
  - 권한 요청 설명
  - 권한 재요청 로직
  - 권한 거부 시 대응
```

### 11.2 개인정보 보호
```yaml
데이터 수집:
  - 필요 최소한 정보만 수집
  - 사용자 동의 기반
  - 목적 외 사용 금지
  - 보관 기간 제한

투명성:
  - 알림 발송 이유 명시
  - 데이터 사용 내역 공개
  - 설정 변경 알림
  - 개인정보 삭제 옵션
```

## 12. 테스트 전략

### 12.1 기능 테스트
- WebSocket 연결/재연결 테스트
- 푸시 알림 수신 테스트
- 알림 설정 변경 테스트
- 플랫폼별 동작 테스트

### 12.2 성능 테스트
- 대량 알림 처리 테스트
- 메모리 사용량 테스트
- 배터리 소모량 테스트
- 네트워크 효율성 테스트

### 12.3 사용자 테스트
- 알림 이해도 테스트
- 설정 사용성 테스트
- 접근성 테스트
- 다양한 기기 테스트

## 13. 구현 일정

### 주차별 계획
```yaml
1-2주차:
  - WebSocket 연결 구현
  - 기본 알림 수신/표시
  - 상태 관리 구조
  - 알림 센터 기본 UI

3-4주차:
  - 푸시 알림 연동
  - 로컬 알림 구현
  - 알림 설정 화면
  - 인앱 알림 위젯

5-6주차:
  - 성능 최적화
  - 접근성 구현
  - 보안 강화
  - 플랫폼별 최적화

7주차:
  - 테스트 작성
  - 버그 수정
  - 문서화 완성
  - 배포 준비
```

**총 구현 기간**: 7주  
**개발자 소요**: 1명 풀타임  
**우선순위**: High (사용자 경험 핵심 요소)