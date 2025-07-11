# Jeonbuk 현장 보고 및 관리 통합 Flutter 앱

## 프로젝트 개요

이 Flutter 앱은 전북 지역 현장 보고 및 관리 시스템의 모바일/웹 클라이언트입니다. 현장 직원은 모바일 앱을 통해 현장 상황(사진, 위치, 특이사항 등)을 신속하게 보고하고, 관리자는 웹 대시보드에서 실시간으로 상황을 확인 및 조치할 수 있습니다.

- **플랫폼**: Android, iOS, Web (Desktop Browser)
- **주요 기능**:
  - 현장 보고서 작성(사진, 위치, 서명 등)
  - AI 기반 이미지 분석(Roboflow 연동)
  - 실시간 알림 및 피드백
  - 관리자 대시보드(웹)
  - OAuth2/JWT 기반 인증

## 주요 의존성

- Flutter 3.2 이상
- 주요 패키지: provider, dio, shared_preferences, google_sign_in, kakao_flutter_sdk, flutter_naver_login, geolocator, camera, image_picker, google_ml_kit, flutter_dotenv 등
- 상세 의존성은 [pubspec.yaml](pubspec.yaml) 참고

## 설치 및 실행 방법

### 1. Flutter 환경 준비
```bash
# Flutter 설치 (https://docs.flutter.dev/get-started/install)
flutter --version
```

### 2. 패키지 설치
```bash
cd flutter-app
flutter pub get
```

### 3. 환경 변수 설정 (AI 기능 사용 시)
- 루트 디렉토리에 `.env` 파일 생성 후 아래 항목 입력:
```
ROBOFLOW_API_KEY=your_actual_api_key_here
ROBOFLOW_WORKSPACE=your_workspace_name
ROBOFLOW_PROJECT=your_project_name
```

### 4. 앱 실행
```bash
# Android/iOS/웹 디버그 실행
flutter run --debug
# 특정 디바이스 지정 실행
flutter devices
flutter run -d <device-id>
```

## 테스트 계정 (개발/테스트용)
- 관리자: `admin@test.com` / `admin123`
- 일반 사용자: `user@test.com` / `user123`

## 참고 문서
- [QUICK_START_GUIDE.md](../documents/QUICK_START_GUIDE.md)
- [RUN_INSTRUCTIONS.md](../documents/RUN_INSTRUCTIONS.md)
- [ROBOFLOW_SETUP_STEP_BY_STEP.md](../documents/ROBOFLOW_SETUP_STEP_BY_STEP.md)

## 문의
- 시스템/앱 관련 문의: 관리자 또는 개발팀에 연락
