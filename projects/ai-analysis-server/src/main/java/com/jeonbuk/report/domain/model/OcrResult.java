package com.jeonbuk.report.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OcrResult {
    
    private String id;
    private OcrEngine engine;
    private OcrStatus status;
    private String extractedText;
    private Double confidence;
    private List<TextBlock> textBlocks;
    private String language;
    private Map<String, Object> metadata;
    private LocalDateTime processedAt;
    private Integer processingTimeMs;
    private String errorMessage;
    
    public enum OcrEngine {
        GOOGLE_ML_KIT,
        GOOGLE_VISION,
        QWEN_VL
    }
    
    public enum OcrStatus {
        PROCESSING,
        SUCCESS,
        FAILED,
        PARTIAL
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TextBlock {
        private String text;
        private Double confidence;
        private List<Point> boundingBox;
        private String language;
        private Map<String, Object> metadata;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Point {
        private Double x;
        private Double y;
    }
}