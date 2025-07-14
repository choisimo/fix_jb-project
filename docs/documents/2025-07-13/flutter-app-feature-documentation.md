# 전라북도 신고 플랫폼 - Flutter 앱 기능 문서

## 📱 앱 개요
전라북도 신고 플랫폼 모바일 앱은 시민들이 지역 문제를 쉽게 신고하고 추적할 수 있는 Flutter 기반 애플리케이션입니다. AI 기반 이미지 분석과 실시간 알림 기능을 제공합니다.

---

## 🔐 인증 기능 (Authentication Features)

### 1. 로그인 화면 (Login Screen)
**파일 위치**: `lib/features/auth/presentation/screens/login_screen.dart`

**주요 기능**:
- 이메일/비밀번호 로그인
- 소셜 로그인 (Google, Apple, Naver, Kakao)
- 자동 로그인 옵션
- 비밀번호 찾기 연결

**사용자 경험**:
- 직관적인 폼 디자인
- 실시간 입력 검증
- 로딩 상태 표시
- 에러 메시지 표시

### 2. 회원가입 화면 (Signup Screen)
**파일 위치**: `lib/features/auth/presentation/screens/signup_screen.dart`

**주요 기능**:
- 이메일, 비밀번호, 이름, 휴대폰 번호 입력
- 실시간 유효성 검사
- 이용약관 및 개인정보처리방침 동의
- SMS/이메일 인증 연결

**입력 검증**:
- 이메일 형식 검증
- 비밀번호 강도 검사 (8자리 이상, 특수문자 포함)
- 휴대폰 번호 형식 검증
- 실시간 중복 확인

### 3. 인증 화면 (Verification Screen)
**파일 위치**: `lib/features/auth/presentation/screens/verification_screen.dart`

**주요 기능**:
- SMS/이메일 인증번호 발송
- 6자리 인증번호 입력
- 5분 타이머 표시
- 인증번호 재발송 기능

**사용자 경험**:
- 자동 인증번호 입력 (6자리 완성 시 자동 인증)
- 남은 시간 실시간 표시
- 인증 실패 시 도움말 제공
- 스팸함 확인 안내

### 4. 비밀번호 찾기 화면 (Forgot Password Screen)
**파일 위치**: `lib/features/auth/presentation/screens/forgot_password_screen.dart`

**주요 기능**:
- 이메일 또는 휴대폰 번호로 비밀번호 재설정
- 인증 후 새 비밀번호 설정
- 보안 질문 확인 (옵션)

---

## 🏠 홈 기능 (Home Features)

### 메인 화면 (Home Screen)
**파일 위치**: `lib/features/home/presentation/home_screen.dart`

**주요 기능**:
- 최근 신고 목록 표시
- 신고 상태별 필터링
- 새 신고 작성 버튼
- 긴급 신고 바로가기

**표시 정보**:
- 신고 제목 및 카테고리
- 신고 일시 및 상태
- 신고 위치 (지역명)
- 처리 진행률 표시

**사용자 경험**:
- 풀 리프레시로 새로고침
- 무한 스크롤 지원
- 상태별 색상 구분
- 스와이프 액션 (삭제, 수정)

---

## 📝 신고 기능 (Report Features)

### 1. 신고 작성 화면 (Create Report Screen)
**파일 위치**: `lib/features/report/presentation/create_report_screen.dart`

**주요 기능**:
- 카테고리 선택 (도로, 환경, 안전, 시설 등)
- 사진/동영상 첨부 (최대 5개)
- GPS 위치 자동 감지
- 상세 설명 입력
- AI 분석 결과 표시

**AI 분석 기능**:
- 업로드된 이미지 자동 분석
- 문제 유형 자동 분류
- 심각도 자동 평가
- 예상 처리 시간 안내

**위치 기능**:
- 현재 위치 자동 감지
- 지도에서 위치 수동 선택
- 주소 검색 기능
- 랜드마크 기반 위치 설명

