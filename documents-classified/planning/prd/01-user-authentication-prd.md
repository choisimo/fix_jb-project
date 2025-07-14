# Flutter 사용자 인증 시스템 PRD

## 1. 개요
**목적**: 안전하고 사용자 친화적인 인증 시스템 구현  
**대상**: 전북 신고 플랫폼 모바일 앱 사용자  
**우선순위**: 최고 (Critical)

## 2. 현재 상태
- **기존 구현**: `AuthRepository` 기본 구조만 존재
- **구현률**: 5% (스켈레톤 코드만)
- **누락 기능**: 로그인/회원가입 UI, JWT 처리, 소셜 로그인, 생체 인증

## 3. 상세 요구사항

### 3.1 로그인 화면 (`LoginScreen`)
```yaml
기능 요구사항:
  - 이메일/비밀번호 로그인
  - 입력 검증 (이메일 형식, 비밀번호 최소 길이)
  - 로그인 상태 유지 옵션
  - 자동 로그인 기능
  - 비밀번호 찾기 링크

UI/UX 요구사항:
  - Material 3 디자인
  - 로딩 상태 표시
  - 에러 메시지 표시
  - 키보드 대응 레이아웃
  - 브랜드 로고 표시

기술 구현:
  - reactive_forms 활용
  - Riverpod 상태 관리
  - JWT 토큰 처리
  - Secure Storage 연동
```

### 3.2 회원가입 화면 (`SignUpScreen`)
```yaml
기능 요구사항:
  - 필수 정보: 이메일, 비밀번호, 닉네임, 전화번호
  - 선택 정보: 프로필 이미지, 주소
  - 이메일 중복 확인
  - 비밀번호 강도 체크
  - 이용약관 동의

검증 규칙:
  - 이메일: RFC 5322 표준
  - 비밀번호: 8자 이상, 영문+숫자+특수문자
  - 닉네임: 2-20자, 한글/영문/숫자
  - 전화번호: 한국 휴대폰 번호 형식

기술 구현:
  - 단계별 회원가입 (3단계)
  - 실시간 입력 검증
  - 프로필 이미지 업로드
  - SMS 인증 연동
```

### 3.3 소셜 로그인 (`SocialAuthService`)
```yaml
지원 플랫폼:
  - Google 로그인
  - Kakao 로그인
  - Apple 로그인 (iOS)

기능 구현:
  - 원클릭 로그인
  - 계정 연동/해제
  - 프로필 정보 동기화
  - 소셜 계정 관리

기술 스택:
  - google_sign_in: ^6.1.6
  - kakao_flutter_sdk_user: ^1.7.0
  - sign_in_with_apple: ^5.0.0
```

### 3.4 생체 인증 (`BiometricAuthService`)
```yaml
지원 기능:
  - 지문 인증
  - 얼굴 인식 (Face ID)
  - PIN 번호 설정
  - 패턴 잠금

구현 요구사항:
  - 기기 지원 여부 확인
  - 생체 정보 등록 가이드
  - 대체 인증 수단 제공
  - 보안 설정 관리

패키지: local_auth: ^2.1.6
```

### 3.5 토큰 관리 (`TokenManager`)
```yaml
기능 요구사항:
  - JWT Access Token 관리
  - Refresh Token 자동 갱신
  - 토큰 만료 감지
  - 자동 로그아웃

보안 요구사항:
  - Secure Storage 암호화 저장
  - 토큰 탈취 방지
  - 앱 백그라운드 시 데이터 보호
  - 디바이스 잠금 연동

기술 구현:
  - flutter_secure_storage: ^9.0.0
  - dio_token_manager 커스텀 구현
  - 자동 재시도 로직
```

## 4. API 연동 명세

### 4.1 인증 API 엔드포인트
```yaml
로그인:
  - POST /api/auth/login
  - Body: { email, password, rememberMe }
  - Response: { accessToken, refreshToken, user }

소셜 로그인:
  - POST /api/auth/social/{provider}
  - Body: { socialToken, provider }
  - Response: { accessToken, refreshToken, user }

토큰 갱신:
  - POST /api/auth/refresh
  - Header: Authorization: Bearer {refreshToken}
  - Response: { accessToken, refreshToken }

로그아웃:
  - POST /api/auth/logout
  - Header: Authorization: Bearer {accessToken}
  - Response: { success: true }
```

