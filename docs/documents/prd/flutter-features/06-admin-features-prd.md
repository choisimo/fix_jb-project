# Flutter 관리자 기능 PRD

## 1. 개요
**목적**: 효율적인 신고서 관리 및 처리를 위한 관리자 전용 기능  
**대상**: 시스템 관리자, 담당 공무원, 처리 담당자  
**우선순위**: 높음 (High)

## 2. 현재 상태
- **기존 구현**: 없음 (완전 미구현)
- **구현률**: 0%
- **누락 기능**: 관리자 대시보드, 신고서 관리, 통계, 사용자 관리, 시스템 설정

## 3. 상세 요구사항

### 3.1 관리자 대시보드 (`AdminDashboardScreen`)
```yaml
개요 위젯:
  - 총 신고서 수 (오늘/이번 주/이번 달)
  - 처리 대기 중인 신고 수
  - 처리 완료율 (%)
  - 평균 처리 시간
  - 긴급 신고 알림

실시간 현황:
  - 신규 신고 실시간 알림
  - 처리 상태 변화 모니터링
  - 시스템 성능 지표
  - 사용자 접속 현황
  - 에러 및 예외 상황

빠른 액션:
  - 긴급 신고 바로 가기
  - 오늘의 할당 작업
  - 미처리 신고 목록
  - 시스템 공지 작성
  - 담당자 배정

차트 및 그래프:
  - 일별 신고 추이 라인 차트
  - 카테고리별 분포 도넛 차트
  - 지역별 신고 현황 히트맵
  - 처리 성과 바 차트
  - 사용자 활동 트렌드
```

### 3.2 신고서 관리 화면 (`AdminReportManagementScreen`)
```yaml
목록 관리:
  - 전체 신고서 목록 (페이징)
  - 고급 필터링 (상태/카테고리/담당자/기간)
  - 다중 선택 및 일괄 처리
  - 정렬 옵션 (날짜/우선순위/상태)
  - 검색 기능 (제목/내용/작성자)

상태 관리:
  - 신고서 상태 변경 (접수→처리중→완료→반려)
  - 담당자 배정/변경
  - 우선순위 조정
  - 처리 예상 시간 설정
  - 에스컬레이션 관리

상세 처리:
  - 신고서 상세 보기 (관리자 뷰)
  - 관리자 댓글 작성
  - 내부 메모 작성 (비공개)
  - 처리 결과 첨부
  - 유사 신고 연결

일괄 처리:
  - 다중 선택 처리
  - 상태 일괄 변경
  - 담당자 일괄 배정
  - 메시지 일괄 발송
  - 통계 데이터 일괄 업데이트
```

### 3.3 담당자 관리 (`AdminUserManagementScreen`)
```yaml
담당자 목록:
  - 전체 담당자 목록
  - 부서별/권한별 분류
  - 담당 업무 현황
  - 처리 성과 통계
  - 근무 상태 (온라인/오프라인)

권한 관리:
  - 역할 기반 권한 설정 (RBAC)
  - 기능별 접근 권한
  - 데이터 접근 범위 제한
  - 승인 워크플로우 설정
  - 감사 로그 확인

성과 관리:
  - 개인별 처리 실적
  - 처리 시간 분석
  - 품질 평가 점수
  - 사용자 만족도 평가
  - 목표 대비 달성률

업무 배정:
  - 자동 배정 규칙 설정
  - 수동 업무 배정
  - 업무량 밸런싱
  - 전문성 기반 배정
  - 긴급 상황 에스컬레이션
```

### 3.4 통계 및 분석 (`AdminAnalyticsScreen`)
```yaml
기본 통계:
  - 신고서 접수/처리/완료 현황
  - 일/주/월/년별 추이
  - 카테고리별 분포
  - 지역별 신고 현황
  - 처리 시간 통계

고급 분석:
  - 트렌드 분석 (계절성, 패턴)
  - 예측 분석 (향후 신고량 예측)
  - 상관관계 분석 (날씨, 이벤트 등)
  - 이상치 탐지 (비정상적 신고 패턴)
  - 효율성 분석 (처리 시간, 비용)

시각화:
  - 대화형 차트 (Plotly/Chart.js)
  - 지도 기반 시각화
  - 시계열 분석 차트
  - 히트맵 달력 뷰
  - 커스텀 대시보드

리포트 생성:
  - 자동 일/주/월 리포트
  - 커스텀 리포트 작성
  - PDF/Excel 내보내기
  - 이메일 자동 발송
  - 리포트 템플릿 관리
```

