# JB Report Platform 관리자 UI 개발 PRD

## 📋 문서 정보
- **작성일:** 2025년 7월 13일
- **작성자:** OpenCode AI Assistant
- **프로젝트:** JB Report Platform (전북 시민 신고 시스템)
- **문서 유형:** Product Requirements Document (PRD)
- **버전:** 1.0

---

## 🎯 프로젝트 개요

### 목적
JB Report Platform의 관리자가 시스템을 효율적으로 관리할 수 있는 완전한 UI 인터페이스를 개발합니다. 현재 백엔드 API와 데이터 모델은 완성되어 있으나, 관리자용 사용자 인터페이스가 전혀 구현되어 있지 않은 상태입니다.

### 현재 상황
- ✅ **백엔드 API**: 70% 완성 (관리자 권한 시스템, 통계 API, 사용자 관리 API)
- ✅ **데이터 모델**: 95% 완성 (AdminUser, AdminDashboardData, 권한 시스템)
- ✅ **권한 시스템**: 90% 완성 (4개 역할, 18개 세분화된 권한)
- ❌ **Flutter 관리자 UI**: 0% 구현 (모델만 존재, 화면/컨트롤러/위젯 없음)
- ❌ **웹 관리자 대시보드**: 0% 구현 (별도 웹 관리자 대시보드 없음)

---

## 🎯 비즈니스 목표

### 주요 목표
1. **관리 효율성 향상**: 시스템 관리 작업을 50% 단축
2. **실시간 모니터링**: 플랫폼 상태를 실시간으로 모니터링
3. **데이터 기반 의사결정**: 통계 및 분석 데이터 제공
4. **보안 강화**: 관리자 권한 기반 접근 제어

### 성공 지표
- 관리자 작업 효율성 50% 향상
- 시스템 다운타임 30% 감소
- 신고 처리 시간 40% 단축
- 관리자 만족도 90% 이상

---

## 👥 타겟 사용자

### 주요 관리자 역할
1. **SUPER_ADMIN**: 최고 관리자 (시스템 전체 관리)
2. **ADMIN**: 일반 관리자 (일상적인 관리 업무)
3. **MODERATOR**: 중재자 (신고 검토 및 처리)
4. **VIEWER**: 조회자 (통계 및 데이터 조회만)

### 사용자 시나리오
- **일일 관리**: 신고 현황 확인, 사용자 문의 처리
- **주간 분석**: 통계 리포트 생성, 성과 분석
- **시스템 관리**: API 키 설정, 사용자 권한 관리
- **긴급 대응**: 시스템 장애 대응, 부적절한 신고 처리

---

## 🔧 기술 요구사항

### 개발 플랫폼
1. **Flutter 모바일 관리자 앱**: iOS/Android 크로스 플랫폼
2. **React 웹 관리자 대시보드**: 데스크톱 브라우저 최적화

### 기존 시스템 통합
- **Main API Server** (포트 8080): 사용자 관리, 신고 관리 API
- **AI Analysis Server** (포트 8081): AI 분석 결과 관리 API
- **PostgreSQL 데이터베이스**: 모든 관리 데이터 저장
- **Redis**: 세션 관리 및 캐싱
- **Kafka**: 실시간 이벤트 스트리밍

---

## 📱 Flutter 모바일 관리자 앱 기능

### 1. 인증 및 권한 관리
```dart
// 기존 모델 활용
AdminUser adminUser;
List<Permission> permissions;
```

**기능:**
- 관리자 로그인 (OAuth2 + JWT)
- 역할 기반 메뉴 표시
- 생체 인식 로그인 (지문/Face ID)

### 2. 실시간 대시보드
```dart
// 기존 모델 활용
AdminDashboardData dashboardData;
```

**주요 지표:**
- 실시간 신고 수 (오늘/이번 주/이번 달)
- 처리 대기 중인 신고 수
- AI 분석 진행률
- 시스템 상태 (서버, DB, AI 서비스)

### 3. 신고 관리
**기능:**
- 신고 목록 조회 (필터링/정렬)
- 신고 상세 정보 조회
- 신고 상태 변경 (승인/거부/검토중)
- 신고자에게 푸시 알림 발송
- 신고 이미지 확대/AI 분석 결과 확인

### 4. 사용자 관리
**기능:**
- 사용자 목록 조회
- 사용자 상세 정보 조회
- 사용자 계정 비활성화/활성화
- 관리자 계정 생성
- 역할 및 권한 할당

