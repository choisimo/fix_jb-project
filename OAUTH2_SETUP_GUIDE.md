# OAuth2 설정 가이드 (Google & Kakao)

이 가이드는 Google과 Kakao OAuth2 소셜 로그인을 설정하는 방법을 단계별로 설명합니다.

## 📋 목차
1. [Google OAuth2 설정](#google-oauth2-설정)
2. [Kakao OAuth2 설정](#kakao-oauth2-설정)
3. [프로젝트 설정 적용](#프로젝트-설정-적용)
4. [테스트 방법](#테스트-방법)

---

## 🔍 Google OAuth2 설정

### 1단계: Google Cloud Console 접속
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. Google 계정으로 로그인

### 2단계: 프로젝트 생성 또는 선택
1. 상단 프로젝트 선택 드롭다운 클릭
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. 프로젝트 이름: `jeonbuk-report-app` (또는 원하는 이름)

### 3단계: OAuth 동의 화면 설정
1. 좌측 메뉴에서 **"API 및 서비스" > "OAuth 동의 화면"** 선택
2. 사용자 유형 선택:
   - **외부**: 일반 사용자용 (권장)
   - **내부**: Google Workspace 조직 내부용만
3. 필수 정보 입력:
   ```
   앱 이름: 전북 신고 앱
   사용자 지원 이메일: your-email@example.com
   개발자 연락처 정보: your-email@example.com
   ```

### 4단계: OAuth 클라이언트 ID 생성
1. **"API 및 서비스" > "사용자 인증 정보"** 선택
2. **"+ 사용자 인증 정보 만들기" > "OAuth 클라이언트 ID"** 클릭
3. 애플리케이션 유형: **웹 애플리케이션**
4. 이름: `jeonbuk-report-web-client`
5. **승인된 자바스크립트 원본** 추가:
   ```
   http://localhost:3000
   https://fix-jb.nodove.com
   ```
6. **승인된 리디렉션 URI** 추가:
   ```
   http://localhost:8080/oauth2/callback/google
   https://fix-jb.nodove.com/oauth2/callback/google
   ```

### 5단계: 클라이언트 정보 저장
생성 완료 후 다음 정보를 저장:
- **클라이언트 ID**: `123456789-abcdefghijk.apps.googleusercontent.com`
- **클라이언트 보안 비밀**: `GOCSPX-abcdefghijklmnopqrstuvwxyz`

---

## 🟡 Kakao OAuth2 설정

### 1단계: Kakao Developers 접속
1. [Kakao Developers](https://developers.kakao.com/) 접속
2. 카카오 계정으로 로그인

### 2단계: 애플리케이션 생성
1. **"내 애플리케이션"** 메뉴 선택
2. **"애플리케이션 추가하기"** 클릭
3. 필수 정보 입력:
   ```
   앱 이름: 전북신고앱
   사업자명: 개인 또는 회사명
   ```

### 3단계: 플랫폼 설정
1. 생성된 앱 선택 → **"플랫폼"** 탭
2. **"Web 플랫폼 등록"** 클릭
3. 사이트 도메인 입력:
   ```
   http://localhost:3000
   https://fix-jb.nodove.com
   ```

### 4단계: 카카오 로그인 활성화
1. **"카카오 로그인"** 탭 선택
2. **"활성화 설정"** → **ON**
3. **"Redirect URI 등록"** 클릭
4. Redirect URI 추가:
   ```
   http://localhost:8080/oauth2/callback/kakao
   https://fix-jb.nodove.com/oauth2/callback/kakao
   ```

### 5단계: 동의항목 설정
1. **"동의항목"** 탭 선택
2. 필수 동의항목 설정:
   - **프로필 정보(닉네임/프로필사진)**: 필수 동의
   - **카카오계정(이메일)**: 필수 동의 (이메일 제공 범위 설정)

### 6단계: 클라이언트 정보 확인
**"앱 설정" > "요약 정보"**에서 확인:
- **앱 키** > **REST API 키**: `1234567890abcdefghijklmnopqrstu`
- **보안** > **Client Secret**: `abcdefghijklmnopqrstuvwxyz123456`

---

## ⚙️ 프로젝트 설정 적용

### 1단계: API 키 설정 파일 업데이트
`config/api-keys.env` 파일을 열어 OAuth2 설정 부분을 업데이트:

```bash
# =============================================================================
# OAuth2 소셜 로그인 설정
# =============================================================================
# Google OAuth2
GOOGLE_CLIENT_ID=123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-abcdefghijklmnopqrstuvwxyz

# Kakao OAuth2
KAKAO_CLIENT_ID=1234567890abcdefghijklmnopqrstu
KAKAO_CLIENT_SECRET=abcdefghijklmnopqrstuvwxyz123456
```

### 2단계: 설정 적용
터미널에서 설정 적용 스크립트 실행:
```bash
chmod +x scripts/setup-api-keys.sh
./scripts/setup-api-keys.sh
```

### 3단계: 서비스 재시작
```bash
docker-compose down
docker-compose up -d
```

---

## 🧪 테스트 방법

### OAuth2 연결 테스트
```bash
# OAuth2 설정 테스트 실행
./scripts/test-api-keys.sh

# Google OAuth2 엔드포인트 테스트
curl "http://localhost:8080/oauth2/authorization/google"

# Kakao OAuth2 엔드포인트 테스트  
curl "http://localhost:8080/oauth2/authorization/kakao"
```

### 브라우저 테스트
1. **Google 로그인 테스트**:
   ```
   http://localhost:8080/oauth2/authorization/google
   ```

2. **Kakao 로그인 테스트**:
   ```
   http://localhost:8080/oauth2/authorization/kakao
   ```

### 성공적인 설정 확인 사항
✅ **Google**: 구글 로그인 화면이 나타나고 앱 승인 요청  
✅ **Kakao**: 카카오 로그인 화면이 나타나고 동의 항목 표시  
✅ **Redirect**: 로그인 후 지정된 URI로 정상 리디렉션  
✅ **Token**: JWT 토큰이 정상적으로 발급됨  

---

## 🔒 보안 고려사항

### 운영 환경 설정
1. **HTTPS 필수**: 운영 환경에서는 반드시 HTTPS 사용
2. **도메인 제한**: 승인된 도메인만 Redirect URI에 등록
3. **클라이언트 보안비밀 보호**: 환경변수로만 관리, 코드에 하드코딩 금지

### 추가 보안 설정
```bash
# CORS 설정 (운영환경 도메인만 허용)
CORS_ALLOWED_ORIGINS=https://fix-jb.nodove.com

# Secure Cookie 설정
COOKIE_SECURE=true
COOKIE_SAME_SITE=strict
```

---

## 🚨 문제 해결

### 자주 발생하는 오류

1. **"redirect_uri_mismatch"**
   - 해결: OAuth 콘솔에서 정확한 Redirect URI 등록 확인

2. **"invalid_client"**
   - 해결: Client ID와 Client Secret 정확성 확인

3. **"access_denied"**
   - 해결: OAuth 동의 화면 설정과 권한 범위 확인

### 로그 확인
```bash
# 서버 로그 확인
docker-compose logs main-api-server

# OAuth2 관련 로그 필터링
docker-compose logs main-api-server | grep -i oauth
```

---

## 📞 지원

설정 과정에서 문제가 발생하면:
1. 각 플랫폼의 공식 문서 참조
2. 프로젝트 로그 확인
3. API 키 테스트 스크립트 실행

**참고 링크**:
- [Google OAuth2 가이드](https://developers.google.com/identity/protocols/oauth2)
- [Kakao 로그인 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/common)