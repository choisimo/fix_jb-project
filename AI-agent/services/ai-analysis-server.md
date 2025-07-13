# AI Analysis Server 상세 역할 및 구조

## 🎯 AI Analysis Server 개요

AI Analysis Server는 전북 신고 플랫폼의 **AI 기반 이미지 분석 및 자동 분류**를 전담하는 특화된 서비스로, ROBOFLOW API 연동, 이미지 객체 감지, 전북지역 특화 분류 로직을 제공합니다.

## 📁 프로젝트 구조

```
ai-analysis-server/
├── src/main/java/com/jeonbuk/report/
│   ├── presentation/           # 프레젠테이션 계층
│   │   └── controller/         # REST API 컨트롤러
│   │       ├── AiRoutingController.java
│   │       ├── UserController.java
│   │       └── HealthController.java
│   ├── application/           # 애플리케이션 계층
│   │   └── service/          # 비즈니스 서비스
│   │       ├── AiRoutingService.java
│   │       ├── ValidationAiAgentService.java
│   │       └── IntegratedAiAgentService.java
│   ├── service/              # 도메인 서비스
│   │   └── RoboflowService.java      # 핵심 AI 분석 서비스
│   ├── domain/               # 도메인 계층
│   │   ├── entity/           # JPA 엔티티
│   │   └── repository/       # 레포지토리 인터페이스
│   ├── infrastructure/       # 인프라 계층
│   │   ├── config/           # 설정 클래스
│   │   │   ├── AsyncConfig.java
│   │   │   └── SecurityConfig.java
│   │   └── external/         # 외부 API 연동
│   │       └── roboflow/     # Roboflow API 전용
│   │           ├── RoboflowApiClient.java
│   │           ├── RoboflowDto.java
│   │           └── RoboflowException.java
│   ├── dto/                  # 데이터 전송 객체
│   │   ├── AIAnalysisRequest.java
│   │   ├── AIAnalysisResponse.java
│   │   └── DetectedObjectDto.java
│   └── config/               # 설정 클래스
│       ├── RestClientConfig.java
│       └── SecurityConfig.java
└── src/main/resources/
    ├── application.yml       # AI 서버 전용 설정
    └── static/              # 정적 리소스
```

## 🔧 핵심 기능 및 책임

### 1. 이미지 분석 엔진 (RoboflowService.java)

#### 주요 기능
```java
// 동기 이미지 분석
public AIAnalysisResponse analyzeImage(AIAnalysisRequest request)

// 비동기 이미지 분석
public void analyzeImageAsync(AIAnalysisRequest request)

// 배치 이미지 분석 (병렬 처리)
public List<AIAnalysisResponse> analyzeBatchImages(MultipartFile[] images, Integer confidence, Integer overlap)

// 테스트 시나리오 분석
public AIAnalysisResponse analyzeTestScenario(String scenario, MultipartFile image)

// 서비스 상태 확인
public boolean checkHealth()
```

#### 전북지역 특화 설정
```java
// 한국어 클래스명 매핑
private final Map<String, String> koreanClassNames = Map.ofEntries(
    // 도로 관련 문제
    Map.entry("pothole", "포트홀"),
    Map.entry("crack", "균열"),
    Map.entry("damaged_road", "도로 손상"),
    Map.entry("road_marking_faded", "차선 도색 훼손"),
    
    // 시설물 관련 문제  
    Map.entry("broken_manhole", "맨홀 파손"),
    Map.entry("damaged_sign", "표지판 손상"),
    Map.entry("broken_streetlight", "가로등 파손"),
    Map.entry("damaged_guardrail", "가드레일 손상"),
    
    // 환경 관리 문제
    Map.entry("litter", "쓰레기"),
    Map.entry("graffiti", "낙서"),
    Map.entry("illegal_dumping", "불법 투기")
);

// 문제 유형별 카테고리 매핑
private final Map<String, String> categoryMapping = Map.ofEntries(
    Map.entry("pothole", "도로관리"),
    Map.entry("broken_manhole", "시설관리"),
    Map.entry("litter", "환경관리"),
    Map.entry("damaged_guardrail", "안전관리"),
    Map.entry("damaged_bus_stop", "교통관리")
);

// 우선순위 매핑 (기본 우선순위)
private final Map<String, String> priorityMapping = Map.ofEntries(
    Map.entry("pothole", "긴급"),
    Map.entry("damaged_road", "긴급"),
    Map.entry("broken_manhole", "긴급"),
    Map.entry("damaged_guardrail", "긴급"),
    Map.entry("crack", "보통"),
    Map.entry("litter", "낮음")
);
```