### 5. 통계 및 분석
**기능:**
- 신고 통계 (지역별/카테고리별/시간별)
- 사용자 활동 통계
- AI 분석 정확도 통계
- 처리 성과 분석

### 6. 시스템 설정
**기능:**
- API 키 관리 (Roboflow, OpenRouter)
- 알림 설정
- 앱 설정 관리

---

## 🌐 React 웹 관리자 대시보드 기능

### 1. 종합 대시보드
**레이아웃:**
```
┌─────────────────┬─────────────────┐
│ 실시간 지표      │ 처리 현황        │
├─────────────────┼─────────────────┤
│ 지역별 신고 맵   │ 최근 활동        │
├─────────────────┴─────────────────┤
│ 신고 트렌드 차트                   │
└───────────────────────────────────┘
```

### 2. 고급 신고 관리
**기능:**
- 대량 신고 처리 (배치 작업)
- 신고 검색 및 고급 필터링
- 신고 내보내기 (Excel/CSV)
- 신고 통계 리포트 생성

### 3. 고급 사용자 관리
**기능:**
- 사용자 대량 가져오기/내보내기
- 사용자 활동 로그 조회
- 권한 매트릭스 관리
- 관리자 활동 감사 로그

### 4. 시스템 모니터링
**기능:**
- 실시간 서버 상태 모니터링
- API 응답 시간 모니터링
- 데이터베이스 성능 모니터링
- 에러 로그 조회 및 분석

### 5. 고급 설정
**기능:**
- 시스템 전체 설정 관리
- 백업 및 복원 관리
- 로그 레벨 설정
- 알림 규칙 설정

---

## 🎨 UI/UX 설계 방향

### Flutter 앱 디자인
- **Material 3 Design** 적용
- **다크/라이트 테마** 지원
- **반응형 레이아웃** (태블릿 지원)
- **직관적인 네비게이션** (Bottom Navigation + Drawer)

### React 웹 디자인
- **Ant Design** 또는 **Material-UI** 컴포넌트 라이브러리
- **반응형 대시보드** 레이아웃
- **데이터 시각화** (Chart.js/Recharts)
- **테이블 기반 데이터 표시** (정렬/필터링/페이징)

---

## 🔒 보안 요구사항

### 1. 인증 및 권한
- **JWT 토큰** 기반 인증
- **역할 기반 접근 제어** (RBAC)
- **세션 타임아웃** 관리
- **2단계 인증** (선택사항)

### 2. 데이터 보안
- **HTTPS** 필수
- **API 키 암호화** 저장
- **민감 정보 마스킹**
- **감사 로그** 기록

### 3. 네트워크 보안
- **CORS** 설정
- **Rate Limiting**
- **IP 화이트리스트** (선택사항)

---

## 📊 데이터 모델 및 API

### 기존 데이터 모델 활용
```dart
// flutter-app/lib/features/admin/domain/models/
class AdminUser {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final List<Permission> permissions;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;
}

class AdminDashboardData {
  final int totalReports;
  final int pendingReports;
  final int activeUsers;
  final double aiAnalysisAccuracy;
  final List<ReportStatistics> reportStats;
  final SystemHealthData systemHealth;
}
```

### 필요한 추가 API
```java
// 추가 구현 필요한 API들
@RestController
@RequestMapping("/api/admin")
public class AdminDashboardController {
    // 실시간 대시보드 데이터
    @GetMapping("/dashboard/realtime")
    
    // 시스템 상태 조회
    @GetMapping("/system/health")
    
    // API 키 관리
    @PostMapping("/settings/api-keys")
    
    // 대량 신고 처리
    @PostMapping("/reports/batch-update")
}
```

---

## 🚀 개발 계획

### Phase 1: 기반 구조 (2주)
1. **Flutter 프로젝트 설정**
   - 관리자 앱 라우팅 구조
   - 인증 시스템 구현
   - 기본 네비게이션 설정

2. **React 프로젝트 설정**
   - Create React App 또는 Next.js 설정
   - 라우팅 및 레이아웃 구성
   - 인증 시스템 구현

### Phase 2: 핵심 기능 (3주)
1. **실시간 대시보드**
   - Flutter: 홈 화면 및 기본 지표
   - React: 종합 대시보드 및 차트

2. **신고 관리 시스템**
   - Flutter: 신고 목록 및 상세 화면
   - React: 고급 신고 관리 인터페이스

### Phase 3: 고급 기능 (3주)
1. **사용자 관리**
   - Flutter: 기본 사용자 관리
   - React: 고급 사용자 관리 및 권한 설정

2. **통계 및 분석**
   - Flutter: 모바일 최적화된 통계 화면
   - React: 고급 분석 및 리포트 기능

