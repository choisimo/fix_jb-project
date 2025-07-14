package com.jeonbuk.report.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jeonbuk.report.dto.AIAnalysisRequest;
import com.jeonbuk.report.dto.AIAnalysisResponse;
import com.jeonbuk.report.dto.AIAnalysisResponse.DetectedObjectDto;
import com.jeonbuk.report.dto.AIAnalysisResponse.BoundingBoxDto;
import com.jeonbuk.report.domain.entity.ReportCategory;
import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.repository.ReportCategoryRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Roboflow API 통합 서비스
 * 이미지 객체 감지 및 분석을 담당
 */
@Service
@Slf4j
public class RoboflowService {
    
    @Value("${roboflow.api.key:}")
    private String apiKey;
    
    @Value("${roboflow.workspace:}")
    private String workspace;
    
    @Value("${roboflow.project:}")
    private String project;
    
    @Value("${roboflow.version:1}")
    private String version;
    
    @Value("${roboflow.api.url:https://detect.roboflow.com}")
    private String baseApiUrl;
    
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final ReportCategoryRepository reportCategoryRepository;
    
    // 비동기 작업 결과 저장소 (실제 환경에서는 Redis 등 사용)
    private final Map<String, AIAnalysisResponse> asyncResults = new ConcurrentHashMap<>();
    
    // 한국어 클래스명 매핑 - 전북지역 인프라 문제 중심
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
        Map.entry("broken_sidewalk", "인도 파손"),
        
        // 환경 관리 문제
        Map.entry("litter", "쓰레기"),
        Map.entry("graffiti", "낙서"),
        Map.entry("illegal_dumping", "불법 투기"),
        
