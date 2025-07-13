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
   * 내부 분석 결과 DTO (AI 라우팅용)
   */
  @Data
  @NoArgsConstructor
  @AllArgsConstructor
  public static class AnalysisResult {
    private String modelId;
    private List<DetectedObject> detectedObjects;
    private Double averageConfidence;
    private String analysisTime;
    private boolean success;
    private String errorMessage;
    private String dominantCategory;
    private Double maxConfidence;

    public Double getMaxConfidence() {
      if (detectedObjects == null || detectedObjects.isEmpty()) {
        return 0.0;
      }
      return detectedObjects.stream()
          .mapToDouble(obj -> obj.getConfidence() != null ? obj.getConfidence() : 0.0)
          .max()
          .orElse(0.0);
    }

    public boolean containsCriticalObjects() {
      // TODO: Implement critical object detection logic
      return false;
    }

    public String getDominantCategory() {
      // TODO: Implement dominant category logic
      return "GENERAL";
    }

    public Double getConfidence() {
      return getMaxConfidence();
    }

    public String getDetectedClass() {
      if (detectedObjects == null || detectedObjects.isEmpty()) {
        return "UNKNOWN";
      }
      // Return the class with highest confidence
      return detectedObjects.stream()
          .max((o1, o2) -> Double.compare(
              o1.getConfidence() != null ? o1.getConfidence() : 0.0,
              o2.getConfidence() != null ? o2.getConfidence() : 0.0))
          .map(DetectedObject::getClassName)
          .orElse("UNKNOWN");
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DetectedObject {
      private String objectType;
      private Double confidence;
      private BoundingBox boundingBox;
      private Map<String, Object> additionalData;

      public String getClassName() {
        return objectType;
      }

      public void setClassName(String className) {
        this.objectType = className;
      }

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

      public String getClassName() {
        return objectType;
      }

      public void setClassName(String className) {
        this.objectType = className;
      }

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