### 3.5 시스템 설정 (`AdminSystemSettingsScreen`)
```yaml
일반 설정:
  - 시스템 이름/로고 설정
  - 기본 언어/지역 설정
  - 타임존 설정
  - 연락처 정보 관리
  - 공지사항 관리

업무 설정:
  - 신고서 카테고리 관리
  - 상태 워크플로우 설정
  - 처리 시간 기준 설정
  - 자동 배정 규칙 관리
  - 에스컬레이션 정책

알림 설정:
  - 알림 템플릿 관리
  - 발송 조건 설정
  - 수신자 그룹 관리
  - 알림 스케줄 설정
  - 긴급 알림 정책

보안 설정:
  - 비밀번호 정책
  - 로그인 시도 제한
  - 세션 만료 시간
  - IP 화이트리스트
  - 감사 로그 정책
```

### 3.6 AI 관리 기능 (`AdminAIManagementScreen`)
```yaml
AI 모델 관리:
  - 이미지 분석 모델 설정
  - 텍스트 분석 모델 설정
  - 모델 성능 모니터링
  - 학습 데이터 관리
  - 모델 버전 관리

분석 결과 검토:
  - AI 분석 결과 확인
  - 정확도 평가
  - 오분류 데이터 수정
  - 피드백 데이터 수집
  - 재학습 스케줄 관리

API 사용량 관리:
  - Roboflow API 사용량
  - OpenRouter API 사용량
  - 비용 모니터링
  - 사용량 제한 설정
  - 예산 알림 설정

품질 관리:
  - 분석 품질 점수
  - 사용자 피드백 분석
  - 개선 제안 관리
  - A/B 테스트 관리
  - 성능 벤치마크
```

## 4. 권한 및 역할 관리

### 4.1 역할 정의
```yaml
시스템 관리자 (SYSTEM_ADMIN):
  - 모든 시스템 기능 접근
  - 사용자 권한 관리
  - 시스템 설정 변경
  - 감사 로그 접근
  - 데이터베이스 관리

처리 관리자 (PROCESS_MANAGER):
  - 신고서 관리 전체
  - 담당자 업무 배정
  - 처리 현황 모니터링
  - 통계 및 리포트 생성
  - 공지사항 작성

담당 공무원 (OFFICER):
  - 배정된 신고서 처리
  - 상태 변경 (제한적)
  - 댓글 작성
  - 처리 결과 업로드
  - 기본 통계 조회

읽기 전용 (READ_ONLY):
  - 신고서 조회만 가능
  - 통계 대시보드 조회
  - 리포트 다운로드
  - 댓글 읽기
  - 기본 검색
```

### 4.2 권한 매트릭스
```yaml
기능별 접근 권한:
  대시보드 조회: 모든 역할
  신고서 상태 변경: OFFICER 이상
  담당자 배정: PROCESS_MANAGER 이상
  사용자 관리: SYSTEM_ADMIN만
  시스템 설정: SYSTEM_ADMIN만
  AI 관리: PROCESS_MANAGER 이상
  통계 조회: OFFICER 이상
  리포트 생성: PROCESS_MANAGER 이상
```

## 5. 데이터 모델

### 5.1 AdminUser 모델
```dart
@freezed
class AdminUser with _$AdminUser {
  const factory AdminUser({
    required String id,
    required String email,
    required String name,
    required AdminRole role,
    required String department,
    String? profileImageUrl,
    @Default(AdminStatus.active) AdminStatus status,
    @Default(0) int processedReports,
    @Default(0.0) double averageProcessingTime,
    @Default(0.0) double satisfactionScore,
    required DateTime createdAt,
    DateTime? lastLoginAt,
    List<String>? specializations,
  }) = _AdminUser;
}

enum AdminRole {
  systemAdmin,
  processManager,
  officer,
  readOnly,
}

enum AdminStatus {
  active,
  inactive,
  suspended,
}
```