### 2. AI 라우팅 컨트롤러 (AiRoutingController.java)

#### 주요 엔드포인트
```java
// 동기 이미지 분석
POST   /api/v1/analyze
{
    "image": "MultipartFile",
    "confidence": 50,
    "overlap": 30,
    "jobId": "optional-job-id"
}

// 비동기 이미지 분석 시작
POST   /api/v1/analyze/async
{
    "image": "MultipartFile",
    "confidence": 70,
    "overlap": 25,
    "jobId": "required-job-id"
}

// 비동기 분석 결과 조회
GET    /api/v1/analyze/result/{jobId}

// 배치 이미지 분석
POST   /api/v1/analyze/batch
Content-Type: multipart/form-data
images: MultipartFile[]
confidence: 60
overlap: 30

// 테스트 시나리오 분석
POST   /api/v1/test/{scenario}
{
    "image": "MultipartFile (optional)"
}

// AI 서비스 상태 확인
GET    /api/v1/health

// 지원 클래스 목록 조회
GET    /api/v1/classes

// 성능 메트릭 조회
GET    /api/v1/metrics
```

### 3. ROBOFLOW API 클라이언트 (RoboflowApiClient.java)

#### 핵심 기능
```java
// 비동기 단일 이미지 분석
public CompletableFuture<RoboflowAnalysisResult> analyzeImageAsync(String imageData, String modelId) {
    return CompletableFuture.supplyAsync(() -> {
        // 백그라운드 스레드풀에서 실행
        return analyzeImage(imageData, modelId);
    }, executor);
}

// 재시도 및 복구 로직
@Retryable(retryFor = {ResourceAccessException.class, HttpServerErrorException.class}, 
           maxAttempts = 3, 
           backoff = @Backoff(delay = 1000, multiplier = 2))
private RoboflowAnalysisResult analyzeImage(String imageData, String modelId) {
    // API 호출 로직
}

@Recover
private RoboflowAnalysisResult recoverFromRoboflowError(Exception ex, String imageData, String modelId) {
    // 재시도 실패 시 기본값 반환
    return new RoboflowAnalysisResult(/* 기본값 */);
}
```

#### API 통신 설정
```java
// API URL 구성
private String buildApiUrl(Integer confidence, Integer overlap) {
    double confidenceValue = confidence != null ? confidence / 100.0 : 0.5;
    double overlapValue = overlap != null ? overlap / 100.0 : 0.3;
    
    return String.format("%s/%s/%s/%s?api_key=%s&confidence=%.2f&overlap=%.2f",
        baseApiUrl, workspace, project, version, apiKey, confidenceValue, overlapValue);
}

// HTTP 헤더 설정
private HttpHeaders createHeaders() {
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.MULTIPART_FORM_DATA);
    headers.set("User-Agent", "Jeonbuk-FieldReport/2.0.1");
    return headers;
}
```

### 4. 고급 오류 처리 및 성능 최적화

