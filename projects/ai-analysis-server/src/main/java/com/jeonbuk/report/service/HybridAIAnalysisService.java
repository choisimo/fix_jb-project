package com.jeonbuk.report.service;

import com.jeonbuk.report.dto.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

/**
 * 통합 AI 분석 파이프라인 서비스
 * Google Vision OCR + AutoML Vision + RAG 시스템 통합
 */
@Slf4j
@Service
public class HybridAIAnalysisService {

    @Autowired
    private GoogleCloudVisionService googleVisionService;

    @Autowired
    private AutoMLVisionService autoMLVisionService;

    @Autowired
    private RagOrchestrationService ragService;

    @Autowired
    private RoboflowService roboflowService;

    @Autowired
    private DocumentIndexingService documentIndexingService;

    @Value("${ai.analysis.enable-automl:true}")
    private boolean enableAutoML;

    @Value("${ai.analysis.enable-rag:true}")
    private boolean enableRAG;

    @Value("${ai.analysis.enable-fallback:true}")
    private boolean enableFallback;

    @Value("${ai.analysis.confidence-threshold:0.7}")
    private float confidenceThreshold;

    @Value("${ai.analysis.parallel-processing:true}")
    private boolean parallelProcessing;

    /**
     * 통합 AI 분석 수행 (모든 AI 서비스 통합)
     */
    public CompletableFuture<HybridAnalysisResult> performHybridAnalysis(
            byte[] imageData, String reportId, String filename) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("Starting hybrid AI analysis for report: {} (file: {})", reportId, filename);
                long startTime = System.currentTimeMillis();
                
                HybridAnalysisResult.HybridAnalysisResultBuilder resultBuilder = 
                    HybridAnalysisResult.builder()
                        .reportId(reportId)
                        .filename(filename)
                        .analysisStartTime(LocalDateTime.now());
                
                // Phase 1: 기본 AI 분석 (병렬 처리)
                CompletableFuture<List<String>> ocrFuture = performOCRAnalysis(imageData, filename);
                CompletableFuture<String> roboflowFuture = performRoboflowAnalysis(imageData);
                
                // Phase 2: AutoML Vision 분석 (선택적)
                CompletableFuture<AutoMLClassificationResult> autoMLClassificationFuture = null;
                CompletableFuture<AutoMLObjectDetectionResult> autoMLDetectionFuture = null;
                
                if (enableAutoML) {
                    autoMLClassificationFuture = autoMLVisionService.classifyImage(imageData);
                    autoMLDetectionFuture = autoMLVisionService.detectObjects(imageData);
                }
                
                // Phase 1 결과 수집
                List<String> ocrTexts = ocrFuture.get();
                String roboflowResult = roboflowFuture.get();
                
                resultBuilder.ocrTexts(ocrTexts)
                           .roboflowAnalysis(roboflowResult);
                
                // Phase 2 결과 수집 (AutoML)
                AutoMLClassificationResult classificationResult = null;
                AutoMLObjectDetectionResult detectionResult = null;
                
                if (enableAutoML && autoMLClassificationFuture != null && autoMLDetectionFuture != null) {
                    classificationResult = autoMLClassificationFuture.get();
                    detectionResult = autoMLDetectionFuture.get();
                    
                    resultBuilder.autoMLClassification(classificationResult)
                               .autoMLDetection(detectionResult);
                }
                
                // Phase 3: 기본 분석 결과 생성
                AIAnalysisResponse basicAnalysis = createBasicAnalysisResult(
                    ocrTexts, roboflowResult, classificationResult, detectionResult);
                
                resultBuilder.basicAnalysis(basicAnalysis);
                
                // Phase 4: RAG 향상 분석 (선택적)
                RagAnalysisResult ragResult = null;
                if (enableRAG) {
                    String analysisQuery = constructAnalysisQuery(basicAnalysis);
                    ragResult = ragService.analyzeWithContext(analysisQuery, basicAnalysis).get();
                    resultBuilder.ragAnalysis(ragResult);
                }
                
