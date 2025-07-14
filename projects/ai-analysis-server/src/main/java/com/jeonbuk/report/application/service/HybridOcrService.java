package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.model.OcrResult;
import com.jeonbuk.report.infrastructure.external.GoogleCloudVisionClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;

/**
 * 하이브리드 OCR 서비스
 * Google Cloud Vision, OpenRouter AI 모델을 조합하여 최적의 OCR 결과 제공
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class HybridOcrService {

    private final GoogleCloudVisionClient googleVisionClient;
    private final IntegratedAiAgentService integratedAiAgentService;

    /**
     * 하이브리드 OCR 처리 - 여러 엔진을 사용하여 최고의 결과 도출
     */
    public CompletableFuture<List<OcrResult>> processHybridOcr(
        byte[] imageData, 
        String filename,
        OcrConfig config
    ) {
        log.info("🔄 하이브리드 OCR 처리 시작 - 파일: {}", filename);
        
        List<CompletableFuture<OcrResult>> futures = new ArrayList<>();
        
        // 1. Google Cloud Vision OCR (고정밀)
        if (googleVisionClient.isAvailable() && config.isEnableGoogleVision()) {
            futures.add(googleVisionClient.extractTextAsync(imageData, filename));
        }
        
        // 2. AI 모델 OCR (qwen2.5-vl-72b-instruct)
        if (config.isEnableAiModel()) {
            futures.add(processAiModelOcr(imageData, filename));
        }
        
        // 병렬 처리 및 결과 수집
        return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
            .thenApply(v -> {
                List<OcrResult> results = new ArrayList<>();
                for (CompletableFuture<OcrResult> future : futures) {
                    try {
                        OcrResult result = future.get();
                        if (result.getStatus() != OcrResult.OcrStatus.FAILED) {
                            results.add(result);
                        }
                    } catch (Exception e) {
                        log.warn("⚠️ OCR 처리 중 일부 실패: {}", e.getMessage());
                    }
                }
                
                log.info("✅ 하이브리드 OCR 완료 - 파일: {}, 성공한 엔진: {}", 
                        filename, results.size());
                
                return results;
            });
    }

    /**
     * AI 모델 기반 OCR 처리 (기존 OpenRouter 활용)
     */
    private CompletableFuture<OcrResult> processAiModelOcr(byte[] imageData, String filename) {
        return CompletableFuture.supplyAsync(() -> {
            String resultId = UUID.randomUUID().toString();
            long startTime = System.currentTimeMillis();
            
            try {
                log.info("🤖 AI 모델 OCR 시작 - 파일: {}", filename);
                
                // OpenRouter AI 모델을 통한 텍스트 추출
                String extractedText = integratedAiAgentService.extractTextFromImage(imageData);
                
                long processingTime = System.currentTimeMillis() - startTime;
                
                // AI 모델 결과의 신뢰도는 텍스트 길이와 구조를 기반으로 추정
                double confidence = calculateAiModelConfidence(extractedText);
                
                return OcrResult.builder()
                    .id(resultId)
                    .engine(OcrResult.OcrEngine.QWEN_VL)
                    .status(confidence > 0.5 ? OcrResult.OcrStatus.SUCCESS : OcrResult.OcrStatus.PARTIAL)
                    .extractedText(extractedText)
                    .confidence(confidence)
                    .language(detectLanguage(extractedText))
                    .metadata(Map.of(
                        "filename", filename,
                        "model", "qwen2.5-vl-72b-instruct",
                        "processingType", "ai_vision_model"
                    ))
                    .processedAt(LocalDateTime.now())
                    .processingTimeMs((int) processingTime)
                    .build();
                    
            } catch (Exception e) {
                long processingTime = System.currentTimeMillis() - startTime;
                log.error("❌ AI 모델 OCR 실패 - 파일: {}, 오류: {}", filename, e.getMessage());
                
                return OcrResult.builder()
                    .id(resultId)
                    .engine(OcrResult.OcrEngine.QWEN_VL)
                    .status(OcrResult.OcrStatus.FAILED)
                    .extractedText("")
                    .confidence(0.0)
                    .errorMessage(e.getMessage())
                    .processedAt(LocalDateTime.now())
                    .processingTimeMs((int) processingTime)
                    .build();
            }
        });
    }

    /**
     * 최적의 OCR 결과 선택
     */
    public OcrResult selectBestResult(List<OcrResult> results, OcrConfig config) {
        if (results.isEmpty()) {
            throw new IllegalArgumentException("OCR 결과가 없습니다");
        }
        
        if (results.size() == 1) {
            return results.get(0);
        }
        
        log.info("🔍 최적의 OCR 결과 선택 중 - 후보: {}", results.size());
        
        // 성공한 결과만 필터링
        List<OcrResult> successResults = results.stream()
            .filter(r -> r.getStatus() == OcrResult.OcrStatus.SUCCESS)
            .toList();
        
        if (successResults.isEmpty()) {
            // 성공한 결과가 없으면 신뢰도가 가장 높은 결과 반환
            return results.stream()
                .max(Comparator.comparing(OcrResult::getConfidence))
                .orElse(results.get(0));
        }
        
        // 복합 점수 계산하여 최적 결과 선택
        OcrResult bestResult = successResults.stream()
            .max(Comparator.comparing(result -> calculateCompositeScore(result, config)))
            .orElse(successResults.get(0));
        
        log.info("✅ 최적 결과 선택 완료 - 엔진: {}, 신뢰도: {:.2f}, 텍스트 길이: {}", 
                bestResult.getEngine(), bestResult.getConfidence(), bestResult.getExtractedText().length());
        
        return bestResult;
    }

    /**
     * 복합 점수 계산 (신뢰도 + 텍스트 품질 + 엔진 선호도)
     */
    private double calculateCompositeScore(OcrResult result, OcrConfig config) {
        double confidenceScore = result.getConfidence() * 0.5; // 신뢰도 50%
        double lengthScore = Math.min(result.getExtractedText().length() / 200.0, 1.0) * 0.3; // 텍스트 길이 30%
        double engineScore = getEnginePreferenceScore(result.getEngine(), config) * 0.2; // 엔진 선호도 20%
        
        return confidenceScore + lengthScore + engineScore;
    }

    /**
     * 엔진 선호도 점수
     */
    private double getEnginePreferenceScore(OcrResult.OcrEngine engine, OcrConfig config) {
        return switch (engine) {
            case GOOGLE_VISION -> config.getGoogleVisionWeight();
            case QWEN_VL -> config.getAiModelWeight();
            case GOOGLE_ML_KIT -> config.getMlKitWeight();
        };
    }

    /**
     * AI 모델 결과의 신뢰도 추정 (휴리스틱)
     */
    private double calculateAiModelConfidence(String text) {
        if (text == null || text.trim().isEmpty()) return 0.0;
        
        int length = text.length();
        int lineCount = text.split("\n").length;
        
        // 텍스트 길이와 구조를 기반으로 신뢰도 추정
        if (length >= 100 && lineCount >= 3) return 0.9;
        if (length >= 50 && lineCount >= 2) return 0.8;
        if (length >= 20) return 0.7;
        if (length >= 5) return 0.6;
        return 0.5;
    }

    /**
     * 언어 감지
     */
    private String detectLanguage(String text) {
        if (text == null || text.isEmpty()) return null;
        
        long koreanCount = text.chars().filter(ch -> ch >= 0xAC00 && ch <= 0xD7AF).count();
        long englishCount = text.chars().filter(ch -> (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')).count();
        
        if (koreanCount > englishCount) return "ko";
        if (englishCount > 0) return "en";
        return null;
    }

    /**
     * OCR 설정 클래스
     */
    public static class OcrConfig {
        private boolean enableGoogleVision = true;
        private boolean enableAiModel = true;
        private double googleVisionWeight = 0.6;
        private double aiModelWeight = 0.4;
        private double mlKitWeight = 0.3;
        private double confidenceThreshold = 0.5;
        
        // Getters and setters
        public boolean isEnableGoogleVision() { return enableGoogleVision; }
        public void setEnableGoogleVision(boolean enableGoogleVision) { this.enableGoogleVision = enableGoogleVision; }
        
        public boolean isEnableAiModel() { return enableAiModel; }
        public void setEnableAiModel(boolean enableAiModel) { this.enableAiModel = enableAiModel; }
        
        public double getGoogleVisionWeight() { return googleVisionWeight; }
        public void setGoogleVisionWeight(double googleVisionWeight) { this.googleVisionWeight = googleVisionWeight; }
        
        public double getAiModelWeight() { return aiModelWeight; }
        public void setAiModelWeight(double aiModelWeight) { this.aiModelWeight = aiModelWeight; }
        
        public double getMlKitWeight() { return mlKitWeight; }
        public void setMlKitWeight(double mlKitWeight) { this.mlKitWeight = mlKitWeight; }
        
        public double getConfidenceThreshold() { return confidenceThreshold; }
        public void setConfidenceThreshold(double confidenceThreshold) { this.confidenceThreshold = confidenceThreshold; }
    }
}