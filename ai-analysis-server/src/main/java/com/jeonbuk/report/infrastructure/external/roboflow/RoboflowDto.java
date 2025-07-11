package com.jeonbuk.report.infrastructure.external.roboflow;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * Roboflow API DTOs
 */
public class RoboflowDto {

    /**
     * Roboflow API 요청 DTO
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AnalysisRequest {
        private String image; // Base64 encoded image or image URL
        private String modelId;
        private Double confidence;
        private Double overlap;
    }

    /**
     * Roboflow API 응답 DTO
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AnalysisResponse {
        private String time;
        private ImageInfo image;
        private List<Prediction> predictions;
        
        @JsonProperty("inference_id")
        private String inferenceId;
        
        @Data
        @NoArgsConstructor
        @AllArgsConstructor
        public static class ImageInfo {
            private Integer width;
            private Integer height;
        }
        
        @Data
        @NoArgsConstructor
        @AllArgsConstructor
        public static class Prediction {
            private Double x;
            private Double y;
            private Double width;
            private Double height;
            private Double confidence;
            
            @JsonProperty("class")
            private String className;
            
            @JsonProperty("class_id")
            private Integer classId;
            
            @JsonProperty("detection_id")
            private String detectionId;
        }
    }

    /**
     * 내부 분석 결과 DTO
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RoboflowAnalysisResult {
        private String modelId;
        private List<DetectedObject> detectedObjects;
        private Double averageConfidence;
        private String analysisTime;
        private boolean success;
        private String errorMessage;
        
        @Data
        @NoArgsConstructor
        @AllArgsConstructor
        public static class DetectedObject {
            private String objectType;
            private Double confidence;
            private BoundingBox boundingBox;
            private Map<String, Object> additionalData;
            
            @Data
            @NoArgsConstructor
            @AllArgsConstructor
            public static class BoundingBox {
                private Double x;
                private Double y;
                private Double width;
                private Double height;
            }
        }
    }

    /**
     * 모델 정보 DTO
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ModelInfo {
        private String modelId;
        private String name;
        private String description;
        private List<String> supportedClasses;
        private String endpoint;
        private boolean active;
    }
}
