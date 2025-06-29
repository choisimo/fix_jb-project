# 위치/GPS 문제 해결 가이드 🌍

## 📍 문제 상황
- 에뮬레이터에서 위치가 미국으로 표시됨
- 실제 기기에서 위치가 부정확함
- GPS 위치 서비스가 작동하지 않음

## 🔍 진단 과정

### 1. 현재 위치 서비스 상태 확인
```bash
# Flutter 앱 실행 후 콘솔 로그 확인
flutter run
```

### 2. 위치 디버깅 로그 확인
앱 실행 시 다음과 같은 로그가 출력됩니다:
```
🔍 위치 서비스 시작...
✅ 위치 권한 확인 완료
🌍 현재 위치: 37.7749, -122.4194
🏠 위치 확인: 해외 (37.7749, -122.4194)
⚠️ 경고: 현재 위치가 해외로 감지됨. 에뮬레이터 GPS 설정을 확인해주세요.
```

## 🛠️ 해결 방법

### A. 에뮬레이터 위치 설정

#### 1. Android Studio 에뮬레이터
```bash
# 에뮬레이터 실행 후
# 1. 에뮬레이터 창 오른쪽 패널에서 "..." 클릭
# 2. "Extended controls" 선택
# 3. "Location" 탭 선택
# 4. 한국 좌표 설정:
#    - Latitude: 37.5665 (서울)
#    - Longitude: 126.9780 (서울)
# 5. "Send" 버튼 클릭
```

#### 2. 명령줄로 위치 설정
```bash
# ADB 명령어로 위치 설정
adb emu geo fix 126.9780 37.5665

# 또는 텔넷으로 연결
telnet localhost 5554
geo fix 126.9780 37.5665
```

#### 3. 에뮬레이터 GPS 설정 확인
```bash
# 에뮬레이터 설정 > 위치 > GPS 활성화 확인
# Extended Controls > Location > GPS 탭에서 위성 상태 확인
```

### B. 실제 기기 위치 설정

#### 1. 안드로이드 기기
```bash
# 설정 > 위치 > 위치 서비스 켜기
# 설정 > 위치 > 위치 정확도 > 높은 정확도 선택
# 설정 > 앱 > [앱이름] > 권한 > 위치 > 허용
```

#### 2. iOS 기기
```bash
# 설정 > 개인정보 보호 > 위치 서비스 > 켜기
# 설정 > 개인정보 보호 > 위치 서비스 > [앱이름] > 앱 사용 중 허용
```

### C. 코드 레벨 디버깅

#### 1. 위치 서비스 상태 확인 함수 추가
```dart
// lib/core/services/location_service.dart에 추가
Future<void> debugLocationService() async {
  print('🔧 위치 서비스 디버깅 시작');
  
  // 1. 위치 서비스 활성화 확인
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  print('📡 위치 서비스: ${serviceEnabled ? "활성화" : "비활성화"}');
  
  // 2. 권한 상태 확인
  LocationPermission permission = await Geolocator.checkPermission();
  print('🔐 위치 권한: $permission');
  
  // 3. 마지막 알려진 위치 확인
  try {
    Position? lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      print('📍 마지막 위치: ${lastPosition.latitude}, ${lastPosition.longitude}');
    } else {
      print('📍 마지막 위치: 없음');
    }
  } catch (e) {
    print('❌ 마지막 위치 확인 실패: $e');
  }
  
  // 4. 위치 정확도 설정 확인
  LocationAccuracyStatus accuracy = await Geolocator.getLocationAccuracy();
  print('🎯 위치 정확도: $accuracy');
  
  print('🔧 위치 서비스 디버깅 완료');
}
```

