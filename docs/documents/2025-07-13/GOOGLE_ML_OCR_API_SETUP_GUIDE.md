# Google ML OCR API 키 및 설정 가이드

## 📋 요구사항 요약

### ✅ Google ML Kit (클라이언트) - API 키 불필요
- **완전 무료**: 온디바이스 처리
- **Firebase 설정만 필요**: 기존 프로젝트에 이미 설정됨
- **오프라인 동작**: 인터넷 연결 없이도 작동

### ⚠️ Google Cloud Vision API (서버) - API 키 필요
- **Google Cloud 프로젝트 생성**
- **Vision API 활성화**
- **서비스 계정 생성 및 키 파일 다운로드**
- **결제 정보 등록** (무료 할당량: 월 1,000회)

## 🔧 Google Cloud Vision API 설정 방법

### 1단계: Google Cloud 프로젝트 생성
```bash
# Google Cloud Console에서:
# 1. https://console.cloud.google.com 접속
# 2. 새 프로젝트 생성 또는 기존 프로젝트 선택
# 3. 프로젝트 ID 기록 (예: jb-report-ocr-project)
```

### 2단계: Vision API 활성화
```bash
# Google Cloud Console에서:
# 1. "API 및 서비스" > "라이브러리" 이동
# 2. "Cloud Vision API" 검색
# 3. "사용" 버튼 클릭
```

### 3단계: 서비스 계정 생성
```bash
# Google Cloud Console에서:
# 1. "IAM 및 관리자" > "서비스 계정" 이동
# 2. "서비스 계정 만들기" 클릭
# 3. 이름: jb-report-vision-service
# 4. 역할: "Cloud Vision API 사용자" 추가
# 5. JSON 키 파일 다운로드
```

### 4단계: 키 파일 배치
```bash
# 서버 프로젝트에 키 파일 배치
mkdir -p ai-analysis-server/src/main/resources/credentials/
cp ~/Downloads/jb-report-vision-service-key.json ai-analysis-server/src/main/resources/credentials/

# 또는 환경변수로 설정
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

## ⚙️ 설정 파일 업데이트

### application.yml 설정
```yaml
google:
  cloud:
    vision:
      enabled: true
      project-id: jb-report-ocr-project
      credentials-path: /credentials/jb-report-vision-service-key.json
```

### 환경변수 설정 (권장)
```bash
# 프로덕션 환경에서는 환경변수 사용 권장
export GOOGLE_CLOUD_PROJECT=jb-report-ocr-project
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

## 💰 비용 정보

### Google ML Kit (무료)
- **완전 무료**: 사용량 제한 없음
- **오프라인 처리**: 데이터 전송 비용 없음

### Google Cloud Vision API (유료)
- **무료 할당량**: 월 1,000회 텍스트 감지
- **초과 시 비용**: 1,000회당 $1.50
- **문서 텍스트 감지**: 1,000회당 $5.00

## 🔒 보안 고려사항

### 서비스 계정 키 보안
```bash
# 1. 키 파일 권한 설정
chmod 600 service-account-key.json

# 2. Git에서 제외
echo "src/main/resources/credentials/*.json" >> .gitignore

# 3. 환경변수 사용 권장 (프로덕션)
```

### 네트워크 보안
```yaml
# application.yml
google:
  cloud:
    vision:
      # IP 제한, VPC 설정 등 보안 옵션 추가 가능
      security:
        allowed-networks:
          - "10.0.0.0/8"
          - "192.168.0.0/16"
```

## 🧪 설정 검증 방법

### API 연결 테스트
```bash
# 서버 시작 후 로그 확인
./gradlew bootRun

# 로그에서 다음 메시지 확인:
# ✅ Google Cloud Vision API 클라이언트 초기화 완료
```

### API 호출 테스트
```bash
# OCR API 테스트
curl -X POST "http://localhost:8080/api/v1/ocr/extract" \
  -F "image=@test_image.jpg" \
  -F "enableGoogleVision=true"
```

## 🎯 권장 설정

### 개발 환경
```yaml
google:
  cloud:
    vision:
      enabled: false  # 개발 시에는 ML Kit만 사용
```

### 프로덕션 환경
```yaml
google:
  cloud:
    vision:
      enabled: true
      # 환경변수로 설정
```

## 🚨 문제 해결

### 일반적인 오류
1. **"인증 실패"**: 서비스 계정 키 경로 확인
2. **"API 비활성화"**: Google Cloud Console에서 Vision API 활성화
3. **"할당량 초과"**: Google Cloud Console에서 사용량 확인
4. **"네트워크 오류"**: 방화벽 및 프록시 설정 확인

### 폴백 전략
- Google Vision API 실패 시 자동으로 AI 모델(qwen2.5-vl)로 폴백
- 서버 연결 실패 시 클라이언트 ML Kit만 사용