### 4.2 사용자 정보 API
```yaml
프로필 조회:
  - GET /api/users/me
  - Response: { id, email, nickname, profileImage, ... }

프로필 수정:
  - PUT /api/users/me
  - Body: { nickname, profileImage, phone, address }
  - Response: { success: true, user }

비밀번호 변경:
  - PUT /api/users/password
  - Body: { currentPassword, newPassword }
  - Response: { success: true }
```

## 5. 화면 플로우

### 5.1 로그인 플로우
```
앱 시작 → 토큰 확인 → 유효 시 홈 화면
                   → 무효 시 로그인 화면
         ↓
로그인 화면 → 로그인 성공 → 홈 화면
           → 로그인 실패 → 에러 표시
           → 회원가입 → 회원가입 화면
```

### 5.2 회원가입 플로우
```
회원가입 화면 → 1단계: 기본 정보 입력
              → 2단계: 추가 정보 입력 (선택)
              → 3단계: 이용약관 동의
              → 가입 완료 → 로그인 화면
```

## 6. 상태 관리 구조

### 6.1 AuthState
```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    User? user,
    String? accessToken,
    String? refreshToken,
    @Default(false) bool isLoading,
    @Default(false) bool isLoggedIn,
    String? error,
  }) = _AuthState;
}
```

### 6.2 AuthNotifier
```dart
class AuthNotifier extends StateNotifier<AuthState> {
  Future<void> login(String email, String password);
  Future<void> socialLogin(SocialProvider provider);
  Future<void> logout();
  Future<void> refreshToken();
  Future<void> updateProfile(UserUpdateRequest request);
}
```

## 7. 보안 요구사항

### 7.1 데이터 보호
- 모든 민감 정보 암호화 저장
- 앱 스크린샷 방지 (로그인 화면)
- 루팅/탈옥 탐지
- SSL Pinning 적용

### 7.2 세션 관리
- 토큰 자동 만료 처리
- 동시 로그인 제한
- 비정상 접근 탐지
- 앱 백그라운드 시 자동 잠금

## 8. 에러 처리

### 8.1 네트워크 에러
```yaml
연결 실패: "인터넷 연결을 확인해주세요"
타임아웃: "서버 응답이 지연되고 있습니다"
서버 오류: "잠시 후 다시 시도해주세요"
```

### 8.2 인증 에러
```yaml
로그인 실패: "이메일 또는 비밀번호가 올바르지 않습니다"
계정 잠김: "계정이 잠겨있습니다. 관리자에게 문의하세요"
토큰 만료: "세션이 만료되었습니다. 다시 로그인해주세요"
```

## 9. 성능 요구사항

### 9.1 응답 시간
- 로그인 처리: 2초 이내
- 토큰 갱신: 1초 이내
- 프로필 로딩: 1초 이내
- 생체 인증: 3초 이내

### 9.2 메모리 사용
- 인증 관련 메모리: 10MB 이하
- 이미지 캐시: 50MB 이하
- 토큰 저장소: 1MB 이하

## 10. 테스트 시나리오

### 10.1 단위 테스트
- AuthRepository 메서드 테스트
- TokenManager 기능 테스트
- 입력 검증 로직 테스트

### 10.2 통합 테스트
- 로그인 플로우 테스트
- 토큰 갱신 플로우 테스트
- 소셜 로그인 테스트

### 10.3 E2E 테스트
- 전체 인증 시나리오
- 에러 상황 처리
- 네트워크 환경 변화 대응

## 11. 구현 일정

### 주차별 계획
```yaml
1주차:
  - AuthState, AuthNotifier 구현
  - TokenManager 구현
  - 기본 로그인 화면

2주차:
  - 회원가입 화면 완성
  - 입력 검증 로직
  - 에러 처리 구현

3주차:
  - 소셜 로그인 연동
  - 생체 인증 구현
  - 보안 강화

4주차:
  - 테스트 작성
  - 성능 최적화
  - 문서화 완성
```

**총 구현 기간**: 4주  
**개발자 소요**: 1명 풀타임  
**우선순위**: Critical (다른 모든 기능의 전제조건)