#### 2. 위치 가져오기 함수 개선
```dart
Future<Position> getCurrentPositionWithFallback() async {
  try {
    print('🔍 위치 가져오기 시작...');
    
    // 디버깅 정보 출력
    await debugLocationService();
    
    // 권한 확인
    await requestLocationPermission();
    
    // 여러 정확도 레벨로 시도
    List<LocationAccuracy> accuracyLevels = [
      LocationAccuracy.best,
      LocationAccuracy.high,
      LocationAccuracy.medium,
      LocationAccuracy.low,
    ];
    
    for (LocationAccuracy accuracy in accuracyLevels) {
      try {
        print('🎯 정확도 레벨 시도: $accuracy');
        
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: Duration(seconds: 15),
        );
        
        print('✅ 위치 획득 성공: ${position.latitude}, ${position.longitude}');
        
        // 한국 범위 확인
        bool isInKorea = _isPositionInKorea(position);
        print('🏠 위치 확인: ${isInKorea ? "한국 내" : "해외"}');
        
        if (!isInKorea) {
          print('⚠️ 해외 위치 감지. 에뮬레이터 GPS 설정 확인 필요');
          _printLocationTroubleshooting();
        }
        
        return position;
      } catch (e) {
        print('❌ 정확도 $accuracy 실패: $e');
        continue;
      }
    }
    
    // 모든 정확도 레벨 실패시 마지막 위치 시도
    Position? lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      print('📍 마지막 알려진 위치 사용: ${lastPosition.latitude}, ${lastPosition.longitude}');
      return lastPosition;
    }
    
    throw Exception('모든 위치 가져오기 방법 실패');
    
  } catch (e) {
    print('❌ 위치 가져오기 최종 실패: $e');
    print('🔧 기본 위치(서울) 사용');
    
    return _getDefaultSeoulPosition();
  }
}

bool _isPositionInKorea(Position position) {
  // 한국 영토 범위 (더 정확한 좌표)
  return position.latitude >= 33.0 && position.latitude <= 43.0 &&
         position.longitude >= 124.0 && position.longitude <= 132.0;
}

Position _getDefaultSeoulPosition() {
  return Position(
    longitude: 126.9780,  // 서울 경도
    latitude: 37.5665,    // 서울 위도
    timestamp: DateTime.now(),
    accuracy: 100.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );
}

void _printLocationTroubleshooting() {
  print('');
  print('🔧 위치 문제 해결 가이드:');
  print('');
  print('📱 에뮬레이터 사용 시:');
  print('1. Extended Controls > Location');
  print('2. 한국 좌표 설정: 37.5665, 126.9780');
  print('3. Send 버튼 클릭');
  print('');
  print('🏠 실제 기기 사용 시:');
  print('1. 설정 > 위치 > 위치 서비스 켜기');
  print('2. 설정 > 위치 > 높은 정확도 선택');
  print('3. 야외에서 GPS 신호 수신 확인');
  print('');
}
```

### D. 권한 설정 확인

#### 1. AndroidManifest.xml 권한 확인
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### 2. iOS Info.plist 권한 확인
```xml
<!-- ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>이 앱은 신고 위치 정보를 위해 현재 위치가 필요합니다.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>이 앱은 신고 위치 정보를 위해 현재 위치가 필요합니다.</string>
```

## 📋 체크리스트

### 에뮬레이터 체크리스트
- [ ] Extended Controls > Location에서 한국 좌표 설정
- [ ] GPS 위성 상태 확인
- [ ] 에뮬레이터 위치 서비스 활성화 확인
- [ ] 앱 위치 권한 허용 확인

### 실제 기기 체크리스트
- [ ] 기기 위치 서비스 활성화
- [ ] 위치 정확도 "높은 정확도" 설정
- [ ] 앱 위치 권한 허용
- [ ] GPS 신호 수신 가능한 환경 확인

### 코드 체크리스트
- [ ] 위치 권한 매니페스트 등록
- [ ] 위치 서비스 초기화 코드 확인
- [ ] 위치 가져오기 타임아웃 설정
- [ ] 에러 핸들링 및 폴백 로직 구현

## 🧪 테스트 방법