### 5.2 AdminDashboardData 모델
```dart
@freezed
class AdminDashboardData with _$AdminDashboardData {
  const factory AdminDashboardData({
    required int totalReports,
    required int pendingReports,
    required int todayReports,
    required double completionRate,
    required double averageProcessingHours,
    required int urgentReports,
    required List<ChartData> dailyTrend,
    required List<ChartData> categoryDistribution,
    required List<ChartData> statusDistribution,
    required DateTime lastUpdated,
  }) = _AdminDashboardData;
}
```

### 5.3 ReportAssignment 모델
```dart
@freezed
class ReportAssignment with _$ReportAssignment {
  const factory ReportAssignment({
    required String id,
    required String reportId,
    required String adminUserId,
    required DateTime assignedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
    @Default(AssignmentStatus.assigned) AssignmentStatus status,
    AssignmentPriority? priority,
  }) = _ReportAssignment;
}

enum AssignmentStatus {
  assigned,
  started,
  completed,
  reassigned,
}
```

## 6. 상태 관리 구조

### 6.1 AdminState
```dart
@freezed
class AdminState with _$AdminState {
  const factory AdminState({
    AdminUser? currentAdmin,
    AdminDashboardData? dashboardData,
    @Default([]) List<Report> managedReports,
    @Default([]) List<AdminUser> teamMembers,
    @Default(false) bool isLoading,
    String? error,
    Map<String, dynamic>? filters,
  }) = _AdminState;
}
```

### 6.2 AdminNotifier
```dart
class AdminNotifier extends StateNotifier<AdminState> {
  Future<void> loadDashboardData();
  Future<void> assignReport(String reportId, String adminId);
  Future<void> updateReportStatus(String reportId, ReportStatus status);
  Future<void> createAdminUser(AdminUser user);
  Future<void> updateSystemSettings(SystemSettings settings);
  Future<void> generateReport(ReportType type, DateRange range);
}
```

## 7. 워크플로우 관리

### 7.1 신고서 처리 워크플로우
```yaml
접수 단계:
  - 신규 신고 자동 분류
  - 우선순위 자동 설정
  - 담당 부서 배정
  - 초기 검토 완료
  - 처리 시작 알림

처리 단계:
  - 현장 조사 계획
  - 관련 부서 협의
  - 처리 방안 수립
  - 예산 승인 요청
  - 작업 진행 관리

완료 단계:
  - 처리 결과 검증
  - 사진 증빙 첨부
  - 신고자 만족도 조사
  - 완료 보고서 작성
  - 사후 관리 계획
```

### 7.2 에스컬레이션 규칙
```yaml
자동 에스컬레이션:
  - 24시간 미처리 시 1차 알림
  - 72시간 미처리 시 상급자 배정
  - 1주일 미처리 시 부서장 개입
  - 긴급 신고는 1시간 내 처리
  - VIP 신고자는 특별 관리

수동 에스컬레이션:
  - 담당자 요청 시
  - 복잡한 사안 판단 시
  - 부서 간 협의 필요 시
  - 예산 승인 필요 시
  - 법적 검토 필요 시
```

## 8. 통계 및 리포팅

### 8.1 KPI 대시보드
```yaml
핵심 지표:
  - 신고 처리율 (목표: 95%)
  - 평균 처리 시간 (목표: 3일)
  - 사용자 만족도 (목표: 4.5/5)
  - 재신고율 (목표: 5% 이하)
  - 시스템 가용성 (목표: 99.9%)

부서별 성과:
  - 처리량 비교
  - 품질 점수 비교
  - 효율성 지표
  - 개선 제안 사항
  - 우수 사례 공유

트렌드 분석:
  - 월별 신고량 변화
  - 계절별 패턴 분석
  - 특정 이벤트 영향 분석
  - 정책 효과 측정
  - 예측 모델링
```

### 8.2 자동 리포트 생성
```yaml
일간 리포트:
  - 당일 접수/처리 현황
  - 긴급 사안 요약
  - 처리 지연 건수
  - 시스템 상태 점검
  - 다음날 업무 계획

주간 리포트:
  - 주간 성과 요약
  - 부서별 실적 비교
  - 문제점 및 개선사항
  - 사용자 피드백 요약
  - 시스템 사용 통계

월간 리포트:
  - 월간 종합 분석
  - KPI 달성도 평가
  - 트렌드 분석 결과
  - 정책 제안 사항
  - 예산 집행 현황
```

## 9. 모바일 최적화

