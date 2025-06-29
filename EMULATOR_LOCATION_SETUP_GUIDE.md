# 에뮬레이터 위치 문제 진단 및 실행 가이드 🚀

## 🎯 목표
에뮬레이터에서 미국 위치가 아닌 한국 위치가 표시되도록 설정하고, 앱에서 정확한 위치를 받아오는 것을 확인합니다.

## 📋 사전 준비사항
- [ ] Android Studio 설치됨
- [ ] 에뮬레이터 생성됨 (API 레벨 23 이상 권장)
- [ ] ADB가 PATH에 설정됨
- [ ] Flutter 개발 환경 구성됨

## 🔍 1단계: 현재 상태 진단

### 에뮬레이터 실행 및 확인
```bash
# 1. 에뮬레이터 실행
# Android Studio > AVD Manager > 에뮬레이터 실행

# 2. ADB 연결 확인
adb devices

# 3. 현재 에뮬레이터 위치 확인 (구글 맵 등에서)
```

### Flutter 앱에서 위치 확인
```bash
# 1. Flutter 앱 실행
cd /home/nodove/workspace/fix_jeonbuk/flutter-app
flutter run

# 2. 앱에서 위치 관련 기능 테스트
# 3. 콘솔 로그에서 위치 정보 확인
```

## 🛠️ 2단계: 위치 설정

### 방법 1: 자동 스크립트 사용 (권장)
```bash
# GPS 위치 설정 스크립트 실행
./set_emulator_location.sh

# 스크립트에서 서울(1번) 선택 권장
```

### 방법 2: 수동 ADB 명령어
```bash
# 서울 좌표로 GPS 설정
adb emu geo fix 126.9780 37.5665

# 설정 확인 (구글 맵에서 현재 위치 확인)
```

### 방법 3: Extended Controls 사용
```bash
# 1. 에뮬레이터 창에서 "..." 버튼 클릭
# 2. "Extended controls" 선택
# 3. "Location" 탭 선택
# 4. 좌표 입력:
#    - Latitude: 37.5665
#    - Longitude: 126.9780
# 5. "Send" 버튼 클릭
```

## 🧪 3단계: 위치 테스트

### Flutter 앱에서 위치 테스트
```bash
# 1. 위치 테스트 위젯 사용
# lib/widgets/location_test_widget.dart를 앱에 추가하여 테스트

# 2. 또는 기존 기능에서 위치 테스트
# - 신고 작성 페이지에서 현재 위치 버튼 클릭
# - 지도에서 위치 마커 확인
```

### 콘솔 로그 모니터링
Flutter 앱 실행 시 다음과 같은 로그를 확인하세요:
```
🔍 위치 서비스 시작...
🔧 위치 서비스 디버깅 시작
📡 위치 서비스: 활성화
🔐 위치 권한: LocationPermission.whileInUse
📍 마지막 위치: 37.5665, 126.9780
✅ 위치 권한 확인 완료
🎯 정확도 레벨 시도: LocationAccuracy.best
✅ 위치 획득 성공: 37.5665, 126.9780
🏠 위치 확인: 한국 내
```

## ⚠️ 4단계: 문제 해결

### 여전히 미국 위치가 나오는 경우

#### 해결책 1: 에뮬레이터 재시작
```bash
# 1. 에뮬레이터 완전 종료
# 2. Cold Boot로 재시작
# 3. GPS 위치 재설정
./set_emulator_location.sh
```

#### 해결책 2: 에뮬레이터 설정 확인
```bash
# 에뮬레이터 내부 설정 확인:
# 설정 > 위치 > 위치 서비스 켜기
# 설정 > 위치 > 위치 모드 > 높은 정확도
# 설정 > 위치 > Google 위치 정확도 > 향상된 위치 서비스 켜기
```

#### 해결책 3: 앱 권한 확인
```bash
# 에뮬레이터에서:
# 설정 > 앱 > [앱 이름] > 권한 > 위치 > 허용
# 또는 앱 실행 시 권한 요청 대화상자에서 허용
```

#### 해결책 4: 네트워크 위치 비활성화
```bash
# Extended Controls > Location > Settings 탭
# GPS만 사용하도록 설정 (네트워크 기반 위치 비활성화)
```

### 위치 권한 문제

#### Android 권한 설정 확인
```xml
<!-- android/app/src/main/AndroidManifest.xml 확인 -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### 런타임 권한 처리 확인
앱에서 위치 권한 요청 대화상자가 나타나면 "허용" 선택

## 📊 5단계: 최종 확인

### 성공 기준 체크리스트
- [ ] 에뮬레이터에서 구글 맵이 한국(서울) 위치를 표시
- [ ] Flutter 앱 콘솔에서 한국 좌표 출력 확인
- [ ] 앱의 지도 기능에서 한국 위치 표시
- [ ] 위치 기반 기능들이 정상 동작

### 예상 결과
```bash
# 성공적인 로그 예시:
🌍 현재 위치: 37.5665, 126.9780
🏠 위치 확인: 한국 내
📊 정확도: 30.0m
✅ 위치 서비스 정상 동작
```

## 🚀 6단계: 실제 기기 테스트 준비

에뮬레이터에서 위치가 정상 동작하면, 실제 기기에서도 테스트해보세요:

```bash
# 1. 실제 Android 기기 연결
adb devices

# 2. 기기에서 위치 서비스 활성화
# 설정 > 위치 > 위치 서비스 켜기

# 3. Flutter 앱을 실제 기기에 설치하여 테스트
flutter run -d [device_id]

# 4. 야외에서 GPS 신호가 잘 잡히는 곳에서 테스트
```

## 📚 추가 리소스

### 관련 문서
- `LOCATION_GPS_TROUBLESHOOTING.md` - 상세한 문제 해결 가이드
- `lib/widgets/location_test_widget.dart` - 위치 테스트 위젯
- `lib/core/services/location_service.dart` - 위치 서비스 구현

### 유용한 명령어
```bash
# 에뮬레이터 GPS 상태 확인
adb shell dumpsys location

# 위치 제공자 확인
adb shell dumpsys location | grep -A 5 "Location Providers"

# 에뮬레이터 로그 실시간 모니터링
adb logcat | grep -E "(GPS|Location|Geolocator)"
```

### 디버깅 팁
1. **콘솔 로그 활용**: Flutter 앱의 상세한 위치 디버깅 로그 확인
2. **단계별 테스트**: 권한 → GPS 설정 → 위치 가져오기 순서로 테스트
3. **여러 방법 시도**: ADB, Extended Controls, 수동 설정 등 다양한 방법 활용
4. **재시작 효과**: 문제 발생 시 에뮬레이터 재시작이 해결하는 경우가 많음

---

이 가이드를 따라하면 에뮬레이터에서 한국 위치를 정확히 설정하고 Flutter 앱에서 올바른 위치 정보를 받아올 수 있습니다! 🇰🇷