#### Circuit Breaker 패턴
```java
// Circuit breaker 상태 관리
private volatile boolean circuitBreakerOpen = false;
private volatile long lastFailureTime = 0;
private static final long CIRCUIT_BREAKER_TIMEOUT = 60000; // 1분

private boolean isCircuitBreakerOpen() {
    if (!circuitBreakerOpen) return false;
    
    // 타임아웃 후 half-open 상태로 전환
    if (System.currentTimeMillis() - lastFailureTime > CIRCUIT_BREAKER_TIMEOUT) {
        circuitBreakerOpen = false;
        log.info("🔄 Circuit breaker half-open 상태로 전환");
    }
    return circuitBreakerOpen;
}

private void triggerCircuitBreaker() {
    circuitBreakerOpen = true;
    lastFailureTime = System.currentTimeMillis();
    log.warn("⚡ Circuit breaker 활성화");
}
```

#### 병렬 배치 처리
```java
public List<AIAnalysisResponse> analyzeBatchImages(MultipartFile[] images, Integer confidence, Integer overlap) {
    List<AIAnalysisResponse> results = Collections.synchronizedList(new ArrayList<>());
    
    // 병렬 처리를 위한 스트림 사용
    Arrays.stream(images)
        .parallel()
        .forEach(image -> {
            try {
                AIAnalysisRequest request = AIAnalysisRequest.builder()
                    .image(image)
                    .confidence(confidence)
                    .overlap(overlap)
                    .build();
                
                AIAnalysisResponse result = analyzeImage(request);
                results.add(result);
                
            } catch (Exception e) {
                log.error("❌ 배치 분석 중 오류 - 파일: {}", image.getOriginalFilename(), e);
                results.add(buildErrorResponse("파일 분석 실패: " + e.getMessage(), 0L));
            }
        });
    
    return results;
}
```

#### 성능 메트릭 수집
```java
// 성능 메트릭 기록
private void recordPerformanceMetrics(String operation, long duration) {
    performanceMetrics.put(operation + "_last_duration", duration);
    performanceMetrics.put(operation + "_count", 
        performanceMetrics.getOrDefault(operation + "_count", 0L) + 1);
    
    // 평균 계산
    String avgKey = operation + "_avg_duration";
    long currentAvg = performanceMetrics.getOrDefault(avgKey, 0L);
    long count = performanceMetrics.get(operation + "_count");
    long newAvg = (currentAvg * (count - 1) + duration) / count;
    performanceMetrics.put(avgKey, newAvg);
}

// 성능 메트릭 조회
public Map<String, Object> getPerformanceMetrics() {
    Map<String, Object> metrics = new HashMap<>();
    metrics.put("circuit_breaker_status", circuitBreakerOpen ? "OPEN" : "CLOSED");
    metrics.put("performance_data", new HashMap<>(performanceMetrics));
    metrics.put("async_jobs_count", asyncResults.size());
    return metrics;
}
```

### 5. 테스트 및 모킹 기능

#### 테스트 시나리오 지원
```java
public AIAnalysisResponse analyzeTestScenario(String scenario, MultipartFile image) {
    switch (scenario) {
        case "도로 파손":
            return createMockResponse("pothole", 0.85, startTime, 
                "도로에 포트홀이 감지되었습니다. 즉시 보수가 필요합니다.");
                
        case "환경 문제":
            return createMockResponse("litter", 0.72, startTime, 
                "쓰레기가 발견되었습니다. 환경 정리가 필요합니다.");
                
        case "시설물 파손":
            return createMockResponse("broken_streetlight", 0.78, startTime, 
                "가로등 손상이 감지되었습니다. 안전상 점검이 필요합니다.");
                
        case "복합 문제":
            return createMockComplexResponse(startTime, 
                "여러 종류의 인프라 문제가 함께 발견되었습니다.");
    }
}

// 복합 문제 모의 응답 생성
private AIAnalysisResponse createMockComplexResponse(long startTime, String description) {
    List<DetectedObjectDto> detections = List.of(
        DetectedObjectDto.builder()
            .className("pothole")
            .koreanName("포트홀")
            .confidence(82.5)
            .priority(Report.Priority.URGENT)
            .build(),
        DetectedObjectDto.builder()
            .className("litter")
            .koreanName("쓰레기")
            .confidence(75.3)
            .priority(Report.Priority.LOW)
            .build()
    );
    
    return AIAnalysisResponse.builder()
        .success(true)
        .detections(detections)
        .averageConfidence(75.5)
        .recommendedPriority(Report.Priority.URGENT)
        .summary(description + " 총 2개 문제: 포트홀 1개, 쓰레기 1개")
        .build();
}
```

