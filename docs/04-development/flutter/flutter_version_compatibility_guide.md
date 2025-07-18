# Flutter 최신 버전 및 호환성 가이드 (2025년 7월 기준)

## 1. Flutter 최신 버전 정보
- **Flutter Stable 최신 버전:** 3.22.x (2025년 7월 기준)
- [Flutter 공식 릴리즈 노트](https://docs.flutter.dev/release/whats-new)
- [Flutter SDK 다운로드](https://docs.flutter.dev/get-started/install)

## 2. 주요 라이브러리 및 플러그인 호환성
- pubspec.yaml의 `environment:` 섹션에서 Flutter 및 Dart SDK 버전을 명확히 지정하세요.
- 주요 플러그인(예: firebase, provider, dio 등)은 항상 Flutter 최신 stable 버전과 호환되는지 [pub.dev](https://pub.dev/)에서 확인하세요.
- Flutter 3.x 이상에서는 null safety가 필수입니다. null safety 미지원 패키지는 사용하지 마세요.
- Android/iOS 네이티브 연동 플러그인은 각 플랫폼의 최소 지원 버전(예: Android 6.0+, iOS 12+)을 확인하세요.

## 3. 버전 충돌 방지 및 관리 팁
- `flutter pub outdated` 명령어로 의존성 최신화 상태를 주기적으로 점검하세요.
- pubspec.lock 파일을 커밋하여 팀 내 버전 일관성을 유지하세요.
- 의존성 충돌 발생 시, pubspec.yaml에서 직접 버전을 명시하거나, 호환성 이슈가 있는 패키지는 공식 이슈 트래커를 확인하세요.
- CI/CD 파이프라인에서 `flutter analyze` 및 `flutter test`를 자동화하세요.

## 4. 참고 공식 문서 및 자료
- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Flutter 패키지 호환성 가이드](https://docs.flutter.dev/packages-and-plugins/using-packages)
- [Dart 공식 문서](https://dart.dev/guides)

---
> 본 문서는 2025년 7월 기준 최신 정보를 반영하였으며, Flutter 및 주요 라이브러리의 업데이트 주기를 고려해 주기적으로 갱신할 것을 권장합니다.
