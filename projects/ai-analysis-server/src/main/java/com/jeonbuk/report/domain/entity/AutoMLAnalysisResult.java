package com.jeonbuk.report.domain.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * AutoML 분석 결과 엔티티
 */
@Entity
@Table(name = "automl_analysis_results")
public class AutoMLAnalysisResult {
    @Id
    @GeneratedValue
    private UUID id;
    
    @Column(name = "report_id")
    private UUID reportId;
    
    @Column(name = "model_id")
    private UUID modelId;
    
    @Column(name = "analysis_type")
    private String analysisType;
    
    @Column(name = "predictions", columnDefinition = "jsonb")
    private String predictions;
    
    @Column(name = "top_prediction", columnDefinition = "jsonb")
    private String topPrediction;
    
    @Column(name = "confidence")
    private Float confidence;
    
    @Column(name = "processing_time_ms")
    private Long processingTimeMs;
    
    @Column(name = "model_version")
    private String modelVersion;
    
    @Column(name = "image_metadata", columnDefinition = "jsonb")
    private String imageMetadata;
    
    @Column(name = "analysis_metadata", columnDefinition = "jsonb")
    private String analysisMetadata;
    
    @Column(name = "status")
    private String status;
    
    @Column(name = "error_message")
    private String errorMessage;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public AutoMLAnalysisResult() {}
    
    // 편의 메서드들
    public boolean isSuccessful() {
        return "SUCCESS".equals(status);
    }
    
    public boolean isClassification() {
        return "CLASSIFICATION".equals(analysisType);
    }
    
    public boolean isObjectDetection() {
        return "OBJECT_DETECTION".equals(analysisType);
    }
    
    public boolean isHybrid() {
        return "HYBRID".equals(analysisType);
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    
    public UUID getReportId() { return reportId; }
    public void setReportId(UUID reportId) { this.reportId = reportId; }
    
    public UUID getModelId() { return modelId; }
    public void setModelId(UUID modelId) { this.modelId = modelId; }
    
    public String getAnalysisType() { return analysisType; }
    public void setAnalysisType(String analysisType) { this.analysisType = analysisType; }
    
    public String getPredictions() { return predictions; }
    public void setPredictions(String predictions) { this.predictions = predictions; }
    
    public String getTopPrediction() { return topPrediction; }
    public void setTopPrediction(String topPrediction) { this.topPrediction = topPrediction; }
    
    public Float getConfidence() { return confidence; }
    public void setConfidence(Float confidence) { this.confidence = confidence; }
    
    public Long getProcessingTimeMs() { return processingTimeMs; }
    public void setProcessingTimeMs(Long processingTimeMs) { this.processingTimeMs = processingTimeMs; }
    
    public String getModelVersion() { return modelVersion; }
    public void setModelVersion(String modelVersion) { this.modelVersion = modelVersion; }
    
    public String getImageMetadata() { return imageMetadata; }
    public void setImageMetadata(String imageMetadata) { this.imageMetadata = imageMetadata; }
    
    public String getAnalysisMetadata() { return analysisMetadata; }
    public void setAnalysisMetadata(String analysisMetadata) { this.analysisMetadata = analysisMetadata; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