                // Phase 5: 최종 결과 통합
                String finalAnalysis = integrateFinalAnalysis(basicAnalysis, ragResult);
                float finalConfidence = calculateFinalConfidence(
                    basicAnalysis, classificationResult, detectionResult, ragResult);
                
                long processingTime = System.currentTimeMillis() - startTime;
                
                HybridAnalysisResult result = resultBuilder
                    .finalAnalysis(finalAnalysis)
                    .finalConfidence(finalConfidence)
                    .processingTimeMs(processingTime)
                    .analysisEndTime(LocalDateTime.now())
                    .status("SUCCESS")
                    .build();
                
                // Phase 6: 결과를 RAG 시스템에 인덱싱 (비동기)
                if (enableRAG) {
                    indexAnalysisResult(reportId, String.join(" ", ocrTexts), finalAnalysis);
                }
                
                log.info("Hybrid analysis completed for report {} in {}ms (confidence: {:.2f})", 
                        reportId, processingTime, finalConfidence);
                
                return result;
                
            } catch (Exception e) {
                log.error("Hybrid analysis failed for report: {}", reportId, e);
                return createFallbackResult(reportId, filename, e);
            }
        });
    }

    /**
     * 배치 분석 (여러 이미지 동시 처리)
     */
    public CompletableFuture<Map<String, HybridAnalysisResult>> performBatchAnalysis(
            Map<String, BatchAnalysisRequest> requests) {
        
        return CompletableFuture.supplyAsync(() -> {
            Map<String, HybridAnalysisResult> results = new HashMap<>();
            
            List<CompletableFuture<Void>> futures = requests.entrySet().stream()
                .map(entry -> {
                    String reportId = entry.getKey();
                    BatchAnalysisRequest request = entry.getValue();
                    
                    return performHybridAnalysis(request.getImageData(), reportId, request.getFilename())
                        .thenAccept(result -> results.put(reportId, result));
                })
                .toList();
            
            // 모든 분석 완료 대기
            CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();
            
            log.info("Batch analysis completed for {} reports", results.size());
            return results;
        });
    }

    /**
     * 적응형 분석 (이미지 특성에 따른 최적 모델 선택)
     */
    public CompletableFuture<HybridAnalysisResult> performAdaptiveAnalysis(
            byte[] imageData, String reportId, String filename, Map<String, Object> imageMetadata) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                // 이미지 메타데이터 분석
                AnalysisStrategy strategy = determineOptimalStrategy(imageMetadata, filename);
                
                log.info("Using adaptive strategy: {} for report: {}", strategy, reportId);
                
                // 전략에 따른 분석 수행
                return performAnalysisWithStrategy(imageData, reportId, filename, strategy).get();
                
            } catch (Exception e) {
                log.error("Adaptive analysis failed for report: {}", reportId, e);
                return createFallbackResult(reportId, filename, e);
            }
        });
    }

    /**
     * OCR 분석 수행
     */
    private CompletableFuture<List<String>> performOCRAnalysis(byte[] imageData, String filename) {
        return googleVisionService.extractTextFromImage(imageData, filename);
    }

    /**
     * Roboflow 객체 탐지 분석
     */
    private CompletableFuture<String> performRoboflowAnalysis(byte[] imageData) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                // Roboflow 서비스 호출 (기존 구현 활용)
                return "Roboflow 분석 결과 예시"; // 실제 구현에서는 roboflowService 호출
            } catch (Exception e) {
                log.warn("Roboflow analysis failed, using fallback", e);
                return "객체 탐지 분석을 수행할 수 없습니다.";
            }
        });
    }

    /**
     * 기본 AI 분석 결과 생성
     */
    private AIAnalysisResponse createBasicAnalysisResult(
            List<String> ocrTexts, 
            String roboflowResult,
            AutoMLClassificationResult classificationResult,
            AutoMLObjectDetectionResult detectionResult) {
        
        StringBuilder analysisBuilder = new StringBuilder();
        
        // OCR 결과 요약
        if (!ocrTexts.isEmpty()) {
            analysisBuilder.append("=== 텍스트 분석 ===\n");
            analysisBuilder.append("추출된 텍스트: ").append(String.join(", ", ocrTexts)).append("\n\n");
        }
        
        // 객체 탐지 결과 (Roboflow)
        analysisBuilder.append("=== 기본 객체 탐지 ===\n");
        analysisBuilder.append(roboflowResult).append("\n\n");
        
        // AutoML 분류 결과
        if (classificationResult != null && !classificationResult.getPredictions().isEmpty()) {
            analysisBuilder.append("=== 도메인 특화 분류 ===\n");
            ClassificationPrediction topPrediction = classificationResult.getTopPrediction();
            analysisBuilder.append("분류: ").append(topPrediction.getKoreanLabel())
                         .append(" (신뢰도: ").append(topPrediction.getConfidencePercentage()).append(")\n");
            analysisBuilder.append("카테고리: ").append(topPrediction.getKoreanCategory()).append("\n\n");
        }
        
        // AutoML 객체 탐지 결과
        if (detectionResult != null && !detectionResult.getDetections().isEmpty()) {
            analysisBuilder.append("=== 정밀 객체 탐지 ===\n");
            for (ObjectDetectionPrediction detection : detectionResult.getDetections()) {
                analysisBuilder.append("- ").append(detection.getKoreanLabel())
                             .append(" (신뢰도: ").append(detection.getConfidencePercentage()).append(")\n");
            }
            analysisBuilder.append("\n");
        }
        
        // 기본 신뢰도 계산
        float confidence = calculateBasicConfidence(classificationResult, detectionResult);
        
        AIAnalysisResponse response = AIAnalysisResponse.builder()
            .ocrText(String.join(" ", ocrTexts))
            .analysisResult(analysisBuilder.toString())
            .averageConfidence((double) confidence)
            .processingTime(0L) // 개별 단계에서 측정
            .timestamp(LocalDateTime.now())
            .build();
        
        // 감지된 객체 설정
        response.detectedObjects(extractDetectedObjects(roboflowResult, classificationResult, detectionResult));
        
        return response;
    }

    /**
     * 최종 분석 결과 통합
     */
    private String integrateFinalAnalysis(AIAnalysisResponse basicAnalysis, RagAnalysisResult ragResult) {
        StringBuilder finalAnalysis = new StringBuilder();
        
        finalAnalysis.append("=== 종합 AI 분석 결과 ===\n\n");
        
        // 기본 분석 결과
        finalAnalysis.append("📊 기본 분석:\n");
        finalAnalysis.append(basicAnalysis.getAnalysisResult()).append("\n");
        
        // RAG 향상 분석 (있는 경우)
        if (ragResult != null && ragResult.isSuccessful()) {
            finalAnalysis.append("🧠 지식 기반 향상 분석:\n");
            finalAnalysis.append(ragResult.getEnhancedAnalysis()).append("\n");
            
            if (ragResult.getContextSourceCount() > 0) {
                finalAnalysis.append("\n📚 참조된 지식 소스: ").append(ragResult.getContextSourceCount()).append("개\n");
            }
        }
        
        // 종합 결론
        finalAnalysis.append("\n=== 종합 결론 ===\n");
        finalAnalysis.append(generateFinalConclusion(basicAnalysis, ragResult));
        
        return finalAnalysis.toString();
    }

    /**
     * 종합 결론 생성
     */
    private String generateFinalConclusion(AIAnalysisResponse basicAnalysis, RagAnalysisResult ragResult) {
        StringBuilder conclusion = new StringBuilder();
        
        // 신뢰도 기반 분석 품질 평가
        float confidence = basicAnalysis.getConfidence();
        if (ragResult != null && ragResult.getConfidence() != null) {
            confidence = Math.max(confidence, ragResult.getConfidence());
        }
        
        if (confidence >= 0.9f) {
            conclusion.append("🔹 분석 결과는 매우 높은 신뢰도를 보입니다.\n");
        } else if (confidence >= 0.7f) {
            conclusion.append("🔹 분석 결과는 높은 신뢰도를 보입니다.\n");
        } else if (confidence >= 0.5f) {
            conclusion.append("🔹 분석 결과는 보통 수준의 신뢰도를 보입니다.\n");
        } else {
            conclusion.append("🔹 분석 결과의 신뢰도가 낮으므로 추가 검토가 필요합니다.\n");
        }
        
        // 주요 발견사항 요약
        List<String> detectedObjects = basicAnalysis.getDetectedObjects();
        if (!detectedObjects.isEmpty()) {
            conclusion.append("🔹 주요 탐지 객체: ").append(String.join(", ", detectedObjects)).append("\n");
        }
        
        // RAG 향상 정보
        if (ragResult != null && ragResult.isSuccessful()) {
            conclusion.append("🔹 지식 기반을 통한 분석 향상이 적용되었습니다.\n");
            if (ragResult.getImprovementRatio() > 1.5f) {
                conclusion.append("🔹 기존 분석 대비 상당한 정보 보강이 이루어졌습니다.\n");
            }
        }
        
        return conclusion.toString();
    }

    /**
     * 최종 신뢰도 계산
     */
    private float calculateFinalConfidence(AIAnalysisResponse basicAnalysis,
                                         AutoMLClassificationResult classificationResult,
                                         AutoMLObjectDetectionResult detectionResult,
                                         RagAnalysisResult ragResult) {
        
        List<Float> confidences = new ArrayList<>();
        
        // 기본 분석 신뢰도
        confidences.add(basicAnalysis.getConfidence());
        
        // AutoML 결과 신뢰도
        if (classificationResult != null) {
            confidences.add(classificationResult.getAverageConfidence());
        }
        if (detectionResult != null) {
            confidences.add(detectionResult.getAverageConfidence());
        }
        
        // RAG 분석 신뢰도 (가중치 적용)
        if (ragResult != null && ragResult.getConfidence() != null) {
            confidences.add(ragResult.getConfidence() * 1.1f); // RAG 결과에 약간의 가중치
        }
        
        // 가중 평균 계산
        return confidences.stream()
            .filter(Objects::nonNull)
            .reduce(0.0f, Float::sum) / confidences.size();
    }

    /**
     * 기본 신뢰도 계산
     */
    private float calculateBasicConfidence(AutoMLClassificationResult classificationResult,
                                         AutoMLObjectDetectionResult detectionResult) {
        
        List<Float> confidences = new ArrayList<>();
        confidences.add(0.7f); // 기본값
        
        if (classificationResult != null) {
            confidences.add(classificationResult.getAverageConfidence());
        }
        if (detectionResult != null) {
            confidences.add(detectionResult.getAverageConfidence());
        }
        
        return confidences.stream().reduce(0.0f, Float::sum) / confidences.size();
    }

    /**
     * 탐지된 객체 목록 추출
     */
    private List<String> extractDetectedObjects(String roboflowResult,
                                               AutoMLClassificationResult classificationResult,
                                               AutoMLObjectDetectionResult detectionResult) {
        
        Set<String> objects = new HashSet<>();
        
        // Roboflow 결과에서 추출 (간단한 파싱)
        if (roboflowResult.contains("포트홀")) objects.add("포트홀");
        if (roboflowResult.contains("쓰레기")) objects.add("쓰레기");
        if (roboflowResult.contains("낙서")) objects.add("낙서");
        
        // AutoML 분류 결과에서 추출
        if (classificationResult != null) {
            classificationResult.getPredictions().stream()
                .map(ClassificationPrediction::getKoreanLabel)
                .forEach(objects::add);
        }
        
        // AutoML 객체 탐지 결과에서 추출
        if (detectionResult != null) {
            detectionResult.getDetections().stream()
                .map(ObjectDetectionPrediction::getKoreanLabel)
                .forEach(objects::add);
        }
        
        return new ArrayList<>(objects);
    }

    /**
     * 분석 쿼리 구성
     */
    private String constructAnalysisQuery(AIAnalysisResponse basicAnalysis) {
        StringBuilder query = new StringBuilder();
        
        query.append("다음 신고서 분석 결과에 대한 상세 분석과 대응 방안을 제시해주세요:\n\n");
        query.append("탐지된 객체: ").append(String.join(", ", basicAnalysis.getDetectedObjects())).append("\n");
        query.append("OCR 텍스트: ").append(basicAnalysis.getOcrText()).append("\n");
        query.append("기본 분석: ").append(basicAnalysis.getAnalysisResult());
        
        return query.toString();
    }

    /**
     * 최적 분석 전략 결정
     */
    private AnalysisStrategy determineOptimalStrategy(Map<String, Object> imageMetadata, String filename) {
        // 파일명 기반 초기 판단
        String lowerFilename = filename.toLowerCase();
        
        if (lowerFilename.contains("pothole") || lowerFilename.contains("crack")) {
            return AnalysisStrategy.ROAD_DAMAGE_FOCUSED;
        } else if (lowerFilename.contains("trash") || lowerFilename.contains("garbage")) {
            return AnalysisStrategy.WASTE_MANAGEMENT_FOCUSED;
        } else if (lowerFilename.contains("graffiti")) {
            return AnalysisStrategy.VANDALISM_FOCUSED;
        }
        
        // 이미지 메타데이터 기반 판단
        if (imageMetadata != null) {
            Integer width = (Integer) imageMetadata.get("width");
            Integer height = (Integer) imageMetadata.get("height");
            
            if (width != null && height != null) {
                if (width * height > 2000000) { // 고해상도 이미지
                    return AnalysisStrategy.HIGH_ACCURACY_FOCUSED;
                } else if (width * height < 500000) { // 저해상도 이미지
                    return AnalysisStrategy.FAST_PROCESSING_FOCUSED;
                }
            }
        }
        
        return AnalysisStrategy.BALANCED;
    }

    /**
     * 전략별 분석 수행
     */
    private CompletableFuture<HybridAnalysisResult> performAnalysisWithStrategy(
            byte[] imageData, String reportId, String filename, AnalysisStrategy strategy) {
        
        // 전략에 따라 다른 모델이나 파라미터 사용
        // 현재는 기본 분석과 동일하게 처리하고, 향후 확장 가능
        return performHybridAnalysis(imageData, reportId, filename);
    }

    /**
     * 분석 결과 인덱싱 (비동기)
     */
    private void indexAnalysisResult(String reportId, String ocrText, String analysisResult) {
        CompletableFuture.runAsync(() -> {
            try {
                documentIndexingService.indexAIAnalysisResult(reportId, ocrText, analysisResult);
                log.debug("Analysis result indexed for report: {}", reportId);
            } catch (Exception e) {
                log.warn("Failed to index analysis result for report: {}", reportId, e);
            }
        });
    }

    /**
     * 폴백 결과 생성
     */
    private HybridAnalysisResult createFallbackResult(String reportId, String filename, Exception error) {
        return HybridAnalysisResult.builder()
            .reportId(reportId)
            .filename(filename)
            .finalAnalysis("분석 중 오류가 발생했습니다: " + error.getMessage())
            .finalConfidence(0.0f)
            .status("FAILED")
            .errorMessage(error.getMessage())
            .analysisStartTime(LocalDateTime.now())
            .analysisEndTime(LocalDateTime.now())
            .processingTimeMs(0L)
            .build();
    }

    /**
     * 분석 전략 열거형
     */
    public enum AnalysisStrategy {
        BALANCED,                    // 균형잡힌 분석
        ROAD_DAMAGE_FOCUSED,        // 도로 손상 특화
        WASTE_MANAGEMENT_FOCUSED,    // 폐기물 관리 특화
        VANDALISM_FOCUSED,          // 기물 파손 특화
        HIGH_ACCURACY_FOCUSED,       // 고정확도 분석
        FAST_PROCESSING_FOCUSED      // 빠른 처리 분석
    }
}