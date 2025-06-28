# 🔧 Roboflow 실제 설정 가이드

## 1. Roboflow 계정 및 워크스페이스 생성

### 1.1 계정 생성
1. [Roboflow.com](https://roboflow.com) 방문
2. 무료 계정 생성 (Free tier: 1,000 API calls/month)
3. 워크스페이스 이름: `jeonbuk-reports` 또는 `jeonbuk-citizen-reports`

### 1.2 프로젝트 생성
```bash
워크스페이스: jeonbuk-reports
프로젝트명: integrated-detection
프로젝트 타입: Object Detection
어노테이션 그룹: Single Class per Project 또는 Multi-Class
```

## 2. API 키 설정

### 2.1 API 키 발급
1. Roboflow 대시보드 → Settings → API Keys
2. Private API Key 복사
3. 프로젝트에 적용

### 2.2 환경변수 설정 (권장)
```bash
# .env 파일 생성
export ROBOFLOW_API_KEY="your_private_api_key_here"
export ROBOFLOW_WORKSPACE="jeonbuk-reports"
export ROBOFLOW_PROJECT="integrated-detection"
export ROBOFLOW_VERSION="1"
```

## 3. 초기 데이터셋 준비

### 3.1 샘플 이미지 수집
전북 지역의 실제 현장 문제 이미지 수집:
- 도로 파손 사진 10-20장
- 포트홀 사진 10-20장
- 가로등 고장 사진 10-20장
- 무단 투기 사진 10-20장

### 3.2 라벨링 작업
1. Roboflow Annotate 도구 사용
2. 바운딩 박스 그리기
3. 클래스 할당
4. 품질 검토

## 4. 모델 훈련 시작

### 4.1 첫 번째 모델 훈련
```python
# Roboflow에서 제공하는 기본 설정
model_config = {
    "epochs": 50,        # 첫 번째는 빠른 테스트용
    "batch_size": 16,
    "image_size": 640,
    "model": "yolov8n"   # 가벼운 모델로 시작
}
```

### 4.2 성능 평가
- mAP@0.5 > 0.5 목표 (첫 번째 모델)
- 각 클래스별 최소 정밀도 확인
- 추론 속도 측정

## 5. Flask 앱에서 테스트

### 5.1 API 연결 테스트
```python
# 테스트 스크립트 실행
python roboflow_test.py
```

### 5.2 예상 결과
```
🤖 Roboflow 서비스 초기화 중...
✅ Roboflow 서비스 초기화 완료
🔍 API 연결 테스트 중...
✅ API 연결 성공
```

## 6. 문제 해결

### 6.1 일반적인 오류
- API 키 오류: "Invalid API key"
- 프로젝트 없음: "Project not found"
- 모델 미완성: "Model training in progress"

### 6.2 해결 방법
1. API 키 재확인
2. 워크스페이스/프로젝트 ID 정확성 검증
3. 모델 훈련 완료 대기
4. 인터넷 연결 확인

## 7. 다음 단계

1. ✅ 기본 모델 생성 및 테스트
2. 📊 더 많은 데이터 수집 (각 클래스 100+ 이미지)
3. 🎯 모델 성능 향상 (mAP > 0.7)
4. 🔧 Flutter 앱 완전 연동
5. 🚀 프로덕션 배포

---
💡 **팁**: 첫 번째 모델은 완벽하지 않아도 괜찮습니다. 점진적으로 개선해나가는 것이 핵심입니다!
