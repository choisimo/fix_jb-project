package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 이미지 분류 예측 결과 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClassificationPrediction {
    
    /**
     * 예측된 라벨
     */
    private String label;
    
    /**
     * 신뢰도 (0.0 ~ 1.0)
     */
    private Float confidence;
    
    /**
     * 카테고리 (ROAD_DAMAGE, WASTE_MANAGEMENT, VANDALISM 등)
     */
    private String category;
    
    /**
     * 예측 상세 설명
     */
    private String description;
    
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
            case "pothole_damage", "pothole" -> "포트홀 손상";
            case "surface_crack", "crack" -> "표면 균열";
            case "pavement_deterioration" -> "포장도로 노화";
            case "trash_accumulation", "garbage" -> "쓰레기 집적";
            case "illegal_dumping" -> "불법 투기";
            case "graffiti" -> "낙서";
            case "vandalism" -> "기물 파손";
            case "streetlight_malfunction" -> "가로등 고장";
            case "construction_site" -> "공사 현장";
            default -> label;
        };
    }
    
    /**
     * 한국어 카테고리 반환
     */
    public String getKoreanCategory() {
        return switch (category) {
            case "ROAD_DAMAGE" -> "도로 손상";
            case "WASTE_MANAGEMENT" -> "폐기물 관리";
            case "VANDALISM" -> "기물 파손";
            case "STREET_LIGHTING" -> "가로등 시설";
            case "CONSTRUCTION" -> "공사 관련";
            case "GENERAL_INFRASTRUCTURE" -> "일반 시설";
            default -> category;
        };
    }
}