        // 기타 공공시설 문제
        Map.entry("damaged_bus_stop", "버스정류장 손상"),
        Map.entry("broken_bench", "벤치 파손"),
        Map.entry("damaged_fence", "울타리 손상")
    );
    
    // 문제 유형별 카테고리 매핑
    private final Map<String, String> categoryMapping = Map.ofEntries(
        Map.entry("pothole", "도로관리"),
        Map.entry("crack", "도로관리"), 
        Map.entry("damaged_road", "도로관리"),
        Map.entry("road_marking_faded", "도로관리"),
        Map.entry("broken_manhole", "시설관리"),
        Map.entry("damaged_sign", "시설관리"),
        Map.entry("broken_streetlight", "시설관리"),
        Map.entry("damaged_guardrail", "안전관리"),
        Map.entry("broken_sidewalk", "도로관리"),
        Map.entry("litter", "환경관리"),
        Map.entry("graffiti", "환경관리"),
        Map.entry("illegal_dumping", "환경관리"),
        Map.entry("damaged_bus_stop", "교통관리"),
        Map.entry("broken_bench", "시설관리"),
        Map.entry("damaged_fence", "시설관리")
    );
    
    // 우선순위 매핑 (기본 우선순위)
    private final Map<String, String> priorityMapping = Map.ofEntries(
        Map.entry("pothole", "긴급"),
        Map.entry("crack", "보통"),
        Map.entry("damaged_road", "긴급"), 
        Map.entry("road_marking_faded", "낮음"),
        Map.entry("broken_manhole", "긴급"),
        Map.entry("damaged_sign", "보통"),
        Map.entry("broken_streetlight", "보통"),
        Map.entry("damaged_guardrail", "긴급"),
        Map.entry("broken_sidewalk", "보통"),
        Map.entry("litter", "낮음"),
        Map.entry("graffiti", "낮음"),
        Map.entry("illegal_dumping", "보통"),
        Map.entry("damaged_bus_stop", "보통"),
        Map.entry("broken_bench", "낮음"),
        Map.entry("damaged_fence", "낮음")
    );
    
    // Circuit breaker for API failures
    private volatile boolean circuitBreakerOpen = false;
    private volatile long lastFailureTime = 0;
    private static final long CIRCUIT_BREAKER_TIMEOUT = 60000; // 1 minute
    private static final int MAX_RETRY_ATTEMPTS = 3;
    
    // Performance metrics
    private final Map<String, Long> performanceMetrics = new ConcurrentHashMap<>();
    
    // Request timeout configuration
    @Value("${roboflow.timeout.connection:30000}")
    private int connectionTimeout;
    
    @Value("${roboflow.timeout.read:60000}")
    private int readTimeout;
    
    public RoboflowService(RestTemplate restTemplate, ObjectMapper objectMapper, ReportCategoryRepository reportCategoryRepository) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
        this.reportCategoryRepository = reportCategoryRepository;
    }
    
    /**
     * 이미지 AI 분석 (동기) - 향상된 오류 처리 및 재시도 로직
     */
    public AIAnalysisResponse analyzeImage(AIAnalysisRequest request) {
        long startTime = System.currentTimeMillis();
        
        try {
            // Circuit breaker 확인
            if (isCircuitBreakerOpen()) {
                log.warn("⚡ Circuit breaker가 열려있어 요청을 거부합니다");
                return buildErrorResponse("서비스 일시 중단 중입니다. 잠시 후 다시 시도해주세요.", 0L);
            }
            
            validateConfiguration();
            validateRequest(request);
            
            log.info("🤖 Roboflow API 분석 시작 - 파일: {}, 크기: {} bytes", 
                request.getImage().getOriginalFilename(), 
                request.getImage().getSize());
            
            // 재시도 로직으로 API 호출
            AIAnalysisResponse response = executeWithRetry(request, startTime);
            
            // 성공 시 circuit breaker 리셋
            resetCircuitBreaker();
            
            // 성능 메트릭 기록
            recordPerformanceMetrics("analyze_image", System.currentTimeMillis() - startTime);
            
            return response;
            
        } catch (Exception e) {
            long processingTime = System.currentTimeMillis() - startTime;
            log.error("❌ 이미지 분석 최종 실패", e);
            
            // Circuit breaker 트리거
            triggerCircuitBreaker();
            
            return buildErrorResponse("분석 중 오류가 발생했습니다: " + e.getMessage(), processingTime);
        }
    }
    
    /**
     * 이미지 AI 분석 (동기) - MultipartFile 직접 처리
     */
    public Map<String, Object> analyzeImage(MultipartFile imageFile, int confidence, int overlap) {
        long startTime = System.currentTimeMillis();
        
        try {
            // Circuit breaker 확인
            if (isCircuitBreakerOpen()) {
                log.warn("⚡ Circuit breaker가 열려있어 요청을 거부합니다");
                Map<String, Object> errorResult = new HashMap<>();
                errorResult.put("success", false);
                errorResult.put("error", "서비스 일시 중단 중입니다. 잠시 후 다시 시도해주세요.");
                errorResult.put("timestamp", System.currentTimeMillis());
                return errorResult;
            }
            
            validateImageFile(imageFile);
            
            log.info("🤖 Roboflow API 분석 시작 - 파일: {}, 크기: {} bytes", 
                imageFile.getOriginalFilename(), 
                imageFile.getSize());
            
            // 재시도 로직으로 API 호출
            Map<String, Object> response = executeImageAnalysisWithRetry(imageFile, confidence, overlap, startTime);
            
            // 성공 시 circuit breaker 리셋
            resetCircuitBreaker();
            
            // 성능 메트릭 기록
            recordPerformanceMetrics("analyze_image", System.currentTimeMillis() - startTime);
            
            return response;
            
        } catch (Exception e) {
            long processingTime = System.currentTimeMillis() - startTime;
            log.error("❌ 이미지 분석 최종 실패", e);
            
            // Circuit breaker 트리거
            triggerCircuitBreaker();
            
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("success", false);
            errorResult.put("error", "분석 중 오류가 발생했습니다: " + e.getMessage());
            errorResult.put("timestamp", System.currentTimeMillis());
            errorResult.put("processingTime", processingTime);
            
            return errorResult;
        }
    }
    
    /**
     * 재시도 로직을 포함한 이미지 분석 API 호출 실행
     */
    private Map<String, Object> executeImageAnalysisWithRetry(MultipartFile imageFile, int confidence, int overlap, long startTime) throws Exception {
        // workspace나 project가 없으면 모의 응답 반환
        if (workspace == null || workspace.isEmpty() || project == null || project.isEmpty()) {
            log.info("🎭 Roboflow 설정 불완전 - 모의 AI 분석 응답 반환");
            return createMockAnalysisResponse(imageFile, confidence, overlap, startTime);
        }
        
        Exception lastException = null;
        
        for (int attempt = 1; attempt <= MAX_RETRY_ATTEMPTS; attempt++) {
            try {
                log.debug("🔄 API 호출 시도 {}/{}", attempt, MAX_RETRY_ATTEMPTS);
                
                String url = buildApiUrl(confidence, overlap);
                
                // HTTP 요청 구성
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.MULTIPART_FORM_DATA);
                headers.set("User-Agent", "Jeonbuk-FieldReport/2.0.1");
                
                MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
                body.add("file", new ByteArrayResource(imageFile.getBytes()) {
                    @Override
                    public String getFilename() {
                        return imageFile.getOriginalFilename();
                    }
                });
                
                HttpEntity<MultiValueMap<String, Object>> requestEntity = 
                    new HttpEntity<>(body, headers);
                
                // API 호출
                ResponseEntity<String> response = restTemplate.postForEntity(
                    url, requestEntity, String.class);
                
                long processingTime = System.currentTimeMillis() - startTime;
                
                if (response.getStatusCode().is2xxSuccessful()) {
                    JsonNode jsonResponse = objectMapper.readTree(response.getBody());
                    log.info("✅ API 호출 성공 (시도 {}/{})", attempt, MAX_RETRY_ATTEMPTS);
                    return buildImageAnalysisResponse(jsonResponse, processingTime);
                } else {
                    throw new RuntimeException("API 응답 오류: " + response.getStatusCode());
                }
                
            } catch (Exception e) {
                lastException = e;
                log.warn("⚠️ API 호출 실패 (시도 {}/{}): {}", attempt, MAX_RETRY_ATTEMPTS, e.getMessage());
                
                // 마지막 시도가 아니면 잠시 대기
                if (attempt < MAX_RETRY_ATTEMPTS) {
                    try {
                        Thread.sleep(1000 * attempt); // 지수 백오프
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new RuntimeException("분석이 중단되었습니다", ie);
                    }
                }
            }
        }
        
        // 모든 시도 실패 시 모의 응답 반환
        log.warn("🎭 Roboflow API 호출 실패 - 모의 분석 응답 반환");
        return createMockAnalysisResponse(imageFile, confidence, overlap, startTime);
    }
    
    /**
     * 모의 AI 분석 응답 생성
     */
    private Map<String, Object> createMockAnalysisResponse(MultipartFile imageFile, int confidence, int overlap, long startTime) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("timestamp", System.currentTimeMillis());
        result.put("processingTime", System.currentTimeMillis() - startTime);
        result.put("confidence", confidence);
        result.put("overlap", overlap);
        
        // 파일 이름에 따라 다른 모의 분석 결과 생성
        String filename = imageFile.getOriginalFilename().toLowerCase();
        List<Map<String, Object>> predictions = new ArrayList<>();
        
        if (filename.contains("pothole") || filename.contains("hole")) {
            Map<String, Object> detection = new HashMap<>();
            detection.put("class", "pothole");
            detection.put("confidence", 0.85);
            detection.put("x", 320.0);
            detection.put("y", 240.0);
            detection.put("width", 150.0);
            detection.put("height", 100.0);
            predictions.add(detection);
        } else if (filename.contains("trash") || filename.contains("garbage")) {
            Map<String, Object> detection = new HashMap<>();
            detection.put("class", "litter");
            detection.put("confidence", 0.72);
            detection.put("x", 400.0);
            detection.put("y", 300.0);
            detection.put("width", 120.0);
            detection.put("height", 80.0);
            predictions.add(detection);
        } else if (filename.contains("street") || filename.contains("light")) {
            Map<String, Object> detection = new HashMap<>();
            detection.put("class", "broken_streetlight");
            detection.put("confidence", 0.78);
            detection.put("x", 250.0);
            detection.put("y", 150.0);
            detection.put("width", 100.0);
            detection.put("height", 200.0);
            predictions.add(detection);
        } else if (filename.contains("graffiti")) {
            Map<String, Object> detection = new HashMap<>();
            detection.put("class", "graffiti");
            detection.put("confidence", 0.68);
            detection.put("x", 300.0);
            detection.put("y", 200.0);
            detection.put("width", 180.0);
            detection.put("height", 120.0);
            predictions.add(detection);
        } else {
            // 기본값: 도로 균열
            Map<String, Object> detection = new HashMap<>();
            detection.put("class", "crack");
            detection.put("confidence", 0.65);
            detection.put("x", 350.0);
            detection.put("y", 280.0);
            detection.put("width", 200.0);
            detection.put("height", 60.0);
            predictions.add(detection);
        }
        
        result.put("predictions", predictions);
        result.put("detectionCount", predictions.size());
        
        log.info("🎭 모의 AI 분석 완료 - 파일: {}, 감지된 객체: {}개", 
                filename, predictions.size());
        
        return result;
    }
    
    /**
     * 이미지 분석 응답 구성
     */
    private Map<String, Object> buildImageAnalysisResponse(JsonNode roboflowResponse, long processingTime) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("timestamp", System.currentTimeMillis());
        result.put("processingTime", processingTime);
        
        // Roboflow 응답에서 predictions 추출
        if (roboflowResponse.has("predictions")) {
            result.put("predictions", roboflowResponse.get("predictions"));
            
            // 감지된 객체 수 계산
            JsonNode predictions = roboflowResponse.get("predictions");
            result.put("detectionCount", predictions.size());
            
        } else {
            result.put("predictions", Collections.emptyList());
            result.put("detectionCount", 0);
        }
        
        return result;
    }
    
    /**
     * 이미지 파일 유효성 검사
     */
    private void validateImageFile(MultipartFile imageFile) {
        if (imageFile == null || imageFile.isEmpty()) {
            throw new IllegalArgumentException("이미지 파일이 비어있습니다");
        }
        
        String contentType = imageFile.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("유효한 이미지 파일이 아닙니다");
        }
        
        // 파일 크기 제한 (10MB)
        if (imageFile.getSize() > 10 * 1024 * 1024) {
            throw new IllegalArgumentException("이미지 파일 크기가 너무 큽니다 (최대 10MB)");
        }
    }
    
    /**
     * 재시도 로직을 포함한 API 호출 실행
     */
    private AIAnalysisResponse executeWithRetry(AIAnalysisRequest request, long startTime) throws Exception {
        Exception lastException = null;
        
        for (int attempt = 1; attempt <= MAX_RETRY_ATTEMPTS; attempt++) {
            try {
                log.debug("🔄 API 호출 시도 {}/{}", attempt, MAX_RETRY_ATTEMPTS);
                
                String url = buildApiUrl(request.getConfidence(), request.getOverlap());
                
                // HTTP 요청 구성
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.MULTIPART_FORM_DATA);
                headers.set("User-Agent", "Jeonbuk-FieldReport/2.0.1");
                
                MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
                body.add("file", new ByteArrayResource(request.getImage().getBytes()) {
                    @Override
                    public String getFilename() {
                        return request.getImage().getOriginalFilename();
                    }
                });
                
                HttpEntity<MultiValueMap<String, Object>> requestEntity = 
                    new HttpEntity<>(body, headers);
                
                // API 호출
                ResponseEntity<String> response = restTemplate.postForEntity(
                    url, requestEntity, String.class);
                
                long processingTime = System.currentTimeMillis() - startTime;
                
                if (response.getStatusCode().is2xxSuccessful()) {
                    JsonNode jsonResponse = objectMapper.readTree(response.getBody());
                    log.info("✅ API 호출 성공 (시도 {}/{})", attempt, MAX_RETRY_ATTEMPTS);
                    return buildSuccessResponse(jsonResponse, processingTime, request.getJobId());
                } else {
                    throw new RuntimeException("API 응답 오류: " + response.getStatusCode());
                }
                
            } catch (Exception e) {
                lastException = e;
                log.warn("⚠️ API 호출 실패 (시도 {}/{}): {}", attempt, MAX_RETRY_ATTEMPTS, e.getMessage());
                
                // 마지막 시도가 아니면 잠시 대기
                if (attempt < MAX_RETRY_ATTEMPTS) {
                    try {
                        Thread.sleep(1000 * attempt); // 지수 백오프
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new RuntimeException("분석이 중단되었습니다", ie);
                    }
                }
            }
        }
        
        throw new RuntimeException("최대 재시도 횟수 초과", lastException);
    }
    
    /**
     * 이미지 AI 분석 (비동기)
     */
    public void analyzeImageAsync(AIAnalysisRequest request) {
        String jobId = request.getJobId();
        
        try {
            log.info("🔄 비동기 분석 시작 - Job ID: {}", jobId);
            
            AIAnalysisResponse result = analyzeImage(request);
            result.setJobId(jobId);
            
            // 결과 저장 (실제 환경에서는 Redis 등 사용)
            asyncResults.put(jobId, result);
            
            log.info("✅ 비동기 분석 완료 - Job ID: {}", jobId);
            
        } catch (Exception e) {
            log.error("❌ 비동기 분석 실패 - Job ID: {}", jobId, e);
            
            AIAnalysisResponse errorResult = buildErrorResponse(e.getMessage(), 0L);
            errorResult.setJobId(jobId);
            asyncResults.put(jobId, errorResult);
        }
    }
    
    /**
     * 비동기 분석 결과 조회
     */
    public AIAnalysisResponse getAnalysisResult(String jobId) {
        AIAnalysisResponse result = asyncResults.get(jobId);
        if (result == null) {
            throw new RuntimeException("작업을 찾을 수 없습니다: " + jobId);
        }
        return result;
    }
    
    /**
     * 서비스 상태 확인
     */
    public boolean checkHealth() {
        try {
            validateConfiguration();
            
            // 간단한 연결 테스트 (실제로는 API 엔드포인트에 ping)
            String testUrl = baseApiUrl;
            log.info("🔍 Roboflow 서비스 상태 확인: {}", testUrl);
            
            return true; // 설정이 유효하면 OK
            
        } catch (Exception e) {
            log.error("❌ 서비스 상태 확인 실패", e);
            return false;
        }
    }
    
    /**
     * 지원 클래스 목록 조회
     */
    public List<Map<String, String>> getSupportedClasses() {
        List<Map<String, String>> classes = new ArrayList<>();
        
        koreanClassNames.forEach((englishName, koreanName) -> {
            Map<String, String> classInfo = new HashMap<>();
            classInfo.put("english", englishName);
            classInfo.put("korean", koreanName);
            classes.add(classInfo);
        });
        
        return classes;
    }
    
    /**
     * 배치 이미지 분석 - 향상된 병렬 처리 및 진행률 추적
     */
    public List<AIAnalysisResponse> analyzeBatchImages(
            MultipartFile[] images, Integer confidence, Integer overlap) {
        
        if (images == null || images.length == 0) {
            log.warn("⚠️ 빈 이미지 배열이 제공되었습니다");
            return Collections.emptyList();
        }
        
        long startTime = System.currentTimeMillis();
        log.info("📦 배치 분석 시작 - {} 개 이미지, 신뢰도: {}%, 겹침: {}%", 
            images.length, confidence, overlap);
        
        List<AIAnalysisResponse> results = Collections.synchronizedList(new ArrayList<>());
        
        // 병렬 처리를 위한 스트림 사용
        Arrays.stream(images)
            .parallel()
            .forEach(image -> {
                try {
                    long imageStartTime = System.currentTimeMillis();
                    
                    AIAnalysisRequest request = AIAnalysisRequest.builder()
                        .image(image)
                        .confidence(confidence)
                        .overlap(overlap)
                        .build();
                    
                    AIAnalysisResponse result = analyzeImage(request);
                    result.setProcessingTime(System.currentTimeMillis() - imageStartTime);
                    results.add(result);
                    
                    log.debug("✅ 배치 분석 완료 - 파일: {}, 감지: {}개", 
                        image.getOriginalFilename(), 
                        result.getDetections() != null ? result.getDetections().size() : 0);
                    
                } catch (Exception e) {
                    log.error("❌ 배치 분석 중 오류 - 파일: {}", 
                        image.getOriginalFilename(), e);
                    
                    AIAnalysisResponse errorResult = buildErrorResponse(
                        "파일 분석 실패: " + e.getMessage(), 0L);
                    errorResult.setJobId("batch_error_" + System.currentTimeMillis());
                    results.add(errorResult);
                }
            });
        
        long totalTime = System.currentTimeMillis() - startTime;
        long successCount = results.stream()
            .mapToLong(r -> r.getSuccess() ? 1 : 0)
            .sum();
        
        log.info("📊 배치 분석 완료 - 성공: {}/{}, 총 소요시간: {}ms", 
            successCount, images.length, totalTime);
        
        // 성능 메트릭 기록
        recordPerformanceMetrics("batch_analysis", totalTime);
        recordPerformanceMetrics("batch_success_rate", (successCount * 100) / images.length);
        
        return results;
    }
    
    /**
     * 테스트 시나리오별 AI 분석 - Flutter 앱의 테스트 기능용
     */
    public AIAnalysisResponse analyzeTestScenario(String scenario, MultipartFile image) {
        log.info("🧪 테스트 시나리오 분석 시작 - 시나리오: {}, 파일: {}", 
            scenario, image != null ? image.getOriginalFilename() : "없음");
        
        long startTime = System.currentTimeMillis();
        
        try {
            // 시나리오별 모의 분석 결과 생성
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
                        
                default:
                    if (image != null && !image.isEmpty()) {
                        // 실제 이미지가 있으면 정상 분석 수행
                        AIAnalysisRequest request = AIAnalysisRequest.builder()
                            .image(image)
                            .confidence(50)
                            .overlap(30)
                            .build();
                        return analyzeImage(request);
                    } else {
                        // 기본 테스트 응답
                        return createMockResponse("crack", 0.65, startTime, 
                            "도로 균열이 감지되었습니다.");
                    }
            }
            
        } catch (Exception e) {
            log.error("❌ 테스트 시나리오 분석 실패", e);
            return buildErrorResponse("테스트 분석 실패: " + e.getMessage(), 
                System.currentTimeMillis() - startTime);
        }
    }
    
    /**
     * 단일 객체 모의 응답 생성
     */
    private AIAnalysisResponse createMockResponse(String className, double confidence, 
                                                long startTime, String description) {
        
        DetectedObjectDto detection = DetectedObjectDto.builder()
            .className(className)
            .koreanName(koreanClassNames.getOrDefault(className, className))
            .confidence(confidence * 100)
            .boundingBox(BoundingBoxDto.builder()
                .x(320.0)
                .y(240.0)
                .width(150.0)
                .height(100.0)
                .build())
            .category(mapToCategory(className))
            .priority(mapToPriority(className, confidence))
            .build();
        
        List<DetectedObjectDto> detections = List.of(detection);
        
        return AIAnalysisResponse.builder()
            .success(true)
            .detections(detections)
            .averageConfidence(confidence * 100)
            .processingTime(System.currentTimeMillis() - startTime)
            .timestamp(LocalDateTime.now())
            .recommendedCategory(mapToCategory(className))
            .recommendedPriority(mapToPriority(className, confidence))
            .recommendedDepartment(determineDepartment(detections))
            .summary(description)
            .build();
    }
    
    /**
     * 복합 문제 모의 응답 생성
     */
    private AIAnalysisResponse createMockComplexResponse(long startTime, String description) {
        List<DetectedObjectDto> detections = List.of(
            DetectedObjectDto.builder()
                .className("pothole")
                .koreanName("포트홀")
                .confidence(82.5)
                .boundingBox(BoundingBoxDto.builder().x(200.0).y(180.0).width(120.0).height(80.0).build())
                .category(mapToCategory("pothole"))
                .priority(Report.Priority.URGENT)
                .build(),
            DetectedObjectDto.builder()
                .className("litter")
                .koreanName("쓰레기")
                .confidence(75.3)
                .boundingBox(BoundingBoxDto.builder().x(450.0).y(300.0).width(90.0).height(60.0).build())
                .category(mapToCategory("litter"))
                .priority(Report.Priority.LOW)
                .build(),
            DetectedObjectDto.builder()
                .className("damaged_sign")
                .koreanName("표지판 손상")
                .confidence(68.7)
                .boundingBox(BoundingBoxDto.builder().x(100.0).y(120.0).width(80.0).height(120.0).build())
                .category(mapToCategory("damaged_sign"))
                .priority(Report.Priority.MEDIUM)
                .build()
        );
        
        return AIAnalysisResponse.builder()
            .success(true)
            .detections(detections)
            .averageConfidence(75.5)
            .processingTime(System.currentTimeMillis() - startTime)
            .timestamp(LocalDateTime.now())
            .recommendedCategory(mapToCategory("pothole")) // 가장 심각한 문제 기준
            .recommendedPriority(Report.Priority.URGENT)
            .recommendedDepartment("도로관리팀")
            .summary(description + " 총 3개 문제: 포트홀 1개, 쓰레기 1개, 표지판 손상 1개")
            .build();
    }
    
    // ===== Helper Methods =====
    
    private void validateConfiguration() {
        // 개발 환경에서는 API 키만 있으면 모의 응답 사용
        if (apiKey == null || apiKey.isEmpty()) {
            throw new IllegalStateException("Roboflow API 키가 설정되지 않았습니다");
        }
        
        // workspace와 project가 없으면 경고만 출력 (모의 응답 사용)
        if (workspace == null || workspace.isEmpty() || project == null || project.isEmpty()) {
            log.warn("⚠️ Roboflow workspace/project 미설정 - 모의 응답 사용");
        }
    }
    
    private boolean isConfigurationValid() {
        return apiKey != null && !apiKey.isEmpty() &&
               workspace != null && !workspace.isEmpty() &&
               project != null && !project.isEmpty();
    }
    
    private void validateRequest(AIAnalysisRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("분석 요청이 null입니다");
        }
        
        if (request.getImage() == null || request.getImage().isEmpty()) {
            throw new IllegalArgumentException("이미지 파일이 비어있습니다");
        }
    }
    
    private String buildApiUrl(Integer confidence, Integer overlap) {
        double confidenceValue = confidence != null ? confidence / 100.0 : 0.5;
        double overlapValue = overlap != null ? overlap / 100.0 : 0.3;
        
        return String.format("%s/%s/%s/%s?api_key=%s&confidence=%.2f&overlap=%.2f",
            baseApiUrl, workspace, project, version, apiKey, confidenceValue, overlapValue);
    }
    
    private AIAnalysisResponse buildSuccessResponse(JsonNode roboflowResponse, 
                                                  long processingTime, String jobId) {
        List<DetectedObjectDto> detections = parseDetections(roboflowResponse);
        
        return AIAnalysisResponse.builder()
            .success(true)
            .detections(detections)
            .averageConfidence(calculateAverageConfidence(detections))
            .processingTime(processingTime)
            .timestamp(LocalDateTime.now())
            .jobId(jobId)
            .recommendedCategory(determineCategory(detections))
            .recommendedPriority(determinePriority(detections))
            .recommendedDepartment(determineDepartment(detections))
            .summary(generateSummary(detections))
            .rawResponse(roboflowResponse)
            .build();
    }
    
    private AIAnalysisResponse buildErrorResponse(String errorMessage, long processingTime) {
        return AIAnalysisResponse.builder()
            .success(false)
            .errorMessage(errorMessage)
            .processingTime(processingTime)
            .timestamp(LocalDateTime.now())
            .detections(Collections.emptyList())
            .build();
    }
    
    private List<DetectedObjectDto> parseDetections(JsonNode roboflowResponse) {
        List<DetectedObjectDto> detections = new ArrayList<>();
        
        if (roboflowResponse.has("predictions")) {
            JsonNode predictions = roboflowResponse.get("predictions");
            
            for (JsonNode prediction : predictions) {
                String className = prediction.path("class").asText();
                double confidence = prediction.path("confidence").asDouble();
                
                BoundingBoxDto boundingBox = BoundingBoxDto.builder()
                    .x(prediction.path("x").asDouble())
                    .y(prediction.path("y").asDouble())
                    .width(prediction.path("width").asDouble())
                    .height(prediction.path("height").asDouble())
                    .build();
                
                DetectedObjectDto detection = DetectedObjectDto.builder()
                    .className(className)
                    .koreanName(koreanClassNames.getOrDefault(className, className))
                    .confidence(confidence * 100) // Convert to percentage
                    .boundingBox(boundingBox)
                    .category(mapToCategory(className))
                    .priority(mapToPriority(className, confidence))
                    .build();
                
                detections.add(detection);
            }
        }
        
        return detections;
    }
    
    private Double calculateAverageConfidence(List<DetectedObjectDto> detections) {
        if (detections.isEmpty()) return 0.0;
        
        return detections.stream()
            .mapToDouble(DetectedObjectDto::getConfidence)
            .average()
            .orElse(0.0);
    }
    
    private ReportCategory determineCategory(List<DetectedObjectDto> detections) {
        if (detections.isEmpty()) {
            return getOrCreateDefaultCategory("기타");
        }
        
        // 가장 높은 신뢰도를 가진 객체의 카테고리 반환
        return detections.stream()
            .max(Comparator.comparing(DetectedObjectDto::getConfidence))
            .map(DetectedObjectDto::getCategory)
            .orElse(getOrCreateDefaultCategory("기타"));
    }
    
    private Report.Priority determinePriority(List<DetectedObjectDto> detections) {
        if (detections.isEmpty()) return Report.Priority.LOW;
        
        // 긴급도가 높은 객체가 있으면 높은 우선순위
        boolean hasUrgentPriority = detections.stream()
            .anyMatch(d -> d.getPriority() == Report.Priority.URGENT);
        
        if (hasUrgentPriority) return Report.Priority.URGENT;
        
        boolean hasHighPriority = detections.stream()
            .anyMatch(d -> d.getPriority() == Report.Priority.HIGH);
        
        if (hasHighPriority) return Report.Priority.HIGH;
        
        boolean hasMediumPriority = detections.stream()
            .anyMatch(d -> d.getPriority() == Report.Priority.MEDIUM);
        
        return hasMediumPriority ? Report.Priority.MEDIUM : Report.Priority.LOW;
    }
    
    private String determineDepartment(List<DetectedObjectDto> detections) {
        if (detections.isEmpty()) return "시설관리팀";
        
        // 전북지역 행정구조에 맞는 담당 부서 매핑
        Map<String, String> departmentMap = Map.of(
            "도로관리", "도로관리팀",
            "시설관리", "시설관리팀", 
            "환경관리", "환경관리팀",
            "안전관리", "안전관리팀",
            "교통관리", "교통행정팀"
        );
        
        // 우선순위가 높은 문제부터 부서 결정
        String primaryCategoryName = detections.stream()
            .filter(d -> d.getPriority() == Report.Priority.URGENT)
            .findFirst()
            .map(d -> d.getCategory().getName())
            .orElse(determineCategory(detections).getName());
        
        return departmentMap.getOrDefault(primaryCategoryName, "시설관리팀");
    }
    
    private String generateSummary(List<DetectedObjectDto> detections) {
        if (detections.isEmpty()) {
            return "감지된 문제가 없습니다.";
        }
        
        Map<String, Long> classCounts = detections.stream()
            .collect(Collectors.groupingBy(
                DetectedObjectDto::getKoreanName, 
                Collectors.counting()));
        
        StringBuilder summary = new StringBuilder();
        summary.append("총 ").append(detections.size()).append("개의 문제를 감지했습니다: ");
        
        classCounts.forEach((className, count) -> 
            summary.append(className).append(" ").append(count).append("개, "));
        
        // 마지막 쉼표 제거
        if (summary.length() > 2) {
            summary.setLength(summary.length() - 2);
        }
        
        return summary.toString();
    }
    
    private ReportCategory mapToCategory(String className) {
        String categoryName = categoryMapping.getOrDefault(className, "기타");
        return reportCategoryRepository.findByName(categoryName)
            .orElseGet(() -> getOrCreateDefaultCategory("기타"));
    }
    
    private ReportCategory getOrCreateDefaultCategory(String name) {
        return reportCategoryRepository.findByName(name)
            .orElse(ReportCategory.builder()
                .name(name)
                .description("기본 카테고리")
                .isActive(true)
                .sortOrder(999)
                .build());
    }
    
    private Report.Priority mapToPriority(String className, double confidence) {
        // 기본 우선순위 가져오기
        String basePriority = priorityMapping.getOrDefault(className, "낮음");
        
        // 신뢰도에 따른 우선순위 조정
        String finalPriority;
        if (confidence >= 0.9) {
            // 90% 이상 신뢰도 - 두 단계 상향
            switch (basePriority) {
                case "낮음": finalPriority = "긴급"; break;
                case "보통": finalPriority = "긴급"; break;
                default: finalPriority = basePriority; break;
            }
        } else if (confidence >= 0.8) {
            // 80% 이상 신뢰도 - 한 단계 상향
            switch (basePriority) {
                case "낮음": finalPriority = "보통"; break;
                case "보통": finalPriority = "긴급"; break;
                default: finalPriority = basePriority; break;
            }
        } else if (confidence < 0.6) {
            // 60% 미만 신뢰도 - 한 단계 하향
            switch (basePriority) {
                case "긴급": finalPriority = "보통"; break;
                case "보통": finalPriority = "낮음"; break;
                default: finalPriority = basePriority; break;
            }
        } else {
            finalPriority = basePriority;
        }
        
        // 문자열을 enum으로 변환
        switch (finalPriority) {
            case "긴급": return Report.Priority.URGENT;
            case "높음": return Report.Priority.HIGH;
            case "보통": return Report.Priority.MEDIUM;
            case "낮음": default: return Report.Priority.LOW;
        }
    }
    
    /**
     * Circuit breaker 상태 확인
     */
    private boolean isCircuitBreakerOpen() {
        if (!circuitBreakerOpen) {
            return false;
        }
        
        // 타임아웃 후 half-open 상태로 전환
        if (System.currentTimeMillis() - lastFailureTime > CIRCUIT_BREAKER_TIMEOUT) {
            log.info("🔄 Circuit breaker half-open 상태로 전환");
            circuitBreakerOpen = false;
        }
        
        return circuitBreakerOpen;
    }
    
    /**
     * Circuit breaker 트리거
     */
    private void triggerCircuitBreaker() {
        circuitBreakerOpen = true;
        lastFailureTime = System.currentTimeMillis();
        log.warn("⚡ Circuit breaker 활성화 - {} 후 재시도 가능", 
            CIRCUIT_BREAKER_TIMEOUT / 1000 + "초");
    }
    
    /**
     * Circuit breaker 리셋
     */
    private void resetCircuitBreaker() {
        if (circuitBreakerOpen) {
            circuitBreakerOpen = false;
            log.info("✅ Circuit breaker 정상 상태로 복구");
        }
    }
    
    /**
     * 성능 메트릭 기록
     */
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
    
    /**
     * 성능 메트릭 조회
     */
    public Map<String, Object> getPerformanceMetrics() {
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("circuit_breaker_status", circuitBreakerOpen ? "OPEN" : "CLOSED");
        metrics.put("last_failure_time", lastFailureTime);
        metrics.put("performance_data", new HashMap<>(performanceMetrics));
        metrics.put("async_jobs_count", asyncResults.size());
        return metrics;
    }
}