### 1. 위치 서비스 테스트 위젯 추가
```dart
// lib/widgets/location_test_widget.dart
class LocationTestWidget extends StatefulWidget {
  @override
  _LocationTestWidgetState createState() => _LocationTestWidgetState();
}

class _LocationTestWidgetState extends State<LocationTestWidget> {
  String _locationInfo = '위치 정보 없음';
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_locationInfo),
        ElevatedButton(
          onPressed: _testLocation,
          child: Text('위치 테스트'),
        ),
      ],
    );
  }
  
  Future<void> _testLocation() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      
      setState(() {
        _locationInfo = '위도: ${position.latitude}\n'
                       '경도: ${position.longitude}\n'
                       '정확도: ${position.accuracy}m\n'
                       '시간: ${position.timestamp}';
      });
    } catch (e) {
      setState(() {
        _locationInfo = '위치 오류: $e';
      });
    }
  }
}
```

### 2. 위치 실시간 모니터링
```dart
// 위치 스트림 테스트
StreamSubscription<Position>? _locationSubscription;

void _startLocationMonitoring() {
  _locationSubscription = LocationService().getLocationStream().listen(
    (position) {
      print('📍 실시간 위치: ${position.latitude}, ${position.longitude}');
    },
    onError: (error) {
      print('❌ 위치 스트림 오류: $error');
    },
  );
}

void _stopLocationMonitoring() {
  _locationSubscription?.cancel();
}
```

## 🚀 실행 및 확인

### 1. 위치 서비스 디버깅 실행
```bash
# 앱 실행 후 콘솔에서 위치 로그 확인
flutter run --verbose

# 또는 디버그 모드로 실행
flutter run --debug
```

### 2. 로그 분석
```bash
# 위치 관련 로그만 필터링
flutter logs | grep -E "(🔍|📍|🌍|⚠️|❌)"
```

### 3. 네이티브 로그 확인
```bash
# Android 로그
adb logcat | grep -E "(GPS|Location|Geolocator)"

# iOS 로그 (시뮬레이터)
xcrun simctl spawn booted log stream --predicate 'category == "Location"'
```

## 🔧 고급 문제 해결

### 1. 에뮬레이터 GPS 모의 데이터 설정
```bash
# 여러 위치 포인트 설정
adb emu geo fix 126.9780 37.5665  # 서울
adb emu geo fix 129.0756 35.1796  # 부산
adb emu geo fix 127.3849 36.3504  # 대전
```

### 2. 실제 기기 GPS 상태 확인
```bash
# GPS 상태 확인 앱 추가 정보
# - GPS 위성 개수
# - 신호 강도
# - 위치 정확도
# - 마지막 업데이트 시간
```

### 3. 네트워크 위치 vs GPS 위치
```dart
// 위치 제공자별 정보 확인
Future<void> checkLocationProviders() async {
  try {
    // 네트워크 기반 위치
    Position networkPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
    print('📶 네트워크 위치: ${networkPosition.latitude}, ${networkPosition.longitude}');
    
    // GPS 기반 위치
    Position gpsPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    print('🛰️ GPS 위치: ${gpsPosition.latitude}, ${gpsPosition.longitude}');
    
  } catch (e) {
    print('❌ 위치 제공자 확인 실패: $e');
  }
}
```

## 📚 추가 리소스

### 공식 문서
- [Geolocator 패키지](https://pub.dev/packages/geolocator)
- [Android 위치 서비스](https://developer.android.com/guide/topics/location)
- [iOS 위치 서비스](https://developer.apple.com/documentation/corelocation)

### 일반적인 문제와 해결책
1. **권한 거부**: 앱 설정에서 위치 권한 재설정
2. **위치 서비스 비활성화**: 기기 설정에서 위치 서비스 활성화
3. **GPS 신호 약함**: 야외 환경에서 테스트 또는 WiFi 위치 사용
4. **에뮬레이터 기본 위치**: Extended Controls에서 수동 위치 설정

---

이 가이드를 따라 위치 서비스 문제를 단계별로 해결하고, 한국 내 정확한 위치를 얻을 수 있습니다. 🌏
