package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 객체 탐지 예측 결과 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ObjectDetectionPrediction {
    
    /**
     * 탐지된 객체 라벨
     */
    private String label;
    
    /**
     * 신뢰도 (0.0 ~ 1.0)
     */
    private Float confidence;
    
    /**
     * 객체 카테고리
     */
    private String category;
    
    /**
     * 바운딩 박스 정보
     */
    private BoundingBox boundingBox;
    
    /**
     * 객체 크기 (이미지 대비 비율)
     */
    private Float objectSize;
    
    /**
     * 신뢰도를 백분율로 반환
     */
    public String getConfidencePercentage() {
        return String.format("%.1f%%", confidence * 100);
    }
    
    /**
     * 한국어 라벨 반환
     */
    public String getKoreanLabel() {
        return switch (label) {
            case "pothole" -> "포트홀";
            case "crack" -> "균열";
            case "trash", "garbage" -> "쓰레기";
            case "graffiti" -> "낙서";
            case "streetlight" -> "가로등";
            case "construction_equipment" -> "공사 장비";
            case "damaged_pavement" -> "손상된 포장도로";
            case "manhole_cover" -> "맨홀 뚜껑";
            default -> label;
        };
    }
    
    /**
     * 객체 크기 계산 (바운딩 박스 기반)
     */
    public Float calculateObjectSize() {
        if (boundingBox == null) {
            return 0.0f;
        }
        return boundingBox.getWidth() * boundingBox.getHeight();
    }
}