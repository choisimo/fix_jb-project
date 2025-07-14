package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.HybridOcrService;
import com.jeonbuk.report.domain.model.OcrResult;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * OCR 처리 전용 컨트롤러
 * Google ML Kit, Google Vision, AI 모델을 조합한 하이브리드 OCR 서비스 제공
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/ocr")
@RequiredArgsConstructor
@Tag(name = "OCR API", description = "텍스트 추출 및 OCR 처리 API")
public class OcrController {

    private final HybridOcrService hybridOcrService;

    /**
     * 하이브리드 OCR 처리 - 여러 엔진을 사용하여 최고 품질의 텍스트 추출
     */
    @PostMapping(value = "/extract", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "하이브리드 OCR 텍스트 추출", 
               description = "Google Vision과 AI 모델을 조합하여 이미지에서 텍스트를 추출합니다")
    public CompletableFuture<ResponseEntity<OcrResponse>> extractText(
        @Parameter(description = "텍스트를 추출할 이미지 파일", required = true)
        @RequestPart("image") MultipartFile imageFile,
        
        @Parameter(description = "Google Vision 사용 여부", example = "true")
        @RequestParam(defaultValue = "true") boolean enableGoogleVision,
        
        @Parameter(description = "AI 모델 사용 여부", example = "true") 
        @RequestParam(defaultValue = "true") boolean enableAiModel,
        
        @Parameter(description = "신뢰도 임계값", example = "0.5")
        @RequestParam(defaultValue = "0.5") double confidenceThreshold
    ) {
        log.info("📋 OCR 요청 수신 - 파일: {}, 크기: {} bytes", 
                imageFile.getOriginalFilename(), imageFile.getSize());

        try {
            // OCR 설정 구성
            HybridOcrService.OcrConfig config = new HybridOcrService.OcrConfig();
            config.setEnableGoogleVision(enableGoogleVision);
            config.setEnableAiModel(enableAiModel);
            config.setConfidenceThreshold(confidenceThreshold);

            // 하이브리드 OCR 처리
            return hybridOcrService.processHybridOcr(
                imageFile.getBytes(), 
                imageFile.getOriginalFilename(),
                config
            ).thenApply(results -> {
                if (results.isEmpty()) {
                    return ResponseEntity.badRequest()
                        .body(OcrResponse.error("OCR 처리에 실패했습니다"));
                }

                // 최적의 결과 선택
                OcrResult bestResult = hybridOcrService.selectBestResult(results, config);
                
                return ResponseEntity.ok(OcrResponse.success(bestResult, results));
            });

        } catch (Exception e) {
            log.error("❌ OCR 처리 실패 - 파일: {}, 오류: {}", 
                    imageFile.getOriginalFilename(), e.getMessage());
            
            return CompletableFuture.completedFuture(
                ResponseEntity.internalServerError()
                    .body(OcrResponse.error("서버 오류: " + e.getMessage()))
            );
        }
    }

    /**
     * 빠른 OCR 처리 - Google ML Kit 결과 전용 (클라이언트 사이드와 호환)
     */
    @PostMapping(value = "/quick", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "빠른 OCR 처리", 
               description = "서버 사이드에서 빠른 OCR 처리 (폴백용)")
    public ResponseEntity<Map<String, Object>> quickExtract(
        @Parameter(description = "텍스트를 추출할 이미지 파일", required = true)
        @RequestPart("image") MultipartFile imageFile
    ) {
        try {
            // 간단한 처리를 위해 AI 모델만 사용
            HybridOcrService.OcrConfig config = new HybridOcrService.OcrConfig();
            config.setEnableGoogleVision(false);
            config.setEnableAiModel(true);

            List<OcrResult> results = hybridOcrService.processHybridOcr(
                imageFile.getBytes(),
                imageFile.getOriginalFilename(),
                config
            ).get(); // 동기 처리

            if (results.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "OCR 처리 실패"));
            }

            OcrResult result = results.get(0);
            
            return ResponseEntity.ok(Map.of(
                "id", result.getId(),
                "engine", result.getEngine().name(),
                "status", result.getStatus().name(),
                "extractedText", result.getExtractedText(),
                "confidence", result.getConfidence(),
                "processingTimeMs", result.getProcessingTimeMs()
            ));

        } catch (Exception e) {
            log.error("❌ 빠른 OCR 처리 실패: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * OCR 성능 통계 조회
     */
    @GetMapping("/stats")
    @Operation(summary = "OCR 성능 통계", description = "OCR 처리 성능 및 엔진별 통계를 조회합니다")
    public ResponseEntity<Map<String, Object>> getOcrStats() {
        // TODO: 실제 통계 데이터 구현
        return ResponseEntity.ok(Map.of(
            "message", "OCR 통계 기능은 향후 구현 예정입니다",
            "availableEngines", List.of("GOOGLE_VISION", "QWEN_VL"),
            "defaultEngine", "GOOGLE_VISION"
        ));
    }

    /**
     * OCR 응답 DTO
     */
    public static class OcrResponse {
        private boolean success;
        private String message;
        private OcrResult bestResult;
        private List<OcrResult> allResults;
        private String errorMessage;

        // 생성자
        private OcrResponse(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        // 성공 응답 생성
        public static OcrResponse success(OcrResult bestResult, List<OcrResult> allResults) {
            OcrResponse response = new OcrResponse(true, "OCR 처리 성공");
            response.bestResult = bestResult;
            response.allResults = allResults;
            return response;
        }

        // 오류 응답 생성
        public static OcrResponse error(String errorMessage) {
            OcrResponse response = new OcrResponse(false, "OCR 처리 실패");
            response.errorMessage = errorMessage;
            return response;
        }

        // Getters
        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public OcrResult getBestResult() { return bestResult; }
        public List<OcrResult> getAllResults() { return allResults; }
        public String getErrorMessage() { return errorMessage; }
    }
}