### Phase 4: 시스템 관리 (2주)
1. **설정 관리**
   - API 키 관리 인터페이스
   - 시스템 설정 관리

2. **모니터링 및 로깅**
   - 실시간 시스템 모니터링
   - 로그 조회 및 분석

### Phase 5: 테스트 및 배포 (2주)
1. **통합 테스트**
2. **성능 최적화**
3. **배포 및 문서화**

---

## 📋 상세 작업 목록

### Flutter 관리자 앱 개발
1. **프로젝트 구조 설정**
   ```
   lib/
   ├── features/
   │   └── admin/
   │       ├── presentation/
   │       │   ├── pages/
   │       │   ├── widgets/
   │       │   └── controllers/
   │       ├── domain/
   │       │   ├── models/ (기존 활용)
   │       │   └── repositories/
   │       └── data/
   │           ├── datasources/
   │           └── repositories/
   ```

2. **화면 구현**
   - 로그인 화면 (`admin_login_page.dart`)
   - 홈/대시보드 화면 (`admin_dashboard_page.dart`)
   - 신고 관리 화면 (`admin_reports_page.dart`)
   - 사용자 관리 화면 (`admin_users_page.dart`)
   - 통계 화면 (`admin_statistics_page.dart`)
   - 설정 화면 (`admin_settings_page.dart`)

3. **컨트롤러 구현**
   - `AdminAuthController`
   - `AdminDashboardController`
   - `AdminReportsController`
   - `AdminUsersController`
   - `AdminSettingsController`

### React 웹 대시보드 개발
1. **프로젝트 설정**
   ```
   src/
   ├── components/
   │   ├── admin/
   │   ├── charts/
   │   └── common/
   ├── pages/
   │   └── admin/
   ├── services/
   ├── hooks/
   └── utils/
   ```

2. **컴포넌트 구현**
   - 대시보드 레이아웃
   - 신고 관리 테이블
   - 사용자 관리 인터페이스
   - 통계 차트 컴포넌트
   - 시스템 모니터링 컴포넌트

### 백엔드 API 확장
1. **추가 엔드포인트 구현**
   - 실시간 대시보드 데이터 API
   - 시스템 상태 조회 API
   - API 키 관리 API
   - 대량 처리 API

2. **WebSocket 구현**
   - 실시간 신고 알림
   - 시스템 상태 업데이트

---

## 🧪 테스트 전략

### 단위 테스트
- Flutter: Widget 테스트, Controller 테스트
- React: Component 테스트, Hook 테스트
- 백엔드: Service 및 Controller 테스트

### 통합 테스트
- API 연동 테스트
- 권한 시스템 테스트
- 실시간 기능 테스트

### E2E 테스트
- 관리자 워크플로우 테스트
- 크로스 플랫폼 테스트

---

## 📈 성능 요구사항

### 응답 시간
- 대시보드 로딩: 2초 이내
- 신고 목록 조회: 1초 이내
- 실시간 업데이트: 실시간

### 동시 사용자
- 최대 50명의 동시 관리자 지원
- 실시간 데이터 동기화

---

## 🚀 배포 계획

### Flutter 앱 배포
- **Android**: Google Play Store (내부 테스트 → 베타 → 출시)
- **iOS**: App Store (TestFlight → 출시)

### React 웹 배포
- **웹 서버**: Nginx를 통한 정적 파일 서빙
- **도메인**: admin.jbreport.com (예시)
- **SSL**: Let's Encrypt 인증서

---

## 📚 문서화 계획

### 개발 문서
- API 문서 업데이트
- 컴포넌트 문서
- 설정 가이드

### 사용자 문서
- 관리자 사용 가이드
- 권한 설정 가이드
- 트러블슈팅 가이드

---

## 🔄 유지보수 계획

### 정기 업데이트
- 보안 패치 적용
- 기능 개선
- 성능 최적화

### 모니터링
- 사용자 피드백 수집
- 성능 지표 모니터링
- 오류 추적 및 분석

---

## 📞 연락처 및 승인

**프로젝트 매니저:** [프로젝트 매니저 이름]  
**기술 리드:** [기술 리드 이름]  
**승인자:** [승인자 이름]

**승인 일자:** _______________  
**서명:** _______________

---

*이 문서는 JB Report Platform 관리자 UI 개발의 전체적인 방향성과 요구사항을 정의합니다. 개발 진행 중 요구사항 변경이 필요한 경우, 관련 이해관계자와 협의 후 문서를 업데이트합니다.*