# ROBOFLOW AI 통합 가이드 (완전판)
**최종 업데이트: 2025-07-13**

---

## 📋 개요

본 문서는 전북 신고 플랫폼에 Roboflow AI 객체 감지 시스템을 완전히 통합하는 종합 가이드입니다. 설정부터 실제 운영까지 모든 단계를 포함합니다.

---

## 🏗️ 시스템 아키텍처

```
Flutter App ←→ Spring Boot Backend ←→ Roboflow API
     ↓                ↓                    ↓
UI Components    Service Layer        AI Detection
Config Manager   Domain/DTOs         Cloud Models
Error Handling   REST Controllers     JSON Response
```

---

## 🚀 1단계: Roboflow 계정 및 워크스페이스 설정

### 1.1 계정 생성
1. **웹사이트 방문**: [Roboflow.com](https://roboflow.com) 접속
2. **계정 생성**: 'Sign Up' 클릭 → 이메일/구글 계정으로 가입
3. **이메일 인증**: 가입 후 이메일 인증 완료
4. **플랜 선택**: 무료 플랜 (Free tier) 선택
   - ✅ 1,000 API calls/month
   - ✅ 10,000 source images
   - ✅ Unlimited public projects

### 1.2 워크스페이스 설정
```
워크스페이스 이름: jeonbuk-reports
설명: 전북 시민 현장 보고 시스템용 AI 모델 워크스페이스
가시성: Private (추천) 또는 Public
```

### 1.3 프로젝트 생성
```
프로젝트명: integrated-detection
설명: 전북 현장 문제 통합 감지 모델
프로젝트 타입: Object Detection
라이센스: MIT (권장)
```

---

## 📊 2단계: 객체 클래스 정의

### 감지 대상 클래스 (16개)

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

## ⚙️ 3단계: API 키 및 환경 설정

### 3.1 API 키 발급
1. **설정 페이지 이동**: 우상단 프로필 → Settings
2. **API 키 확인**: 좌측 메뉴 → "API" 또는 "Roboflow API"
3. **Private API Key 복사**: "Copy" 버튼 클릭하여 클립보드에 복사

### 3.2 환경변수 설정
프로젝트 루트에 `.env` 파일 생성:

```bash
# .env 파일 생성
cp .env.example .env

# API 키 설정 (실제 키로 변경)
ROBOFLOW_API_KEY=your_actual_private_api_key_here
ROBOFLOW_WORKSPACE=jeonbuk-reports
ROBOFLOW_PROJECT=integrated-detection
ROBOFLOW_VERSION=1
ROBOFLOW_API_URL=https://detect.roboflow.com
```

### 3.3 Backend 설정 (`application.properties`)

```properties
# Roboflow AI Integration
roboflow.api.key=${ROBOFLOW_API_KEY:}
roboflow.workspace=${ROBOFLOW_WORKSPACE:}
roboflow.project=${ROBOFLOW_PROJECT:}
roboflow.version=${ROBOFLOW_VERSION:1}
roboflow.api.url=${ROBOFLOW_API_URL:https://detect.roboflow.com}

# File Upload Settings
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=50MB
```

---

## 📁 4단계: 프로젝트 구조 설정

### Backend (Spring Boot)
```
main-api-server/src/main/java/com/jeonbuk/report/
├── controller/
│   ├── AIAnalysisController.java      # REST API endpoints
│   └── ReportController.java          # Report management
├── service/
│   └── RoboflowService.java          # Core AI integration logic
├── dto/
│   ├── AIAnalysisRequest.java         # Request DTO
│   ├── AIAnalysisResponse.java        # Response DTO
│   └── common/CommonDto.java          # Shared DTOs
├── domain/
│   ├── report/Report.java             # Domain entities
│   └── user/User.java                 # User entities
└── config/
    └── RestClientConfig.java          # HTTP client configuration
```

### Frontend (Flutter)
```
flutter-app/lib/
├── core/ai/
│   ├── roboflow_service.dart          # API service
│   └── roboflow_config.dart           # Configuration
├── features/settings/
│   └── roboflow_settings_page.dart    # Settings UI
└── pubspec.yaml                       # Dependencies
```

---

## 💻 5단계: 백엔드 구현

### 5.1 RoboflowService.java
```java
@Service
@Slf4j
public class RoboflowService {
    
    @Value("${roboflow.api.key}")
    private String apiKey;
    
    @Value("${roboflow.workspace}")
    private String workspace;
    
    @Value("${roboflow.project}")
    private String project;
    
    @Value("${roboflow.version}")
    private String version;
    
    private final RestTemplate restTemplate;
    
    public AIAnalysisResponse analyzeImage(MultipartFile imageFile) {
        try {
            String base64Image = encodeImageToBase64(imageFile);
            String url = String.format("https://detect.roboflow.com/%s/%s/%s?api_key=%s",
                workspace, project, version, apiKey);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            Map<String, Object> requestBody = Map.of("image", base64Image);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);
            
            ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
            
            return parseRoboflowResponse(response.getBody());
            
        } catch (Exception e) {
            log.error("Roboflow API 호출 실패", e);
            throw new RuntimeException("AI 분석 실패", e);
        }
    }
}
```

### 5.2 AIAnalysisController.java
```java
@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AIAnalysisController {
    
    private final RoboflowService roboflowService;
    
    @PostMapping("/analyze")
    public ResponseEntity<AIAnalysisResponse> analyzeImage(
            @RequestParam("image") MultipartFile imageFile) {
        
        AIAnalysisResponse response = roboflowService.analyzeImage(imageFile);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> healthCheck() {
        return ResponseEntity.ok(Map.of("status", "healthy"));
    }
}
```

---

## 📱 6단계: Flutter 구현

### 6.1 roboflow_service.dart
```dart
class RoboflowService {
  static const String baseUrl = 'http://localhost:8080/api/v1/ai';
  
  Future<AIAnalysisResponse> analyzeImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/analyze'),
    );
    
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );
    
    var response = await request.send();
    
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return AIAnalysisResponse.fromJson(json.decode(responseData));
    } else {
      throw Exception('AI 분석 실패: ${response.statusCode}');
    }
  }
}
```

### 6.2 Settings UI Integration
```dart
class RoboflowSettingsPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI 설정')),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'API Key'),
            onChanged: (value) => _updateApiKey(value),
          ),
          ElevatedButton(
            onPressed: _testConnection,
            child: Text('연결 테스트'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🧪 7단계: 테스트 및 검증

### 7.1 Python 테스트 스크립트
```python
import requests
import base64
import os
from dotenv import load_dotenv

load_dotenv()

def test_roboflow_direct():
    """Roboflow API 직접 테스트"""
    api_key = os.getenv('ROBOFLOW_API_KEY')
    workspace = os.getenv('ROBOFLOW_WORKSPACE')
    project = os.getenv('ROBOFLOW_PROJECT')
    
    with open('test_images/pothole_1.jpg', 'rb') as f:
        image_data = base64.b64encode(f.read()).decode('utf-8')
    
    url = f"https://detect.roboflow.com/{workspace}/{project}/1?api_key={api_key}"
    
    response = requests.post(url, json={"image": image_data})
    print(f"상태 코드: {response.status_code}")
    print(f"응답: {response.json()}")

def test_backend_integration():
    """백엔드 통합 테스트"""
    url = "http://localhost:8080/api/v1/ai/analyze"
    
    with open('test_images/pothole_1.jpg', 'rb') as f:
        files = {'image': f}
        response = requests.post(url, files=files)
    
    print(f"백엔드 상태 코드: {response.status_code}")
    print(f"백엔드 응답: {response.json()}")

if __name__ == "__main__":
    test_roboflow_direct()
    test_backend_integration()
```

### 7.2 실행 방법
```bash
# Python 테스트
python roboflow_test.py

# Backend 실행
cd main-api-server
java -jar build/libs/report-platform-1.0.0.jar

# Flutter 앱 실행
cd flutter-app
flutter run
```

---

## 🔧 8단계: 트러블슈팅

### 8.1 일반적인 문제 해결

#### API 키 오류
```bash
# 환경변수 확인
echo $ROBOFLOW_API_KEY

# .env 파일 확인
cat .env
```

#### 연결 오류
```bash
# 네트워크 연결 테스트
curl -X GET "https://detect.roboflow.com" -I

# 백엔드 상태 확인
curl -X GET "http://localhost:8080/api/v1/ai/health"
```

#### 이미지 업로드 문제
- 파일 크기: 최대 10MB
- 지원 형식: JPG, PNG
- 최소 해상도: 640x480

### 8.2 성능 최적화

#### API 호출 최적화
```java
@Service
public class RoboflowService {
    
    @Cacheable("ai-analysis")
    public AIAnalysisResponse analyzeImage(String imageHash) {
        // 동일한 이미지는 캐시에서 반환
    }
    
    @Async
    public CompletableFuture<AIAnalysisResponse> analyzeImageAsync(MultipartFile file) {
        // 비동기 처리
    }
}
```

---

## 📊 9단계: 모니터링 및 운영

### 9.1 API 사용량 모니터링
```java
@Component
public class RoboflowMetrics {
    
    private final MeterRegistry meterRegistry;
    private Counter apiCallCounter;
    private Timer responseTimeTimer;
    
    @EventListener
    public void handleApiCall(RoboflowApiCallEvent event) {
        apiCallCounter.increment();
        responseTimeTimer.record(event.getResponseTime(), TimeUnit.MILLISECONDS);
    }
}
```

### 9.2 로그 설정
```properties
# application.properties
logging.level.com.jeonbuk.report.service.RoboflowService=DEBUG
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n
```

---

## 🎯 10단계: 고급 기능

### 10.1 신뢰도 기반 우선순위 시스템
```java
public class PriorityCalculator {
    
    public ReportPriority calculatePriority(AIAnalysisResponse analysis) {
        double confidence = analysis.getMaxConfidence();
        String objectClass = analysis.getDetectedClass();
        
        if (confidence > 0.9 && isHighPriorityClass(objectClass)) {
            return ReportPriority.CRITICAL;
        } else if (confidence > 0.75) {
            return ReportPriority.HIGH;
        } else if (confidence > 0.5) {
            return ReportPriority.MEDIUM;
        } else {
            return ReportPriority.LOW;
        }
    }
}
```

### 10.2 부서별 자동 라우팅
```java
public class DepartmentRouter {
    
    public Department routeByObjectClass(String objectClass) {
        return switch (objectClass) {
            case "road_damage", "pothole" -> Department.ROAD_MAINTENANCE;
            case "street_light_out" -> Department.ELECTRICAL;
            case "water_leak" -> Department.WATER_WORKS;
            case "graffiti", "illegal_dumping" -> Department.ENVIRONMENTAL;
            default -> Department.GENERAL_AFFAIRS;
        };
    }
}
```

---

## 📝 11단계: 배포 체크리스트

### 11.1 프로덕션 준비사항
- [ ] API 키 보안 설정 완료
- [ ] 이미지 업로드 용량 제한 설정
- [ ] 에러 핸들링 구현
- [ ] 로깅 시스템 설정
- [ ] 모니터링 대시보드 구성
- [ ] 백업 및 복구 계획 수립

### 11.2 성능 벤치마크
- API 응답 시간: < 3초
- 일일 API 호출 한도: 1,000회 (무료 플랜)
- 이미지 처리 정확도: > 85%

---

## 🔗 관련 자료

### 공식 문서
- [Roboflow API Documentation](https://docs.roboflow.com/)
- [Spring Boot Reference](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Flutter Documentation](https://flutter.dev/docs)

### 프로젝트 관련 문서
- `API_DOCUMENTATION.md` - API 명세서
- `RUN_INSTRUCTIONS.md` - 실행 가이드
- `PROJECT_STATUS_COMPREHENSIVE.md` - 프로젝트 현황

---

## 📞 지원 및 문의

- **개발팀 연락처**: 개발팀
- **API 문서**: http://localhost:8080/swagger-ui.html
- **이슈 리포트**: GitHub Issues

---

**최종 업데이트**: 2025-07-13  
**버전**: 1.0.0  
**작성자**: 개발팀