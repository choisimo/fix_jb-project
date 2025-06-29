# � Roboflow API 오류 해결 가이드

## � Flutter 앱 설정 개선사항

### ✅ 해결된 문제들

#### 1. 설정 저장 문제 ✅
**문제**: 설정이 제대로 저장되지 않음
**해결**: 
- `RoboflowService.saveAllSettings()` 메서드로 원자적 저장
- 설정 저장 후 자동 검증 추가
- 더 명확한 성공/실패 피드백

#### 2. 프로젝트 이름 혼동 ✅
**문제**: 사용자가 올바른 프로젝트 이름을 모름
**해결**:
- 상세한 프로젝트 이름 가이드 추가
- 빠른 설정 버튼으로 일반적인 프리셋 제공
- Roboflow 대시보드 URL에서 이름 확인하는 방법 안내

#### 3. API 키 형식 검증 ✅
**문제**: 잘못된 API 키 형식 입력
**해결**:
- 실시간 API 키 형식 검증
- 일반적인 잘못된 값들 필터링
- API 키 마스킹으로 보안 강화

## 🎯 주요 개선사항

### 1. 향상된 설정 UI
```dart
// 빠른 프리셋 버튼
_buildQuickSetupButton('현장 보고서', 'field-reports', 'jeonbuk-reports')
_buildQuickSetupButton('손상 감지', 'damage-detection', 'infrastructure')  
_buildQuickSetupButton('COCO 테스트', 'coco', 'roboflow-100')
```

### 2. 원자적 설정 저장
```dart
final success = await RoboflowService.saveAllSettings(
  apiKey: apiKey.trim(),
  workspace: workspace.trim(), 
  project: project.trim(),
);
```

### 3. 실시간 유효성 검증
- API 키 형식 자동 검증
- 설정 값 범위 확인
- 연결 상태 실시간 테스트

### 4. 사용자 가이드 통합
- 앱 내 도움말 버튼 (❓)
- 단계별 설정 가이드 다이얼로그
- 프로젝트 이름 확인 방법 안내

## 🚀 사용법

### 1. 설정 페이지 접근
1. Flutter 앱에서 **설정** → **Roboflow AI 설정**
2. 상단의 **❓ 도움말** 버튼으로 가이드 확인

### 2. 빠른 설정 (추천)
1. 프로젝트 이름 가이드 섹션에서 빠른 설정 버튼 클릭
2. 본인의 Roboflow API 키만 입력
3. **설정 저장** 클릭

### 3. 연결 테스트
1. 우상단 메뉴 (⋮) → **연결 테스트**
2. 결과 확인:
   - ✅ 연결 성공
   - ❌ 연결 실패 시 설정 재확인

## 🔍 일반적인 오류와 해결방법

| 오류 메시지                   | 원인                    | 해결방법                                     |
| ----------------------------- | ----------------------- | -------------------------------------------- |
| "API 키가 유효하지 않습니다"  | 잘못된 API 키           | Roboflow 대시보드에서 Private API Key 재확인 |
| "프로젝트를 찾을 수 없습니다" | 프로젝트 이름 불일치    | 빠른 설정 버튼 사용 또는 정확한 이름 확인    |
| "워크스페이스 접근 권한 없음" | 워크스페이스 이름 오류  | Roboflow URL에서 워크스페이스 이름 확인      |
| "연결 테스트 실패"            | 네트워크 또는 설정 문제 | 인터넷 연결 확인 후 설정 재검토              |

## ⚡ 고급 사용법

### 개발 모드
- 개발 중에는 자동으로 목업 데이터 사용
- 실제 API 비용 절약
- 기능 테스트에 적합

### 백엔드 연동
- 서버를 통한 분석 시 **백엔드 사용** 옵션 활성화
- 백엔드 URL 설정 (기본: localhost:8080)

### 성능 튜닝
- **신뢰도 임계값**: 50-80% (높을수록 정확하지만 감지량 감소)
- **겹침 임계값**: 20-40% (낮을수록 중복 제거 강화)

## 📋 문제 해결 체크리스트

1. ☑️ Roboflow 계정 및 프로젝트 확인
2. ☑️ Private API Key 복사 정확성
3. ☑️ 프로젝트/워크스페이스 이름 일치
4. ☑️ 인터넷 연결 상태
5. ☑️ 앱 권한 설정 (카메라, 저장소)
6. ☑️ 설정 저장 및 연결 테스트

## 🆘 추가 지원

### 로그 확인 (개발자용)
```bash
# Flutter 로그 확인
flutter logs

# 주요 로그 메시지
✅ 모든 설정 저장 완료
🔑 API Key: abcd****efgh
🏢 Workspace: jeonbuk-reports  
📁 Project: field-reports
```

### 설정 파일 위치
- Android: `/data/data/com.jeonbuk.report/shared_prefs/`
- iOS: `NSUserDefaults`

---

**최종 업데이트**: 2024년 12월  
**상태**: ✅ 모든 주요 문제 해결됨

## 🧪 **테스트 방법**

### **즉시 테스트 가능 (API 키 없이)**
```bash
# Flutter 앱 실행
cd flutter-app
flutter run

# 이미지 선택 후 "AI 분석" 버튼 클릭
# → 목업 결과가 표시됨
```

### **실제 API 테스트 (API 키 있을 때)**
```bash
# Python으로 먼저 검증
python3 simple_test.py

# 설정 확인
python3 roboflow_test.py --check-config

# 실제 이미지 분석
python3 roboflow_test.py --image test_images/road_damage_1.jpg
```

## 🎯 **추천 설정 예시**

### **무료 계정 생성 시 권장 설정**
```
Project Name: field-reports
Project Type: Object Detection  
Classes: damage, pothole, graffiti, trash
License: MIT
```

### **Flutter 앱 설정 입력**
```
API Key: [복사한 Private API Key]
Workspace: [계정명 또는 workspace ID]
Project: field-reports
Version: 1
```

## 🚀 **현재 상태**

✅ **완료된 기능들**
- Python 스크립트 완전 작동 (목업 모드)
- Flutter 앱 UI 완성
- Spring Boot 백엔드 API 설계
- 에러 처리 및 목업 모드
- 상세 문서화

⚠️ **필요한 작업**
- 실제 Roboflow API 키 설정 (사용자가 직접)
- Flutter 앱에서 설정 페이지에 API 정보 입력

## 💡 **즉시 실행 명령어**

```bash
# 1. Flutter 앱 실행 (목업 모드로 동작)
cd flutter-app && flutter run

# 2. Python 테스트 (목업 모드)
python3 roboflow_test.py --test

# 3. 대화형 데모 실행
./run_demo.sh
```

**결론**: 코드는 모두 수정되었고, 이제 실제 API 키만 설정하면 정상 작동합니다. API 키가 없어도 목업 모드로 앱 전체 기능을 테스트할 수 있습니다!