### 2. 신고 상세 화면 (Report Detail Screen)
**파일 위치**: `lib/features/report/presentation/controllers/report_detail_controller.dart`

**주요 기능**:
- 신고 상세 정보 표시
- 처리 진행 상황 추적
- 담당자 댓글 확인
- 추가 정보 제출

**진행 상황 추적**:
- 접수 → 검토 → 처리중 → 완료 단계
- 각 단계별 예상 시간
- 담당 부서 정보
- 처리 완료 사진

### 3. 신고 목록 화면 (Report List Screen)
**파일 위치**: `lib/features/report/presentation/controllers/report_list_controller.dart`

**주요 기능**:
- 내 신고 목록 표시
- 상태별 필터링
- 검색 기능
- 정렬 옵션

**필터 및 정렬**:
- 상태별: 전체, 접수, 처리중, 완료
- 카테고리별 필터링
- 날짜순, 상태순 정렬
- 키워드 검색

---

## 🔔 알림 기능 (Notification Features)

### 알림 시스템
**파일 위치**: `lib/features/notification/`

**주요 기능**:
- 실시간 푸시 알림
- 앱 내 알림 센터
- 알림 설정 관리
- 알림 히스토리

**알림 유형**:
- 신고 접수 확인
- 처리 상태 업데이트
- 담당자 댓글 알림
- 처리 완료 알림
- 시스템 공지사항

**알림 설정**:
- 푸시 알림 on/off
- 알림 유형별 설정
- 알림 시간 설정
- 소리 및 진동 설정

### 알림 모델
**파일 위치**: `lib/features/notification/domain/models/app_notification.dart`

**데이터 구조**:
- 알림 ID, 제목, 내용
- 알림 유형 및 우선순위
- 생성/읽음/만료 시간
- 관련 리소스 ID
- 발신자 정보

---

## 🔒 보안 기능 (Security Features)

### 보안 시스템
**파일 위치**: `lib/features/security/`

**주요 기능**:
- 생체 인증 (지문, 얼굴 인식)
- 앱 잠금 기능
- 데이터 암호화
- 무결성 검증
- 루팅/탈옥 탐지

**보안 모니터링**:
- 로그인 실패 추적
- 의심스러운 활동 감지
- 디바이스 보안 상태 확인
- 앱 변조 탐지

**개인정보 보호**:
- 데이터 최소 수집
- 암호화 저장
- 자동 로그아웃
- 개인정보 삭제 기능

### 보안 상태 모델
**파일 위치**: `lib/features/security/domain/models/security_state.dart`

**모니터링 항목**:
- 생체 인증 활성화 상태
- 현재 보안 레벨
- 최근 보안 이벤트
- 디바이스 보안 상태
- 루팅/디버그 모드 탐지

---

## 👑 관리자 기능 (Admin Features)

### 관리자 대시보드
**파일 위치**: `lib/features/admin/domain/models/admin_dashboard_data.dart`

**주요 기능**:
- 신고 현황 대시보드
- 처리 성과 분석
- 팀 성과 관리
- 시스템 상태 모니터링

**대시보드 지표**:
- 총 신고 수, 대기중, 오늘/이번주/이번달 신고
- 처리 완료율, 평균 처리 시간
- 긴급 신고 수, 활성 관리자 수
- 일일 트렌드, 카테고리/상태/지역별 분포

**성과 분석**:
- 처리 시간 분석
- 팀 성과 데이터
- 시스템 상태 모니터링
- 최근 활동 로그

### 관리자 권한
- 신고 할당 및 재할당
- 처리 상태 업데이트
- 댓글 및 피드백 작성
- 통계 및 리포트 조회
- 사용자 관리 (제한적)

---

## 🛠 기술적 구현 사항

### 아키텍처 패턴
- **Clean Architecture**: 레이어 분리 (Presentation, Domain, Data)
- **State Management**: Riverpod 사용
- **Dependency Injection**: Provider 패턴
- **Code Generation**: Freezed, JsonAnnotation 활용