### 6. 응답 데이터 구조

#### AIAnalysisResponse.java
```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AIAnalysisResponse {
    private Boolean success;
    private List<DetectedObjectDto> detections;
    private Double averageConfidence;
    private Long processingTime;
    private LocalDateTime timestamp;
    private String jobId;
    
    // 추천 정보
    private ReportCategory recommendedCategory;
    private Report.Priority recommendedPriority;
    private String recommendedDepartment;
    private String summary;
    
    // 오류 정보
    private String errorMessage;
    
    // 원시 응답 (디버깅용)
    private JsonNode rawResponse;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DetectedObjectDto {
    private String className;          // 영문 클래스명
    private String koreanName;         // 한국어 클래스명
    private Double confidence;         // 신뢰도 (0-100)
    private BoundingBoxDto boundingBox; // 바운딩 박스
    private ReportCategory category;   // 추천 카테고리
    private Report.Priority priority;  // 추천 우선순위
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BoundingBoxDto {
        private Double x;      // 중심점 X 좌표
        private Double y;      // 중심점 Y 좌표
        private Double width;  // 너비
        private Double height; // 높이
    }
}
```

### 7. 설정 및 환경

#### application.yml (AI Analysis Server 전용)
```yaml
# AI Analysis Server 전용 설정
server:
  port: ${SERVER_PORT:8081}
  servlet:
    context-path: /api/v1

# Roboflow 설정
roboflow:
  api:
    key: ${ROBOFLOW_API_KEY:your-roboflow-api-key}
    url: https://detect.roboflow.com
  workspace: ${ROBOFLOW_WORKSPACE:your-workspace}
  project: ${ROBOFLOW_PROJECT:your-project}
  version: 1
  timeout:
    connection: 30000
    read: 60000

# JPA 설정 (데이터 공유용)
spring:
  jpa:
    hibernate:
      ddl-auto: create-drop  # AI 서버는 독립적 스키마
    show-sql: ${SHOW_SQL:true}
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
```

### 8. 비동기 작업 관리

#### 작업 결과 저장소
```java
// 비동기 작업 결과 저장소 (실제 환경에서는 Redis 사용 권장)
private final Map<String, AIAnalysisResponse> asyncResults = new ConcurrentHashMap<>();

public void analyzeImageAsync(AIAnalysisRequest request) {
    String jobId = request.getJobId();
    
    CompletableFuture.supplyAsync(() -> {
        try {
            log.info("🔄 비동기 분석 시작 - Job ID: {}", jobId);
            
            AIAnalysisResponse result = analyzeImage(request);
            result.setJobId(jobId);
            
            // 결과 저장
            asyncResults.put(jobId, result);
            
            log.info("✅ 비동기 분석 완료 - Job ID: {}", jobId);
            return result;
            
        } catch (Exception e) {
            log.error("❌ 비동기 분석 실패 - Job ID: {}", jobId, e);
            
            AIAnalysisResponse errorResult = buildErrorResponse(e.getMessage(), 0L);
            errorResult.setJobId(jobId);
            asyncResults.put(jobId, errorResult);
            
            return errorResult;
        }
    });
}

public AIAnalysisResponse getAnalysisResult(String jobId) {
    AIAnalysisResponse result = asyncResults.get(jobId);
    if (result == null) {
        throw new RuntimeException("작업을 찾을 수 없습니다: " + jobId);
    }
    return result;
}
```

---

*문서 버전: 1.0*  
*최종 업데이트: 2025년 7월 12일*  
*작성자: AI Analysis Server 개발팀*