# Roboflow AI 서비스 빠른 시작 가이드

## 1. 현재 상태
- Python 패키지 설치 완료 (`roboflow`, `requests`, `pillow`)
- 테스트 모드 정상 작동 확인
- 실제 API 키 필요 (AI 기능 사용 시)

## 2. 단계별 실행 가이드
### 1단계: Roboflow 계정 생성
- https://roboflow.com 방문, Sign Up 클릭, 이메일 인증

### 2단계: API 키 받기
- 로그인 후 대시보드 > Settings > Roboflow API > Private API Key 복사

### 3단계: 워크스페이스/프로젝트 생성
- Create New Project > Object Detection 선택 > 프로젝트명 입력
- 워크스페이스명 확인

### 4단계: .env 파일 설정
```bash
ROBOFLOW_API_KEY=your_actual_api_key_here
ROBOFLOW_WORKSPACE=your_workspace_name
ROBOFLOW_PROJECT=your_project_name
```

### 5단계: 테스트 명령어
```bash
python3 roboflow_test.py --check-config
python3 roboflow_test.py --test
python3 roboflow_test.py --image test_images/sample1.jpg
```

## 3. 참고 문서
- ROBOFLOW_SETUP_STEP_BY_STEP.md
- ROBOFLOW_INTEGRATION_COMPLETE.md
- ROBOFLOW_AI_ENHANCED_GUIDE.md
