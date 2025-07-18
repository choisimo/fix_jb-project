package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Google AutoML Vision 이미지 분류 결과 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AutoMLClassificationResult {
    
    /**
     * 분류 예측 결과 목록
     */
    private List<ClassificationPrediction> predictions;
    
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
     * 하이브리드 분석 결과 여부 (분류 + 객체탐지 통합)
     */
    @Builder.Default
    private Boolean isHybridResult = false;
    
    /**
     * 최고 신뢰도 예측 반환
     */
    public ClassificationPrediction getTopPrediction() {
        return predictions != null && !predictions.isEmpty() ? predictions.get(0) : null;
    }
    
    /**
     * 특정 카테고리의 예측들만 필터링
     */
    public List<ClassificationPrediction> getPredictionsByCategory(String category) {
        return predictions != null ? 
            predictions.stream()
                .filter(p -> category.equals(p.getCategory()))
                .toList() : 
            List.of();
    }
    
    /**
     * 평균 신뢰도 계산
     */
    public Float getAverageConfidence() {
        if (predictions == null || predictions.isEmpty()) {
            return 0.0f;
        }
        return (float) predictions.stream()
            .mapToDouble(ClassificationPrediction::getConfidence)
            .average()
            .orElse(0.0);
    }
}