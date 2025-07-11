# 🏃 실행 방법 요약

## 1. Flutter 앱 실행 (모바일/웹)
```bash
cd flutter-app
flutter pub get
flutter run --debug
```
- Android/iOS/웹 모두 지원
- 디바이스 목록 확인: `flutter devices`
- 특정 디바이스 실행: `flutter run -d <device-id>`

## 2. Roboflow AI 테스트 스크립트 실행

### 2-1. 테스트 모드 (API 키 없이도 가능)
```bash
python3 roboflow_test.py --test
```

### 2-2. 실제 이미지 분석 (API 키 필요)
```bash
python3 download_test_images.py
python3 roboflow_test.py --image test_images/sample1.jpg
```

### 2-3. 설정 확인
```bash
python3 roboflow_test.py --check-config
```

### 2-4. 백엔드 연동 테스트
```bash
python3 roboflow_test.py --test-backend
```

## 3. 통합 실행 스크립트 (대화형)
```bash
./run_demo.sh
```
- 메뉴에서 원하는 작업 선택 (테스트, 설정 확인, AI 분석 등)

## 4. 환경 변수 설정 (.env)
- AI 기능 사용 시 `.env` 파일에 아래 항목 입력:
```
ROBOFLOW_API_KEY=your_actual_api_key_here
ROBOFLOW_WORKSPACE=your_workspace_name
ROBOFLOW_PROJECT=your_project_name
```

## 5. 참고 문서
- [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)
- [ROBOFLOW_SETUP_STEP_BY_STEP.md](ROBOFLOW_SETUP_STEP_BY_STEP.md)
