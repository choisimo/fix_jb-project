package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Google AutoML Vision 객체 탐지 결과 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AutoMLObjectDetectionResult {
    
    /**
     * 객체 탐지 결과 목록
     */
    private List<ObjectDetectionPrediction> detections;
    
    /**
     * 사용된 모델 ID
     */
    private String modelId;
    
    /**
     * 처리 시간 (밀리초)
     */
    private Long processingTime;
    
    /**
     * 분석 수행 시간
     */
    private LocalDateTime timestamp;
    
    /**
     * 신뢰도 임계값
     */
    private Float confidenceThreshold;
    
    /**
     * 탐지된 객체 개수
     */
    public int getDetectionCount() {
        return detections != null ? detections.size() : 0;
    }
    
    /**
     * 최고 신뢰도 탐지 객체 반환
     */
    public ObjectDetectionPrediction getTopDetection() {
        return detections != null && !detections.isEmpty() ? detections.get(0) : null;
    }
    
    /**
     * 특정 카테고리의 탐지 객체들만 필터링
     */
    public List<ObjectDetectionPrediction> getDetectionsByCategory(String category) {
        return detections != null ? 
            detections.stream()
                .filter(d -> category.equals(d.getCategory()))
                .toList() : 
            List.of();
    }
    
    /**
     * 평균 신뢰도 계산
     */
    public Float getAverageConfidence() {
        if (detections == null || detections.isEmpty()) {
            return 0.0f;
        }
        return (float) detections.stream()
            .mapToDouble(ObjectDetectionPrediction::getConfidence)
            .average()
            .orElse(0.0);
    }
}