### 9.1 반응형 디자인
```yaml
레이아웃 적응:
  - 태블릿 가로 모드 최적화
  - 폰 세로 모드 대응
  - 멀티 윈도우 지원
  - 폴더블 디바이스 대응
  - 다양한 화면 비율 지원

터치 최적화:
  - 관리자용 큰 터치 영역
  - 제스처 기반 빠른 액션
  - 드래그 앤 드롭 지원
  - 멀티 터치 확대/축소
  - 스와이프 네비게이션

성능 최적화:
  - 지연 로딩 적용
  - 이미지 최적화
  - 데이터 페이징
  - 캐싱 전략
  - 배터리 절약 모드
```

### 9.2 오프라인 기능
```yaml
오프라인 대응:
  - 필수 데이터 로컬 저장
  - 읽기 전용 모드 지원
  - 변경사항 임시 저장
  - 온라인 복구 시 동기화
  - 충돌 해결 메커니즘

로컬 저장:
  - 최근 신고서 캐싱
  - 담당자 정보 저장
  - 설정 정보 저장
  - 임시 작업 저장
  - 오프라인 리포트 생성
```

## 10. 보안 및 감사

### 10.1 접근 제어
```yaml
인증 강화:
  - 2단계 인증 필수
  - 관리자용 강화된 비밀번호
  - 세션 관리 강화
  - IP 기반 접근 제한
  - 정기적 권한 검토

데이터 보호:
  - 민감 정보 암호화
  - 데이터 마스킹
  - 접근 로그 기록
  - 데이터 백업 보안
  - 외부 유출 방지
```

### 10.2 감사 로그
```yaml
로그 기록 항목:
  - 로그인/로그아웃 이력
  - 신고서 상태 변경 이력
  - 권한 변경 이력
  - 설정 변경 이력
  - 데이터 접근 이력

로그 관리:
  - 실시간 로그 모니터링
  - 이상 패턴 감지
  - 로그 보관 정책
  - 로그 무결성 검증
  - 정기적 로그 분석
```

## 11. 성능 및 확장성

### 11.1 성능 최적화
```yaml
데이터 처리:
  - 대용량 데이터 페이징
  - 인덱스 최적화
  - 쿼리 성능 튜닝
  - 캐시 전략 적용
  - 비동기 처리 활용

UI 성능:
  - 가상 스크롤링
  - 지연 렌더링
  - 메모리 관리
  - 애니메이션 최적화
  - 이미지 압축
```

### 11.2 확장성 고려
```yaml
아키텍처:
  - 마이크로서비스 준비
  - API 버전 관리
  - 수평 확장 지원
  - 로드 밸런싱
  - 장애 복구 메커니즘

데이터베이스:
  - 샤딩 전략
  - 읽기 복제본 활용
  - 데이터 파티셔닝
  - 아카이빙 정책
  - 백업 및 복구
```

## 12. 테스트 전략

### 12.1 기능 테스트
- 권한 기반 접근 제어 테스트
- 신고서 처리 워크플로우 테스트
- 통계 및 리포트 생성 테스트
- 사용자 관리 기능 테스트

### 12.2 보안 테스트
- 권한 우회 시도 테스트
- SQL 인젝션 방지 테스트
- XSS 공격 방지 테스트
- 세션 하이재킹 방지 테스트

### 12.3 성능 테스트
- 대용량 데이터 처리 테스트
- 동시 사용자 부하 테스트
- 메모리 사용량 테스트
- 응답 시간 측정

## 13. 구현 일정

### 주차별 계획
```yaml
1-2주차:
  - 기본 인증 및 권한 시스템
  - 관리자 대시보드 기본 UI
  - 신고서 목록 조회 기능
  - 기본 상태 변경 기능

3-4주차:
  - 담당자 관리 시스템
  - 업무 배정 기능
  - 기본 통계 화면
  - 권한 관리 시스템

5-6주차:
  - 고급 통계 및 분석
  - 리포트 생성 시스템
  - AI 관리 기능
  - 시스템 설정 관리

7-8주차:
  - 워크플로우 관리
  - 모바일 최적화
  - 보안 강화
  - 성능 최적화

9-10주차:
  - 테스트 및 버그 수정
  - 문서화 완성
  - 사용자 교육 자료
  - 배포 준비
```

**총 구현 기간**: 10주  
**개발자 소요**: 2명 (백엔드 + 프론트엔드)  
**우선순위**: High (시스템 운영의 핵심)