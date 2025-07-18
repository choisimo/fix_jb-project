package com.jeonbuk.report.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.jeonbuk.report.domain.entity.ReportCategory;
import com.jeonbuk.report.domain.entity.Report;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * AI 분석 응답 DTO
 */
@Data
@Builder
public class AIAnalysisResponse {

    /**
     * 분석 성공 여부
     */
    @Builder.Default
    private Boolean success = true;

    /**
     * 오류 메시지 (실패시)
     */
    private String errorMessage;

    /**
     * 감지된 객체 목록
     */
    private List<DetectedObjectDto> detections;

    /**
     * 평균 신뢰도
     */
    private Double averageConfidence;

    /**
     * 처리 시간 (밀리초)
     */
    private Long processingTime;

    /**
     * 분석 타임스탬프
     */
    @Builder.Default
    private LocalDateTime timestamp = LocalDateTime.now();

    /**
     * 작업 ID (비동기 처리용)
     */
    private String jobId;

    /**
     * 추천 카테고리
     */
    private ReportCategory recommendedCategory;

    /**
     * 추천 우선순위
     */
    private Report.Priority recommendedPriority;

    /**
     * 추천 담당 부서
     */
    private String recommendedDepartment;

    /**
     * 분석 요약
     */
    private String summary;

    /**
     * 원시 Roboflow 응답 (디버깅용)
     */
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private Object rawResponse;
    
    /**
     * OCR 텍스트
     */
    private String ocrText;
    
    /**
     * 분석 결과 본문
     */
    private String analysisResult;
    
    /**
     * 분석 결과 가져오기 (summary와 동일한 용도로 사용)
     */
    public String getAnalysisResult() {
        return analysisResult != null ? analysisResult : summary;
    }
    
    /**
     * 감지된 객체 목록 설정
     * @param objects 감지된 객체 목록
     * @return 현재 응답 객체 (빌더 패턴)
     */
    public AIAnalysisResponse detectedObjects(List<String> objects) {
        List<DetectedObjectDto> detectionsList = new ArrayList<>();
        if (objects != null) {
            for (String obj : objects) {
                detectionsList.add(DetectedObjectDto.builder()
                    .className(obj)
                    .koreanName(obj)
                    .confidence(0.8)
                    .build());
            }
            this.detections = detectionsList;
        }
        return this;
    }
    
    /**
     * 감지된 객체 목록의 이름만 추출
     */
    public List<String> getDetectedObjects() {
        if (detections == null) {
            return Collections.emptyList();
        }
        List<String> objects = new ArrayList<>();
        for (DetectedObjectDto detection : detections) {
            objects.add(detection.getKoreanName() != null ? 
                       detection.getKoreanName() : detection.getClassName());
        }
        return objects;
    }
    
    /**
     * 신뢰도 반환
     */
    public float getConfidence() {
        return averageConfidence != null ? averageConfidence.floatValue() : 0.7f;
    }
    
    /**
     * OCR 텍스트 반환
     */
    public String getOcrText() {
        return ocrText;
    }

    /**
     * 감지된 객체 DTO
     */
    @Data
    @Builder
    public static class DetectedObjectDto {

        /**
         * 영문 클래스명
         */
        private String className;

        /**
         * 한국어 클래스명
         */
        private String koreanName;

        /**
         * 신뢰도 (0-100)
         */
        private Double confidence;

        /**
         * 바운딩 박스 정보
         */
        private BoundingBoxDto boundingBox;

        /**
         * 카테고리
         */
        private ReportCategory category;

        /**
         * 우선순위
         */
        private Report.Priority priority;
    }

    /**
     * 바운딩 박스 DTO
     */
    @Data
    @Builder
    public static class BoundingBoxDto {

        /**
         * 중심점 X 좌표
         */
        private Double x;

        /**
         * 중심점 Y 좌표
         */
        private Double y;

        /**
         * 너비
         */
        private Double width;

        /**
         * 높이
         */
        private Double height;

        /**
         * 왼쪽 상단 X 좌표
         */
        public Double getLeft() {
            return x - (width / 2);
        }

        /**
         * 왼쪽 상단 Y 좌표
         */
        public Double getTop() {
            return y - (height / 2);
        }

        /**
         * 오른쪽 하단 X 좌표
         */
        public Double getRight() {
            return x + (width / 2);
        }

        /**
         * 오른쪽 하단 Y 좌표
         */
        public Double getBottom() {
            return y + (height / 2);
        }
    }
}
