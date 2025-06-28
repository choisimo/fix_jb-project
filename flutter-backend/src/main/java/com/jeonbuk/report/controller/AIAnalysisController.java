package com.jeonbuk.report.controller;

import com.jeonbuk.report.dto.AIAnalysisRequest;
import com.jeonbuk.report.dto.AIAnalysisResponse;
import com.jeonbuk.report.service.RoboflowService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import java.util.concurrent.CompletableFuture;

/**
 * AI 분석 API 컨트롤러
 * Roboflow를 통한 이미지 객체 감지 및 분석 서비스
 */
@Tag(name = "AI Analysis", description = "AI 기반 이미지 분석 API")
@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
@Slf4j
public class AIAnalysisController {

    private final RoboflowService roboflowService;

    /**
     * 이미지 객체 감지 및 분석
     *
     * @param image 분석할 이미지 파일
     * @param confidence 신뢰도 임계값 (기본값: 50)
     * @param overlap 겹침 임계값 (기본값: 30)
     * @return AI 분석 결과
     */
    @Operation(
        summary = "이미지 AI 분석",
        description = "업로드된 이미지에서 공공시설 문제를 감지하고 분류합니다."
    )
    @PostMapping(value = "/analyze", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<AIAnalysisResponse> analyzeImage(
            @Parameter(description = "분석할 이미지 파일", required = true)
            @RequestParam("image") MultipartFile image,
            
            @Parameter(description = "감지 신뢰도 임계값 (0-100)", example = "50")
            @RequestParam(value = "confidence", defaultValue = "50") 
            @Min(value = 0, message = "신뢰도는 0 이상이어야 합니다")
            @Max(value = 100, message = "신뢰도는 100 이하여야 합니다")
            Integer confidence,
            
            @Parameter(description = "객체 겹침 임계값 (0-100)", example = "30")
            @RequestParam(value = "overlap", defaultValue = "30")
            @Min(value = 0, message = "겹침 임계값은 0 이상이어야 합니다") 
            @Max(value = 100, message = "겹침 임계값은 100 이하여야 합니다")
            Integer overlap) {

        try {
            log.info("🤖 AI 분석 요청 - 파일명: {}, 크기: {} bytes, 신뢰도: {}%, 겹침: {}%", 
                    image.getOriginalFilename(), image.getSize(), confidence, overlap);

            // 파일 유효성 검사
            validateImageFile(image);

            // AI 분석 실행
            AIAnalysisRequest request = AIAnalysisRequest.builder()
                    .image(image)
                    .confidence(confidence)
                    .overlap(overlap)
                    .build();

            AIAnalysisResponse response = roboflowService.analyzeImage(request);

            log.info("✅ AI 분석 완료 - 감지된 객체: {}개, 처리시간: {}ms", 
                    response.getDetections().size(), response.getProcessingTime());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("❌ AI 분석 실패: {}", e.getMessage(), e);
            
            // 에러 응답 반환
            AIAnalysisResponse errorResponse = AIAnalysisResponse.builder()
                    .success(false)
                    .errorMessage(e.getMessage())
                    .processingTime(0L)
                    .build();
            
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    /**
     * 비동기 이미지 분석
     * 대용량 이미지나 배치 처리에 사용
     */
    @Operation(
        summary = "비동기 이미지 AI 분석", 
        description = "이미지 분석을 비동기로 처리하고 작업 ID를 반환합니다."
    )
    @PostMapping(value = "/analyze-async", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> analyzeImageAsync(
            @RequestParam("image") MultipartFile image,
            @RequestParam(value = "confidence", defaultValue = "50") Integer confidence,
            @RequestParam(value = "overlap", defaultValue = "30") Integer overlap) {

        try {
            validateImageFile(image);

            // 비동기 처리 시작
            String jobId = java.util.UUID.randomUUID().toString();
            
            CompletableFuture.runAsync(() -> {
                try {
                    AIAnalysisRequest request = AIAnalysisRequest.builder()
                            .image(image)
                            .confidence(confidence)
                            .overlap(overlap)
                            .jobId(jobId)
                            .build();
                    
                    roboflowService.analyzeImageAsync(request);
                } catch (Exception e) {
                    log.error("❌ 비동기 AI 분석 실패 (Job ID: {}): {}", jobId, e.getMessage(), e);
                }
            });

            log.info("🔄 비동기 AI 분석 시작 - Job ID: {}", jobId);
            return ResponseEntity.accepted().body(jobId);

        } catch (Exception e) {
            log.error("❌ 비동기 AI 분석 요청 실패: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body("분석 요청 실패: " + e.getMessage());
        }
    }

    /**
     * 비동기 작업 상태 조회
     */
    @Operation(summary = "분석 작업 상태 조회", description = "비동기 분석 작업의 진행 상태를 조회합니다.")
    @GetMapping("/status/{jobId}")
    public ResponseEntity<AIAnalysisResponse> getAnalysisStatus(
            @Parameter(description = "작업 ID", required = true, example = "550e8400-e29b-41d4-a716-446655440000")
            @PathVariable String jobId) {
        
        try {
            AIAnalysisResponse response = roboflowService.getAnalysisResult(jobId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("❌ 작업 상태 조회 실패 (Job ID: {}): {}", jobId, e.getMessage());
            
            AIAnalysisResponse errorResponse = AIAnalysisResponse.builder()
                    .success(false)
                    .errorMessage("작업을 찾을 수 없습니다: " + jobId)
                    .build();
            
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * AI 서비스 상태 확인
     */
    @Operation(summary = "AI 서비스 상태 확인", description = "Roboflow API 연결 상태를 확인합니다.")
    @GetMapping("/health")
    public ResponseEntity<String> checkHealth() {
        try {
            boolean isHealthy = roboflowService.checkHealth();
            
            if (isHealthy) {
                return ResponseEntity.ok("✅ AI 서비스 정상 동작 중");
            } else {
                return ResponseEntity.status(503).body("❌ AI 서비스 연결 실패");
            }
        } catch (Exception e) {
            log.error("❌ AI 서비스 상태 확인 실패: {}", e.getMessage(), e);
            return ResponseEntity.status(503).body("❌ 서비스 상태 확인 실패: " + e.getMessage());
        }
    }

    /**
     * 지원되는 객체 클래스 목록 조회
     */
    @Operation(summary = "감지 가능한 객체 클래스 조회", description = "AI 모델이 감지할 수 있는 객체 클래스 목록을 반환합니다.")
    @GetMapping("/classes")
    public ResponseEntity<?> getSupportedClasses() {
        try {
            var classes = roboflowService.getSupportedClasses();
            return ResponseEntity.ok(classes);
        } catch (Exception e) {
            log.error("❌ 클래스 목록 조회 실패: {}", e.getMessage(), e);
            return ResponseEntity.status(500).body("클래스 목록 조회 실패: " + e.getMessage());
        }
    }

    /**
     * 배치 이미지 분석
     */
    @Operation(summary = "배치 이미지 분석", description = "여러 이미지를 일괄 분석합니다.")
    @PostMapping(value = "/analyze-batch", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> analyzeBatchImages(
            @Parameter(description = "분석할 이미지 파일들", required = true)
            @RequestParam("images") MultipartFile[] images,
            @RequestParam(value = "confidence", defaultValue = "50") Integer confidence,
            @RequestParam(value = "overlap", defaultValue = "30") Integer overlap) {

        try {
            log.info("📦 배치 AI 분석 요청 - 이미지 수: {}", images.length);

            if (images.length > 10) {
                return ResponseEntity.badRequest().body("한 번에 최대 10개 이미지까지 처리 가능합니다.");
            }

            // 모든 이미지 유효성 검사
            for (MultipartFile image : images) {
                validateImageFile(image);
            }

            // 배치 분석 실행
            var results = roboflowService.analyzeBatchImages(images, confidence, overlap);
            
            log.info("✅ 배치 AI 분석 완료 - 처리된 이미지: {}/{}", 
                    results.size(), images.length);

            return ResponseEntity.ok(results);

        } catch (Exception e) {
            log.error("❌ 배치 AI 분석 실패: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body("배치 분석 실패: " + e.getMessage());
        }
    }

    /**
     * 테스트 시나리오별 AI 분석
     */
    @Operation(summary = "테스트 시나리오 AI 분석", description = "미리 정의된 테스트 시나리오로 AI 분석을 수행합니다.")
    @PostMapping(value = "/test-scenario", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<AIAnalysisResponse> analyzeTestScenario(
            @Parameter(description = "테스트 시나리오", required = true, 
                      example = "도로 파손")
            @RequestParam("scenario") String scenario,
            
            @Parameter(description = "테스트 이미지 파일 (선택사항)")
            @RequestParam(value = "image", required = false) MultipartFile image) {

        try {
            log.info("🧪 테스트 시나리오 분석 요청 - 시나리오: {}", scenario);

            // 이미지가 있으면 유효성 검사
            if (image != null && !image.isEmpty()) {
                validateImageFile(image);
            }

            // 테스트 시나리오 분석 실행
            AIAnalysisResponse response = roboflowService.analyzeTestScenario(scenario, image);

            log.info("✅ 테스트 시나리오 분석 완료 - 시나리오: {}, 감지: {}개", 
                    scenario, response.getDetections() != null ? response.getDetections().size() : 0);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("❌ 테스트 시나리오 분석 실패: {}", e.getMessage(), e);
            
            AIAnalysisResponse errorResponse = AIAnalysisResponse.builder()
                    .success(false)
                    .errorMessage("테스트 분석 실패: " + e.getMessage())
                    .processingTime(0L)
                    .build();
            
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
    
    /**
     * AI 서비스 성능 메트릭 조회
     */
    @Operation(summary = "AI 서비스 성능 메트릭", description = "AI 서비스의 성능 지표와 상태를 조회합니다.")
    @GetMapping("/metrics")
    public ResponseEntity<?> getMetrics() {
        try {
            var metrics = roboflowService.getPerformanceMetrics();
            return ResponseEntity.ok(metrics);
        } catch (Exception e) {
            log.error("❌ 메트릭 조회 실패: {}", e.getMessage(), e);
            return ResponseEntity.status(500).body("메트릭 조회 실패: " + e.getMessage());
        }
    }

    /**
     * 이미지 파일 유효성 검사
     */
    private void validateImageFile(MultipartFile image) {
        if (image == null || image.isEmpty()) {
            throw new IllegalArgumentException("이미지 파일이 비어있습니다.");
        }

        // 파일 크기 검사 (10MB 제한)
        if (image.getSize() > 10 * 1024 * 1024) {
            throw new IllegalArgumentException("파일 크기가 너무 큽니다. 최대 10MB까지 지원합니다.");
        }

        // 파일 형식 검사
        String contentType = image.getContentType();
        if (contentType == null || 
            (!contentType.startsWith("image/jpeg") && 
             !contentType.startsWith("image/png") && 
             !contentType.startsWith("image/jpg"))) {
            throw new IllegalArgumentException("지원하지 않는 파일 형식입니다. JPEG, PNG만 지원합니다.");
        }

        // 파일명 검사
        String filename = image.getOriginalFilename();
        if (filename == null || filename.trim().isEmpty()) {
            throw new IllegalArgumentException("유효하지 않은 파일명입니다.");
        }
    }
}
