package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.AiAnalysisResult;
import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.ReportFile;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * AI 분석 결과 리포지토리
 */
@Repository
public interface AiAnalysisResultRepository extends JpaRepository<AiAnalysisResult, Long> {
    
    /**
     * 리포트별 분석 결과 조회
     */
    List<AiAnalysisResult> findByReportOrderByCreatedAtDesc(Report report);
    
    /**
     * 파일별 분석 결과 조회
     */
    List<AiAnalysisResult> findByReportFileOrderByCreatedAtDesc(ReportFile reportFile);
    
    /**
     * 상태별 분석 결과 조회
     */
    List<AiAnalysisResult> findByStatus(AiAnalysisResult.AnalysisStatus status);
    
    /**
     * AI 서비스별 분석 결과 조회
     */
    List<AiAnalysisResult> findByAiService(AiAnalysisResult.AiServiceType aiService);
    
    /**
     * 리포트와 AI 서비스로 최신 분석 결과 조회
     */
    Optional<AiAnalysisResult> findTopByReportAndAiServiceOrderByCreatedAtDesc(
            Report report, AiAnalysisResult.AiServiceType aiService);
    
    /**
     * 파일과 AI 서비스로 최신 분석 결과 조회
     */
    Optional<AiAnalysisResult> findTopByReportFileAndAiServiceOrderByCreatedAtDesc(
            ReportFile reportFile, AiAnalysisResult.AiServiceType aiService);
    
    /**
     * 재시도가 필요한 실패된 분석 결과 조회
     */
    @Query("SELECT a FROM AiAnalysisResult a WHERE a.status = 'FAILED' AND a.retryCount < 3")
    List<AiAnalysisResult> findFailedResultsNeedingRetry();
    
    /**
     * 특정 기간의 분석 결과 조회
     */
    @Query("SELECT a FROM AiAnalysisResult a WHERE a.createdAt BETWEEN :startDate AND :endDate")
    List<AiAnalysisResult> findByCreatedAtBetween(
            @Param("startDate") LocalDateTime startDate, 
            @Param("endDate") LocalDateTime endDate);
    
    /**
     * 신뢰도 점수가 특정 값 이상인 분석 결과 조회
     */
    List<AiAnalysisResult> findByConfidenceScoreGreaterThanEqual(Double minConfidence);
    
    /**
     * 리포트의 성공한 분석 결과 개수
     */
    @Query("SELECT COUNT(a) FROM AiAnalysisResult a WHERE a.report = :report AND a.status = 'COMPLETED'")
    long countSuccessfulAnalysesByReport(@Param("report") Report report);
    
    /**
     * AI 서비스별 성공률 통계
     */
    @Query("SELECT a.aiService, " +
           "COUNT(a) as total, " +
           "SUM(CASE WHEN a.status = 'COMPLETED' THEN 1 ELSE 0 END) as successful " +
           "FROM AiAnalysisResult a " +
           "GROUP BY a.aiService")
    List<Object[]> getSuccessRateByAiService();
    
    /**
     * 평균 처리 시간 통계
     */
    @Query("SELECT AVG(a.processingTimeMs) FROM AiAnalysisResult a WHERE a.status = 'COMPLETED'")
    Double getAverageProcessingTime();
    
    /**
     * AI 서비스별 평균 신뢰도 점수
     */
    @Query("SELECT a.aiService, AVG(a.confidenceScore) " +
           "FROM AiAnalysisResult a " +
           "WHERE a.status = 'COMPLETED' AND a.confidenceScore IS NOT NULL " +
           "GROUP BY a.aiService")
    List<Object[]> getAverageConfidenceByAiService();
    
    /**
     * 특정 리포트의 가장 최근 성공한 분석 결과
     */
    @Query("SELECT a FROM AiAnalysisResult a " +
           "WHERE a.report = :report AND a.status = 'COMPLETED' " +
           "ORDER BY a.createdAt DESC")
    Page<AiAnalysisResult> findLatestSuccessfulByReport(@Param("report") Report report, Pageable pageable);
}