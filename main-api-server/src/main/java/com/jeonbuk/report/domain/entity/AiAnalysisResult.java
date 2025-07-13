package com.jeonbuk.report.domain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * AI 분석 결과 엔티티
 * AI 서비스의 분석 결과를 저장하는 엔티티
 */
@Entity
@Table(name = "ai_analysis_results", indexes = {
    @Index(name = "idx_ai_analysis_report_id", columnList = "report_id"),
    @Index(name = "idx_ai_analysis_file_id", columnList = "report_file_id"),
    @Index(name = "idx_ai_analysis_status", columnList = "status"),
    @Index(name = "idx_ai_analysis_service", columnList = "ai_service"),
    @Index(name = "idx_ai_analysis_created_at", columnList = "created_at")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiAnalysisResult {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 분석 대상 리포트
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "report_id", nullable = false)
    private Report report;
    
    /**
     * 분석 대상 파일 (옵션)
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "report_file_id")
    private ReportFile reportFile;
    
    /**
     * 사용된 AI 서비스
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "ai_service", nullable = false, length = 50)
    private AiServiceType aiService;
    
    /**
     * AI 서비스의 원본 응답 (JSON)
     */
    @Column(name = "raw_response", columnDefinition = "TEXT")
    private String rawResponse;
    
    /**
     * 파싱된 분석 결과 (JSON)
     */
    @Column(name = "parsed_result", columnDefinition = "TEXT")
    private String parsedResult;
    
    /**
     * 분석 상태
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private AnalysisStatus status;
    
    /**
     * 신뢰도 점수
     */
    @Column(name = "confidence_score")
    private Double confidenceScore;
    
    /**
     * 오류 메시지 (실패 시)
     */
    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;
    
    /**
     * 처리 시간 (밀리초)
     */
    @Column(name = "processing_time_ms")
    private Long processingTimeMs;
    
    /**
     * 재시도 횟수
     */
    @Column(name = "retry_count", nullable = false)
    @Builder.Default
    private Integer retryCount = 0;
    
    /**
     * 생성 시간
     */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    /**
     * 수정 시간
     */
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * AI 서비스 타입
     */
    public enum AiServiceType {
        ROBOFLOW,
        OPENROUTER,
        OPENAI,
        CUSTOM
    }
    
    /**
     * 분석 상태
     */
    public enum AnalysisStatus {
        PENDING,    // 대기 중
        PROCESSING, // 처리 중
        COMPLETED,  // 완료
        FAILED,     // 실패
        RETRYING    // 재시도 중
    }
    
    /**
     * 분석이 성공했는지 확인
     */
    public boolean isSuccessful() {
        return status == AnalysisStatus.COMPLETED;
    }
    
    /**
     * 분석이 실패했는지 확인
     */
    public boolean isFailed() {
        return status == AnalysisStatus.FAILED;
    }
    
    /**
     * 재시도가 필요한지 확인
     */
    public boolean needsRetry() {
        return status == AnalysisStatus.FAILED && retryCount < 3;
    }
}