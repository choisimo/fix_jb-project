# 🚀 Roboflow AI 서비스 빠른 시작 가이드

## ✅ 현재 상태
- ✅ Python 패키지 설치 완료 (`roboflow`, `requests`, `pillow`)
- ✅ 테스트 모드 정상 작동 확인
- ⚠️ 실제 API 키 설정 필요 (AI 기능 사용 시)

## 🎯 단계별 실행 가이드

### 1단계: Roboflow 계정 생성 (무료)
1. [Roboflow.com](https://roboflow.com) 방문
2. "Sign Up" 클릭하여 계정 생성
3. 이메일 인증 완료

### 2단계: API 키 얻기
1. 로그인 후 대시보드에서 "Settings" 클릭
2. 좌측 메뉴에서 "Roboflow API" 선택
3. "Private API Key" 복사

### 3단계: 워크스페이스 및 프로젝트 생성
1. "Create New Project" 클릭
2. 프로젝트 유형: "Object Detection" 선택
3. 프로젝트 이름 입력 (예: `field-reports`)
4. 워크스페이스 이름 확인 (보통 계정명과 동일)

### 4단계: .env 파일 설정
```bash
# 루트 디렉토리에서 .env 파일 생성/수정
nano .env
```
아래 항목을 실제 값으로 입력:
```
ROBOFLOW_API_KEY=your_actual_api_key_here
ROBOFLOW_WORKSPACE=your_workspace_name
ROBOFLOW_PROJECT=your_project_name
```

## 🧪 테스트 명령어

### 1. 설정 확인
```bash
python3 roboflow_test.py --check-config
```

### 2. 테스트 모드 실행 (API 키 없이도 가능)
```bash
python3 roboflow_test.py --test
```

### 3. 실제 API 테스트 (API 키 필요)
```bash
# 샘플 이미지 다운로드
python3 download_test_images.py
# 실제 이미지 분석
python3 roboflow_test.py --image test_images/sample1.jpg
```

### 4. 백엔드 연동 테스트
```bash
python3 roboflow_test.py --test-backend
```

## 🛠️ 문제 해결
- **403 Forbidden**: API 키, 워크스페이스/프로젝트 이름, 인터넷 연결 확인
- **모듈 미설치**: `pip3 install roboflow requests pillow python-dotenv`
- **이미지 파일 오류**: 경로/확장자/크기(10MB 이하) 확인

## 📁 프로젝트 구조 (요약)
```
fix_jeonbuk/
  ├── roboflow_test.py          # 메인 테스트 스크립트
  ├── config_manager.py         # 설정 관리
  ├── download_test_images.py   # 샘플 이미지 다운로드
  ├── run_guide.py              # 설정 가이드
  ├── analyze_image.py          # AI 이미지 분석
  ├── integration_test.py       # 통합 테스트
  ├── simple_test.py            # 간단 테스트
  ├── test_api_key.py           # API 키 테스트
  ├── setup_and_test.py         # 환경설정 및 테스트
  ├── .env                      # 환경변수 설정
  ├── .env.example              # 설정 예제
  ├── documents/README.md       # 프로젝트 소개 및 가이드
  ├── documents/QUICK_START_GUIDE.md # 빠른 시작 가이드
  ├── documents/PROJECT_STATUS_SUMMARY.md # 진행상황 요약
  └── flutter-app/              # Flutter 모바일/웹 앱
      └── lib/                  # 주요 기능별 폴더
      └── test/                 # 테스트 코드
  └── spring-backend/           # Spring Boot 백엔드
      └── src/                  # 서비스/엔티티/컨트롤러 등
  └── database/                 # DB 스키마 및 초기화
  └── docker-compose.yml        # 서비스 오케스트레이션
```
## 🎉 성공 시 예상 출력
```
🚀 전북 현장 보고 시스템 - Roboflow AI 분석
============================================================
🔍 이미지 분석 중: sample1.jpg
✅ 분석 완료!
📊 감지된 객체:
   - 포트홀 (confidence: 85.2%)
   - 도로 파손 (confidence: 73.1%)
🎯 카테고리: 도로 관리
📌 우선순위: 높음
```

## 📚 추가 도움말
- 상세 설정 가이드: `ROBOFLOW_SETUP_STEP_BY_STEP.md`
- 통합 가이드: `ROBOFLOW_INTEGRATION_COMPLETE.md`
- AI 고도화 가이드: `ROBOFLOW_AI_ENHANCED_GUIDE.md`
