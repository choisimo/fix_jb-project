# 🎯 전북 현장 보고 시스템 - Roboflow 워크스페이스 실제 구성 가이드

## 📋 단계별 실행 체크리스트

### ✅ 1단계: Roboflow 계정 생성 및 기본 설정

#### 1.1 계정 생성
1. **웹사이트 방문**: [Roboflow.com](https://roboflow.com) 접속
2. **계정 생성**: 'Sign Up' 클릭 → 이메일/구글 계정으로 가입
3. **이메일 인증**: 가입 후 이메일 인증 완료
4. **플랜 선택**: 무료 플랜 (Free tier) 선택
   - ✅ 1,000 API calls/month
   - ✅ 10,000 source images
   - ✅ Unlimited public projects

#### 1.2 워크스페이스 설정
```
워크스페이스 이름: jeonbuk-reports
설명: 전북 시민 현장 보고 시스템용 AI 모델 워크스페이스
가시성: Private (추천) 또는 Public
```

---

### ✅ 2단계: 프로젝트 생성

#### 2.1 프로젝트 설정
1. **프로젝트 생성**: "Create New Project" 클릭
2. **프로젝트 정보 입력**:
   ```
   프로젝트명: integrated-detection
   설명: 전북 현장 문제 통합 감지 모델
   프로젝트 타입: Object Detection
   라이센스: MIT (권장)
   ```

#### 2.2 클래스 정의
프로젝트 생성 후 다음 16개 클래스 추가:

| 순번 | 클래스 ID           | 한글명          | 영문명              | 우선순위 |
| ---- | ------------------- | --------------- | ------------------- | -------- |
| 0    | road_damage         | 도로 파손       | road_damage         | 높음     |
| 1    | pothole             | 포트홀          | pothole             | 높음     |
| 2    | illegal_dumping     | 무단 투기       | illegal_dumping     | 낮음     |
| 3    | graffiti            | 낙서            | graffiti            | 낮음     |
| 4    | broken_sign         | 간판 파손       | broken_sign         | 보통     |
| 5    | broken_fence        | 펜스 파손       | broken_fence        | 보통     |
| 6    | street_light_out    | 가로등 고장     | street_light_out    | 보통     |
| 7    | manhole_damage      | 맨홀 손상       | manhole_damage      | 높음     |
| 8    | sidewalk_crack      | 인도 균열       | sidewalk_crack      | 보통     |
| 9    | tree_damage         | 나무 손상       | tree_damage         | 낮음     |
| 10   | construction_issue  | 공사 문제       | construction_issue  | 긴급     |
| 11   | traffic_sign_damage | 교통표지판 손상 | traffic_sign_damage | 보통     |
| 12   | building_damage     | 건물 손상       | building_damage     | 보통     |
| 13   | water_leak          | 누수            | water_leak          | 긴급     |
| 14   | electrical_hazard   | 전기 위험       | electrical_hazard   | 긴급     |
| 15   | other_public_issue  | 기타 공공 문제  | other_public_issue  | 낮음     |

---

### ✅ 3단계: API 키 설정

#### 3.1 API 키 발급
1. **설정 페이지 이동**: 우상단 프로필 → Settings
2. **API 키 확인**: 좌측 메뉴 → "API" 또는 "Roboflow API"
3. **Private API Key 복사**: "Copy" 버튼 클릭하여 클립보드에 복사

#### 3.2 환경변수 설정
프로젝트 루트에 `.env` 파일 생성:

```bash
# .env 파일 생성
cp .env.example .env

# API 키 설정 (실제 키로 변경)
ROBOFLOW_API_KEY=your_actual_private_api_key_here
ROBOFLOW_WORKSPACE=jeonbuk-reports
ROBOFLOW_PROJECT=integrated-detection
ROBOFLOW_VERSION=1
```

---

### ✅ 4단계: 초기 데이터셋 준비

#### 4.1 최소 데이터셋 수집
각 클래스당 **최소 20-30장**의 이미지 수집:

**우선순위별 데이터 수집 계획:**
- 🔴 **긴급/높음 우선순위** (6개 클래스): 각 30장씩 = 180장
- 🟡 **보통 우선순위** (6개 클래스): 각 25장씩 = 150장  
- 🟢 **낮음 우선순위** (4개 클래스): 각 20장씩 = 80장
- **총 목표**: 410장 (최소 기능 구현용)

#### 4.2 이미지 품질 기준
- **해상도**: 최소 640x480, 권장 1920x1080
- **파일 형식**: JPG, PNG (JPG 권장)
- **파일 크기**: 100KB - 5MB
- **촬영 조건**: 다양한 각도, 조명, 날씨 조건

---

### ✅ 5단계: 라벨링 작업

#### 5.1 Roboflow Annotate 사용
1. **이미지 업로드**: "Upload" → 이미지 파일 선택
2. **라벨링 시작**: "Annotate" 탭 이동
3. **바운딩 박스 그리기**: 
   - 객체 주위에 정확한 박스 그리기
   - 객체의 95% 이상 포함되도록 조정
4. **클래스 할당**: 해당하는 클래스 선택
5. **검토 및 저장**: "Save" 클릭

#### 5.2 라벨링 가이드라인
```
🎯 바운딩 박스 기준:
- 객체의 전체 영역 포함
- 배경 최소화
- 겹치는 객체는 개별 박스로 처리
- 일부만 보이는 객체도 포함

⚠️ 주의사항:
- 너무 작은 객체 (32x32 미만) 제외
- 흐릿하거나 식별 불가능한 객체 제외
- 동일 클래스의 여러 객체는 모두 라벨링
```

---

### ✅ 6단계: 첫 번째 모델 훈련

#### 6.1 데이터셋 분할
```
훈련용 (Train): 70% (287장)
검증용 (Valid): 20% (82장)
테스트용 (Test): 10% (41장)
```

#### 6.2 훈련 설정
```yaml
모델: YOLOv8n (빠른 테스트용)
Epochs: 50 (첫 번째 훈련)
Batch Size: 16
Image Size: 640
Augmentation: 기본 설정 사용
```

#### 6.3 훈련 시작
1. **Generate** 버튼 클릭
2. **Train Model** 선택
3. **훈련 설정** 확인 후 시작
4. **진행 상황 모니터링** (약 30분-1시간 소요)

---

### ✅ 7단계: API 연결 테스트

#### 7.1 설정 검증
```bash
# 설정 관리자 테스트
python config_manager.py
```

예상 출력:
```
🔧 현재 설정 상태:
  📁 워크스페이스: jeonbuk-reports
  📦 프로젝트: integrated-detection
  🔢 모델 버전: 1
  🎯 신뢰도 임계값: 50%
  📊 겹침 임계값: 30%
  🔐 API 키: ✅ 설정됨
  🧪 테스트 모드: ✅ 활성화
  🎭 모의 데이터: ✅ 활성화
```

#### 7.2 테스트 이미지 준비
```bash
# 테스트 이미지 다운로드
python download_test_images.py
```

#### 7.3 AI 분석 테스트
```bash
# Roboflow API 테스트
python roboflow_test.py
```

예상 출력:
```
🤖 Roboflow 서비스 초기화 중...
✅ Roboflow 서비스 초기화 완료
🔍 API 연결 테스트 중...
✅ API 연결 성공
📦 일괄 분석 시작: 3개 이미지
✅ 일괄 분석 완료: 3/3 성공
```

---

### ✅ 8단계: 성능 평가 및 개선

#### 8.1 성능 지표 확인
Roboflow 대시보드에서 확인:
- **mAP@0.5**: 목표 > 0.5 (첫 번째 모델)
- **Precision**: 클래스별 정밀도 확인
- **Recall**: 클래스별 재현율 확인
- **F1 Score**: 전체적인 성능 지표

#### 8.2 개선 사항 식별
- 성능이 낮은 클래스 확인
- 오분류가 많은 케이스 분석
- 추가 데이터 수집 계획 수립

---

## 🚨 문제 해결

### 자주 발생하는 문제와 해결책

#### 1. API 키 오류
```
오류: "Invalid API key"
해결: 
1. API 키 재확인 및 재발급
2. .env 파일 경로 및 형식 확인
3. 공백이나 특수문자 제거
```

#### 2. 프로젝트 찾을 수 없음
```
오류: "Project not found"
해결:
1. 워크스페이스 ID 확인
2. 프로젝트 ID 정확성 검증
3. 프로젝트 공개 설정 확인
```

#### 3. 모델 훈련 미완료
```
오류: "Model training in progress"
해결:
1. 훈련 완료까지 대기
2. 다른 버전의 모델 사용
3. 훈련 상태 대시보드에서 확인
```

#### 4. 데이터 부족 경고
```
경고: "Insufficient training data"
해결:
1. 각 클래스당 최소 20장 확보
2. 데이터 증강 기법 적용
3. 유사한 클래스 통합 고려
```

---

## 🎯 다음 단계 계획

### 단기 목표 (1-2주)
- [x] 기본 워크스페이스 설정 완료
- [x] 최소 데이터셋 수집 및 라벨링
- [x] 첫 번째 모델 훈련 완료
- [x] API 연결 테스트 성공

### 중기 목표 (1-2개월)
- [ ] 각 클래스당 100+ 이미지 확보
- [ ] 모델 성능 향상 (mAP > 0.7)
- [ ] Flutter 앱 완전 연동
- [ ] 실제 사용자 테스트

### 장기 목표 (3-6개월)
- [ ] 프로덕션 모델 완성 (mAP > 0.8)
- [ ] 실시간 모니터링 시스템
- [ ] 자동 재훈련 파이프라인
- [ ] 사용자 피드백 기반 개선

---

💡 **성공의 핵심**: 완벽한 모델보다는 **점진적 개선**이 중요합니다. 작은 데이터셋으로 시작하여 지속적으로 데이터를 추가하고 모델을 개선해나가세요!