### 주요 의존성
- **UI**: Material Design 3
- **상태 관리**: flutter_riverpod
- **네트워크**: dio, retrofit
- **데이터 모델**: freezed, json_annotation
- **로컬 저장소**: shared_preferences, secure_storage
- **위치 서비스**: geolocator, geocoding
- **카메라**: image_picker, camera
- **알림**: firebase_messaging, flutter_local_notifications
- **생체 인증**: local_auth

### 보안 구현
- **HTTPS 통신**: Certificate Pinning
- **데이터 암호화**: AES-256 암호화
- **토큰 관리**: JWT 토큰, Refresh Token
- **생체 인증**: TouchID, FaceID, Fingerprint
- **앱 보안**: 루팅/탈옥 탐지, 스크린샷 방지

---

## 📊 성능 최적화

### 이미지 최적화
- 자동 리사이징 및 압축
- Progressive JPEG 지원
- 캐싱 전략 구현
- 레이지 로딩

### 메모리 관리
- 이미지 메모리 캐시 제한
- 위젯 생명주기 관리
- 리스너 자동 해제
- 메모리 누수 방지

### 네트워크 최적화
- 요청 중복 제거
- 오프라인 지원
- 백그라운드 동기화
- 재시도 로직

---

## 🌐 다국어 지원

### 지원 언어
- 한국어 (기본)
- 영어
- 중국어 (간체)
- 일본어

### 현지화 요소
- UI 텍스트
- 에러 메시지
- 알림 메시지
- 날짜/시간 형식
- 숫자 형식

---

## 🧪 테스트 및 품질 보증

### 테스트 구조
**파일 위치**: `test/widget_test.dart`

- **Unit Tests**: 비즈니스 로직 테스트
- **Widget Tests**: UI 컴포넌트 테스트
- **Integration Tests**: 전체 플로우 테스트
- **Golden Tests**: UI 스크린샷 테스트

### 코드 품질
- **Linting**: analysis_options.yaml
- **코드 포맷팅**: dart format
- **정적 분석**: dart analyze
- **커버리지**: 90% 이상 목표

---

## 🚀 배포 및 업데이트

### 앱 스토어 배포
- **Android**: Google Play Store
- **iOS**: Apple App Store
- **자동 배포**: GitHub Actions CI/CD

### 업데이트 전략
- **강제 업데이트**: 보안 패치
- **선택적 업데이트**: 기능 개선
- **점진적 배포**: A/B 테스트
- **롤백 지원**: 문제 발생 시

---

## 📈 분석 및 모니터링

### 사용자 분석
- **Firebase Analytics**: 사용자 행동 분석
- **Crashlytics**: 크래시 리포트
- **Performance**: 성능 모니터링
- **Custom Events**: 비즈니스 지표 추적

### 주요 지표
- 일일/월간 활성 사용자 (DAU/MAU)
- 신고 완료율
- 앱 사용 시간
- 기능별 사용률
- 크래시율 및 성능 지표

---

## 🎯 향후 개선 계획

### 단기 계획 (3개월)
- 오프라인 모드 구현
- 다크 테마 지원
- 접근성 개선
- 성능 최적화

### 중기 계획 (6개월)
- AI 추천 시스템
- 소셜 기능 추가
- 실시간 채팅
- 고급 분석 기능

### 장기 계획 (1년)
- AR 기반 신고
- IoT 연동
- 블록체인 무결성
- 다지역 확장

---

## 📞 지원 및 문의

### 기술 지원
- **이메일**: tech-support@jeonbuk-report.kr
- **전화**: 063-123-4567
- **운영시간**: 평일 09:00-18:00

### 사용자 가이드
- **앱 내 도움말**: 설정 > 도움말
- **FAQ**: 웹사이트 FAQ 섹션
- **비디오 가이드**: YouTube 채널
- **사용자 매뉴얼**: PDF 다운로드

이 문서는 전라북도 신고 플랫폼 Flutter 앱의 모든 기능을 포괄적으로 설명합니다. 각 기능은 사용자 친화적이고 직관적인 경험을 제공하도록 설계되었습니다.