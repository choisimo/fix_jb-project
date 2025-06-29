# 네이버 지도 API 설정 가이드

## 현재 상태
- ✅ Flutter 패키지: `flutter_naver_map: ^1.2.3` 설치됨
- ✅ Android minSdkVersion: 23으로 업데이트됨
- ✅ Client ID: `6gmofoay96` 설정됨
- ❌ 인증 실패: 401 Unauthorized client

## 해결해야 할 문제

### 1. 네이버 클라우드 플랫폼 설정 확인
1. [네이버 클라우드 플랫폼 콘솔](https://console.ncloud.com/) 접속
2. Application > oss-project-4w 선택
3. **Android 설정**에서 Package Name이 `com.example.flutter_report_app`인지 확인
4. **Services**에서 Maps > Mobile Maps가 활성화되어 있는지 확인

### 2. 패키지 이름 변경 옵션
현재 앱 패키지: `com.example.flutter_report_app`
네이버에 등록된 패키지가 다르다면 둘 중 하나를 변경해야 합니다:

#### 옵션 A: 네이버 클라우드 플랫폼에서 패키지 이름 변경
- 네이버 콘솔에서 Android 패키지 이름을 `com.example.flutter_report_app`로 변경

#### 옵션 B: 앱 패키지 이름 변경 (권장하지 않음)
- `android/app/build.gradle.kts`에서 `namespace` 변경
- `AndroidManifest.xml`에서 패키지 관련 설정 변경

### 3. 현재 설정 파일들

#### AndroidManifest.xml
```xml
<meta-data android:name="com.naver.maps.map.CLIENT_ID"
    android:value="6gmofoay96" />
```

#### iOS Info.plist
```xml
<key>NMFClientId</key>
<string>6gmofoay96</string>
```

#### main.dart
```dart
await NaverMapSdk.instance.initialize(
  clientId: '6gmofoay96',
  onAuthFailed: (e) {
    print('Naver Map Auth Failed: $e');
  },
);
```

## 다음 단계

1. 네이버 클라우드 플랫폼에서 패키지 이름 확인/수정
2. Mobile Maps 서비스 활성화 확인
3. 앱 재빌드 및 테스트
4. 여전히 문제가 있다면 네이버 클라우드 플랫폼 고객지원 문의

## 참고 링크
- [네이버 지도 Android SDK 가이드](https://navermaps.github.io/android-map-sdk/guide-ko/)
- [네이버 클라우드 플랫폼 Maps API](https://guide.ncloud-docs.com/docs/naveropenapi-maps-overview)
