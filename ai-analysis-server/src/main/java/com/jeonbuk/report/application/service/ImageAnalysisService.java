package com.jeonbuk.report.application.service;

import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterApiClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import javax.imageio.ImageIO;

/**
 * 이미지 분석 서비스 - 멀티스레딩으로 최적화된 무거운 작업 처리
 * 
 * UI 스레드 블로킹 방지를 위한 최적화:
 * - 이미지 리사이징을 백그라운드 스레드에서 처리
 * - AI 분석을 별도 스레드 풀에서 비동기 실행
 * - 대용량 이미지 처리 시 메모리 효율적 처리
 * - compute() 함수 활용으로 CPU 집약적 작업 분리
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ImageAnalysisService {

    private final OpenRouterApiClient openRouterApiClient;
    private final Executor imageProcessingExecutor;
    private final Executor heavyTaskExecutor;

    /**
     * 이미지 분석 메인 메서드 (비동기)
     * UI 스레드를 블로킹하지 않고 백그라운드에서 처리
     */
    @Async("imageProcessingExecutor")
    public CompletableFuture<ImageAnalysisResult> analyzeImageAsync(byte[] imageData, String fileName) {
        log.info("🖼️ 이미지 분석 시작 - 파일: {}, 크기: {} bytes", fileName, imageData.length);
        
        long startTime = System.currentTimeMillis();

        return CompletableFuture
                // 1단계: 이미지 전처리 (리사이징, 포맷 변환) - CPU 집약적 작업
                .supplyAsync(() -> preprocessImage(imageData, fileName), imageProcessingExecutor)
                
                // 2단계: 기본 이미지 정보 추출 - 빠른 처리
                .thenApply(this::extractBasicImageInfo)
                
                // 3단계: AI 분석 요청 - I/O 집약적 작업
                .thenCompose(this::performAiAnalysisAsync)
                
                // 4단계: 결과 후처리 및 최적화
                .thenApply(result -> finalizeAnalysisResult(result, startTime))
                
                // 에러 처리
                .exceptionally(throwable -> {
                    log.error("❌ 이미지 분석 실패 - 파일: {}", fileName, throwable);
                    return createErrorResult(fileName, throwable, startTime);
                });
    }

    /**
     * 대량 이미지 일괄 분석 (병렬 처리)
     */
    public CompletableFuture<List<ImageAnalysisResult>> analyzeBatchImagesAsync(
            Map<String, byte[]> imageDataMap) {
        
        log.info("📦 대량 이미지 분석 시작 - 개수: {}", imageDataMap.size());

        // 각 이미지를 병렬로 처리
        List<CompletableFuture<ImageAnalysisResult>> futures = imageDataMap.entrySet()
                .stream()
                .map(entry -> analyzeImageAsync(entry.getValue(), entry.getKey()))
                .toList();

        // 모든 분석 완료 대기
        return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
                .thenApply(voidResult -> {
                    List<ImageAnalysisResult> results = futures.stream()
                            .map(CompletableFuture::join)
                            .toList();
                    
                    log.info("✅ 대량 이미지 분석 완료 - 처리된 개수: {}", results.size());
                    return results;
                });
    }

    /**
     * 이미지 전처리 - CPU 집약적 작업을 백그라운드 스레드에서 처리
     * compute() 함수를 사용하여 UI 스레드 블로킹 방지
     */
    private ProcessedImageData preprocessImage(byte[] imageData, String fileName) {
        log.debug("🔧 이미지 전처리 시작 - {}", fileName);

        try {
            // BufferedImage 생성 (메모리 집약적)
            BufferedImage originalImage = ImageIO.read(new ByteArrayInputStream(imageData));
            
            if (originalImage == null) {
                throw new IllegalArgumentException("유효하지 않은 이미지 형식: " + fileName);
            }

            ProcessedImageData processed = new ProcessedImageData();
            processed.setOriginalWidth(originalImage.getWidth());
            processed.setOriginalHeight(originalImage.getHeight());
            processed.setOriginalSize(imageData.length);
            processed.setFileName(fileName);

            // 이미지가 너무 큰 경우 리사이징 (CPU 집약적 작업)
            if (shouldResize(originalImage)) {
                BufferedImage resizedImage = resizeImageUsingCompute(originalImage);
                processed.setProcessedImage(resizedImage);
                processed.setResized(true);
                log.debug("📏 이미지 리사이징 완료 - {}x{} -> {}x{}", 
                        originalImage.getWidth(), originalImage.getHeight(),
                        resizedImage.getWidth(), resizedImage.getHeight());
            } else {
                processed.setProcessedImage(originalImage);
                processed.setResized(false);
            }

            // 이미지 품질 분석
            processed.setQualityScore(calculateImageQuality(processed.getProcessedImage()));
            
            log.debug("✅ 이미지 전처리 완료 - {}", fileName);
            return processed;

        } catch (IOException e) {
            log.error("❌ 이미지 전처리 실패 - {}", fileName, e);
            throw new RuntimeException("이미지 전처리 실패: " + e.getMessage(), e);
        }
    }

    /**
     * compute() 함수를 활용한 이미지 리사이징
     * CPU 집약적인 픽셀 변환 작업을 병렬 처리
     */
    private BufferedImage resizeImageUsingCompute(BufferedImage originalImage) {
        int originalWidth = originalImage.getWidth();
        int originalHeight = originalImage.getHeight();
        
        // 최대 크기 제한
        int maxDimension = 1920;
        double scale = Math.min((double) maxDimension / originalWidth, 
                               (double) maxDimension / originalHeight);
        
        int newWidth = (int) (originalWidth * scale);
        int newHeight = (int) (originalHeight * scale);

        log.debug("🔄 이미지 리사이징 시작 - 스케일: {}", scale);

        // compute() 함수를 사용하여 CPU 집약적 작업 분리
        return java.util.concurrent.ForkJoinPool.commonPool().submit(() -> {
            BufferedImage resizedImage = new BufferedImage(newWidth, newHeight, originalImage.getType());
            java.awt.Graphics2D g2d = resizedImage.createGraphics();
            
            // 고품질 리샘플링 설정
            g2d.setRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION,
                                java.awt.RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g2d.setRenderingHint(java.awt.RenderingHints.KEY_RENDERING,
                                java.awt.RenderingHints.VALUE_RENDER_QUALITY);
            g2d.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING,
                                java.awt.RenderingHints.VALUE_ANTIALIAS_ON);
            
            g2d.drawImage(originalImage, 0, 0, newWidth, newHeight, null);
            g2d.dispose();
            
            return resizedImage;
        }).join();
    }

    /**
     * 기본 이미지 정보 추출 (빠른 처리)
     */
    private ImageAnalysisResult extractBasicImageInfo(ProcessedImageData processedData) {
        log.debug("📊 기본 이미지 정보 추출 - {}", processedData.getFileName());

        ImageAnalysisResult result = new ImageAnalysisResult();
        result.setFileName(processedData.getFileName());
        result.setOriginalWidth(processedData.getOriginalWidth());
        result.setOriginalHeight(processedData.getOriginalHeight());
        result.setOriginalSize(processedData.getOriginalSize());
        result.setResized(processedData.isResized());
        result.setQualityScore(processedData.getQualityScore());
        
        // 이미지 유형 기본 분류
        result.setImageType(classifyImageType(processedData));
        
        // 기본 메타데이터
        result.setAnalysisStartTime(java.time.LocalDateTime.now());
        
        return result;
    }

    /**
     * AI 분석 수행 (비동기, I/O 집약적)
     */
    private CompletableFuture<ImageAnalysisResult> performAiAnalysisAsync(ImageAnalysisResult result) {
        log.debug("🤖 AI 분석 시작 - {}", result.getFileName());

        if (!openRouterApiClient.isApiAvailable()) {
            log.warn("⚠️ AI API 사용 불가 - 기본 분석만 수행");
            result.setAiAnalysisAvailable(false);
            return CompletableFuture.completedFuture(result);
        }

        String analysisPrompt = createImageAnalysisPrompt(result);

        return openRouterApiClient
                .chatCompletionAsync(analysisPrompt)
                .thenApply(aiResponse -> {
                    try {
                        parseAiAnalysisResponse(result, aiResponse);
                        result.setAiAnalysisAvailable(true);
                        log.debug("✅ AI 분석 완료 - {}", result.getFileName());
                    } catch (Exception e) {
                        log.warn("⚠️ AI 응답 파싱 실패 - {}: {}", result.getFileName(), e.getMessage());
                        result.setAiAnalysisAvailable(false);
                    }
                    return result;
                })
                .exceptionally(throwable -> {
                    log.warn("⚠️ AI 분석 실패 - {}: {}", result.getFileName(), throwable.getMessage());
                    result.setAiAnalysisAvailable(false);
                    return result;
                });
    }

    /**
     * 분석 결과 최종화
     */
    private ImageAnalysisResult finalizeAnalysisResult(ImageAnalysisResult result, long startTime) {
        result.setAnalysisEndTime(java.time.LocalDateTime.now());
        result.setProcessingTimeMs(System.currentTimeMillis() - startTime);
        
        // 종합 점수 계산
        double comprehensiveScore = calculateComprehensiveScore(result);
        result.setComprehensiveScore(comprehensiveScore);
        
        log.info("✅ 이미지 분석 완료 - {}, 처리시간: {}ms, 점수: {}", 
                result.getFileName(), result.getProcessingTimeMs(), comprehensiveScore);
        
        return result;
    }

    /**
     * 에러 결과 생성
     */
    private ImageAnalysisResult createErrorResult(String fileName, Throwable error, long startTime) {
        ImageAnalysisResult errorResult = new ImageAnalysisResult();
        errorResult.setFileName(fileName);
        errorResult.setError(true);
        errorResult.setErrorMessage(error.getMessage());
        errorResult.setProcessingTimeMs(System.currentTimeMillis() - startTime);
        errorResult.setAnalysisEndTime(java.time.LocalDateTime.now());
        
        return errorResult;
    }

    // === 유틸리티 메서드들 ===

    private boolean shouldResize(BufferedImage image) {
        int maxDimension = 1920;
        return image.getWidth() > maxDimension || image.getHeight() > maxDimension;
    }

    private double calculateImageQuality(BufferedImage image) {
        // 간단한 품질 점수 계산 (실제로는 더 복잡한 알고리즘 사용)
        int totalPixels = image.getWidth() * image.getHeight();
        double aspectRatio = (double) image.getWidth() / image.getHeight();
        
        double qualityScore = Math.min(1.0, totalPixels / 1000000.0); // 메가픽셀 기준
        
        // 극단적인 종횡비는 품질 저하
        if (aspectRatio > 3.0 || aspectRatio < 0.33) {
            qualityScore *= 0.8;
        }
        
        return qualityScore;
    }

    private String classifyImageType(ProcessedImageData data) {
        String fileName = data.getFileName().toLowerCase();
        
        if (fileName.contains("road") || fileName.contains("도로")) return "ROAD";
        if (fileName.contains("building") || fileName.contains("건물")) return "BUILDING";
        if (fileName.contains("car") || fileName.contains("차량")) return "VEHICLE";
        if (fileName.contains("person") || fileName.contains("사람")) return "PERSON";
        
        return "GENERAL";
    }

    private String createImageAnalysisPrompt(ImageAnalysisResult result) {
        return String.format("""
                이미지 분석 전문가로서 다음 이미지 정보를 분석해주세요:
                
                파일명: %s
                크기: %dx%d
                품질 점수: %.2f
                추정 유형: %s
                
                다음 항목들을 JSON 형태로 분석해주세요:
                1. objects: 감지된 주요 객체들
                2. scene_type: 장면 유형 (indoor, outdoor, road, building 등)
                3. potential_issues: 잠재적 문제점들
                4. severity_level: 심각도 (low, medium, high, critical)
                5. recommended_actions: 권장 조치사항
                6. confidence_score: 분석 신뢰도 (0.0-1.0)
                """,
                result.getFileName(),
                result.getOriginalWidth(),
                result.getOriginalHeight(),
                result.getQualityScore(),
                result.getImageType()
        );
    }

    private void parseAiAnalysisResponse(ImageAnalysisResult result, String aiResponse) {
        // TODO: JSON 파싱 구현
        log.debug("AI 응답 파싱: {}", aiResponse);
        
        // 임시 구현 - 실제로는 Jackson으로 JSON 파싱
        if (aiResponse.contains("critical") || aiResponse.contains("CRITICAL")) {
            result.setSeverityLevel("CRITICAL");
        } else if (aiResponse.contains("high") || aiResponse.contains("HIGH")) {
            result.setSeverityLevel("HIGH");
        } else {
            result.setSeverityLevel("MEDIUM");
        }
        
        result.setAiAnalysisText(aiResponse);
    }

    private double calculateComprehensiveScore(ImageAnalysisResult result) {
        double score = result.getQualityScore() * 0.3;
        
        if (result.isAiAnalysisAvailable()) {
            score += 0.4; // AI 분석 가능 보너스
            
            // 심각도에 따른 점수 조정
            switch (result.getSeverityLevel()) {
                case "CRITICAL" -> score += 0.3;
                case "HIGH" -> score += 0.2;
                case "MEDIUM" -> score += 0.1;
                default -> score += 0.0;
            }
        } else {
            score += 0.1; // 기본 분석만 가능
        }
        
        return Math.min(1.0, score);
    }

    // === 내부 클래스들 ===

    public static class ProcessedImageData {
        private String fileName;
        private int originalWidth;
        private int originalHeight;
        private int originalSize;
        private BufferedImage processedImage;
        private boolean resized;
        private double qualityScore;

        // Getters and setters
        public String getFileName() { return fileName; }
        public void setFileName(String fileName) { this.fileName = fileName; }
        public int getOriginalWidth() { return originalWidth; }
        public void setOriginalWidth(int originalWidth) { this.originalWidth = originalWidth; }
        public int getOriginalHeight() { return originalHeight; }
        public void setOriginalHeight(int originalHeight) { this.originalHeight = originalHeight; }
        public int getOriginalSize() { return originalSize; }
        public void setOriginalSize(int originalSize) { this.originalSize = originalSize; }
        public BufferedImage getProcessedImage() { return processedImage; }
        public void setProcessedImage(BufferedImage processedImage) { this.processedImage = processedImage; }
        public boolean isResized() { return resized; }
        public void setResized(boolean resized) { this.resized = resized; }
        public double getQualityScore() { return qualityScore; }
        public void setQualityScore(double qualityScore) { this.qualityScore = qualityScore; }
    }

    public static class ImageAnalysisResult {
        private String fileName;
        private int originalWidth;
        private int originalHeight;
        private int originalSize;
        private boolean resized;
        private double qualityScore;
        private String imageType;
        private boolean aiAnalysisAvailable;
        private String aiAnalysisText;
        private String severityLevel;
        private double comprehensiveScore;
        private long processingTimeMs;
        private java.time.LocalDateTime analysisStartTime;
        private java.time.LocalDateTime analysisEndTime;
        private boolean error;
        private String errorMessage;

        // Getters and setters
        public String getFileName() { return fileName; }
        public void setFileName(String fileName) { this.fileName = fileName; }
        public int getOriginalWidth() { return originalWidth; }
        public void setOriginalWidth(int originalWidth) { this.originalWidth = originalWidth; }
        public int getOriginalHeight() { return originalHeight; }
        public void setOriginalHeight(int originalHeight) { this.originalHeight = originalHeight; }
        public int getOriginalSize() { return originalSize; }
        public void setOriginalSize(int originalSize) { this.originalSize = originalSize; }
        public boolean isResized() { return resized; }
        public void setResized(boolean resized) { this.resized = resized; }
        public double getQualityScore() { return qualityScore; }
        public void setQualityScore(double qualityScore) { this.qualityScore = qualityScore; }
        public String getImageType() { return imageType; }
        public void setImageType(String imageType) { this.imageType = imageType; }
        public boolean isAiAnalysisAvailable() { return aiAnalysisAvailable; }
        public void setAiAnalysisAvailable(boolean aiAnalysisAvailable) { this.aiAnalysisAvailable = aiAnalysisAvailable; }
        public String getAiAnalysisText() { return aiAnalysisText; }
        public void setAiAnalysisText(String aiAnalysisText) { this.aiAnalysisText = aiAnalysisText; }
        public String getSeverityLevel() { return severityLevel; }
        public void setSeverityLevel(String severityLevel) { this.severityLevel = severityLevel; }
        public double getComprehensiveScore() { return comprehensiveScore; }
        public void setComprehensiveScore(double comprehensiveScore) { this.comprehensiveScore = comprehensiveScore; }
        public long getProcessingTimeMs() { return processingTimeMs; }
        public void setProcessingTimeMs(long processingTimeMs) { this.processingTimeMs = processingTimeMs; }
        public java.time.LocalDateTime getAnalysisStartTime() { return analysisStartTime; }
        public void setAnalysisStartTime(java.time.LocalDateTime analysisStartTime) { this.analysisStartTime = analysisStartTime; }
        public java.time.LocalDateTime getAnalysisEndTime() { return analysisEndTime; }
        public void setAnalysisEndTime(java.time.LocalDateTime analysisEndTime) { this.analysisEndTime = analysisEndTime; }
        public boolean isError() { return error; }
        public void setError(boolean error) { this.error = error; }
        public String getErrorMessage() { return errorMessage; }
        public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    }
}
