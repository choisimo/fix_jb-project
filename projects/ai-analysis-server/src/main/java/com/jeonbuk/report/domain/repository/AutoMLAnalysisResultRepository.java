package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.AutoMLAnalysisResult;
import com.jeonbuk.report.dto.AutoMLClassificationResult;
import com.jeonbuk.report.dto.AutoMLObjectDetectionResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * AutoML 분석 결과 Repository
 */
@Repository
public interface AutoMLAnalysisResultRepository extends JpaRepository<AutoMLAnalysisResult, UUID> {

    /**
     * 신고서 ID로 분석 결과 조회
     */
    List<AutoMLAnalysisResult> findByReportIdOrderByCreatedAtDesc(UUID reportId);

    /**
     * 신고서 ID의 최신 분석 결과 조회
     */
    Optional<AutoMLAnalysisResult> findFirstByReportIdOrderByCreatedAtDesc(UUID reportId);

    /**
     * 모델 ID로 분석 결과 조회
     */
    List<AutoMLAnalysisResult> findByModelIdOrderByCreatedAtDesc(UUID modelId);

    /**
     * 분석 타입별 조회
     */
    List<AutoMLAnalysisResult> findByAnalysisTypeOrderByCreatedAtDesc(String analysisType);

    /**
     * 신뢰도 범위로 필터링
     */
    @Query("SELECT ar FROM AutoMLAnalysisResult ar WHERE " +
           "ar.confidence BETWEEN :minConfidence AND :maxConfidence " +
           "ORDER BY ar.confidence DESC, ar.createdAt DESC")
    List<AutoMLAnalysisResult> findByConfidenceRange(@Param("minConfidence") float minConfidence,
                                                    @Param("maxConfidence") float maxConfidence);

    /**
     * 성공한 분석 결과만 조회
     */
    @Query("SELECT ar FROM AutoMLAnalysisResult ar WHERE ar.status = 'SUCCESS' " +
           "ORDER BY ar.createdAt DESC")
    List<AutoMLAnalysisResult> findSuccessfulAnalyses();

    /**
     * 특정 기간의 분석 결과 조회
     */
    @Query("SELECT ar FROM AutoMLAnalysisResult ar WHERE " +
           "ar.createdAt BETWEEN :startDate AND :endDate " +
           "ORDER BY ar.createdAt DESC")
    List<AutoMLAnalysisResult> findByDateRange(@Param("startDate") LocalDateTime startDate,
                                             @Param("endDate") LocalDateTime endDate);

    /**
     * 모델별 성능 통계
     */
    @Query("SELECT ar.modelId, ar.analysisType, " +
           "COUNT(*) as total_count, " +
           "AVG(ar.confidence) as avg_confidence, " +
           "AVG(ar.processingTimeMs) as avg_processing_time " +
           "FROM AutoMLAnalysisResult ar " +
           "WHERE ar.status = 'SUCCESS' " +
           "GROUP BY ar.modelId, ar.analysisType")
    List<Object[]> getModelPerformanceStats();

    /**
     * 일별 분석 통계
     */
    @Query(value = """
        SELECT 
            DATE_TRUNC('day', created_at) as analysis_date,
            analysis_type,
            COUNT(*) as total_analyses,
            AVG(confidence) as avg_confidence,
            AVG(processing_time_ms) as avg_processing_time,
            COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as success_count,
            COUNT(CASE WHEN status = 'FAILED' THEN 1 END) as failure_count
        FROM automl_analysis_results
        WHERE created_at >= :fromDate
        GROUP BY DATE_TRUNC('day', created_at), analysis_type
        ORDER BY analysis_date DESC, analysis_type
        """, nativeQuery = true)
    List<Object[]> getDailyAnalysisStats(@Param("fromDate") LocalDateTime fromDate);

    /**
     * 최고 성능 분석 결과 조회
     */
    @Query("SELECT ar FROM AutoMLAnalysisResult ar WHERE " +
           "ar.status = 'SUCCESS' " +
           "ORDER BY ar.confidence DESC, ar.processingTimeMs ASC")
    List<AutoMLAnalysisResult> findTopPerformingAnalyses(@Param("maxResults") int maxResults);

    /**
     * 실패한 분석 결과 조회 (디버깅용)
     */
    @Query("SELECT ar FROM AutoMLAnalysisResult ar WHERE ar.status = 'FAILED' " +
           "ORDER BY ar.createdAt DESC")
    List<AutoMLAnalysisResult> findFailedAnalyses();

    /**
     * 모델 사용 빈도 조회
     */
    @Query("SELECT ar.modelId, ar.analysisType, COUNT(*) as usage_count " +
           "FROM AutoMLAnalysisResult ar " +
           "GROUP BY ar.modelId, ar.analysisType " +
           "ORDER BY usage_count DESC")
    List<Object[]> getModelUsageStats();
}