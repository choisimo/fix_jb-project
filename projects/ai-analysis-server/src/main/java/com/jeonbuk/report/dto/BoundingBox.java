package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 바운딩 박스 정보 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BoundingBox {
    
    /**
     * 좌상단 X 좌표 (정규화된 값: 0.0 ~ 1.0)
     */
    private Float x;
    
    /**
     * 좌상단 Y 좌표 (정규화된 값: 0.0 ~ 1.0)
     */
    private Float y;
    
    /**
     * 박스 너비 (정규화된 값: 0.0 ~ 1.0)
     */
    private Float width;
    
    /**
     * 박스 높이 (정규화된 값: 0.0 ~ 1.0)
     */
    private Float height;
    
    /**
     * 픽셀 기준 좌표로 변환
     */
    public BoundingBox toPixelCoordinates(int imageWidth, int imageHeight) {
        return BoundingBox.builder()
            .x(x * imageWidth)
            .y(y * imageHeight)
            .width(width * imageWidth)
            .height(height * imageHeight)
            .build();
    }
    
    /**
     * 중심점 X 좌표 계산
     */
    public Float getCenterX() {
        return x + width / 2;
    }
    
    /**
     * 중심점 Y 좌표 계산
     */
    public Float getCenterY() {
        return y + height / 2;
    }
    
    /**
     * 면적 계산
     */
    public Float getArea() {
        return width * height;
    }
    
    /**
     * 우하단 X 좌표
     */
    public Float getEndX() {
        return x + width;
    }
    
    /**
     * 우하단 Y 좌표
     */
    public Float getEndY() {
        return y + height;
    }
}