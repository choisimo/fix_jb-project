package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.AiAnalysisResult;
import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.ReportFile;
import com.jeonbuk.report.domain.repository.AiAnalysisResultRepository;
import com.jeonbuk.report.domain.repository.ReportRepository;
import com.jeonbuk.report.domain.repository.ReportFileRepository;
import com.jeonbuk.report.presentation.dto.request.AiAnalysisResultCreateRequest;
import com.jeonbuk.report.presentation.dto.response.AiAnalysisResultResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.UUID;

/**
 * AI 분석 결과 서비스
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class AiAnalysisResultService {
    
    private final AiAnalysisResultRepository aiAnalysisResultRepository;
    private final ReportRepository reportRepository;
    private final ReportFileRepository reportFileRepository;
    
    /**
     * AI 분석 결과 생성
     */
    @Transactional
    public AiAnalysisResultResponse createAnalysisResult(AiAnalysisResultCreateRequest request) {
        log.info("Creating AI analysis result for report: {}", request.getReportId());
        
        // 리포트 조회
        Report report = reportRepository.findById(UUID.fromString(request.getReportId()))
                .orElseThrow(() -> new IllegalArgumentException("리포트를 찾을 수 없습니다: " + request.getReportId()));
        
        // 리포트 파일 조회 (옵션)
        ReportFile reportFile = null;
        if (request.getReportFileId() != null) {
            reportFile = reportFileRepository.findById(UUID.fromString(request.getReportFileId()))
                    .orElseThrow(() -> new IllegalArgumentException("리포트 파일을 찾을 수 없습니다: " + request.getReportFileId()));
        }
        
        // 엔티티 생성
        AiAnalysisResult entity = request.toEntity();
        entity.setReport(report);
        entity.setReportFile(reportFile);
        
        // 저장
        AiAnalysisResult saved = aiAnalysisResultRepository.save(entity);
        
        log.info("AI analysis result created with ID: {}", saved.getId());
        return AiAnalysisResultResponse.from(saved);
    }
    
    /**
     * 리포트별 분석 결과 조회
     */
    public List<AiAnalysisResultResponse> getAnalysisResultsByReport(String reportId) {
        Report report = reportRepository.findById(UUID.fromString(reportId))
                .orElseThrow(() -> new IllegalArgumentException("리포트를 찾을 수 없습니다: " + reportId));
        
        return aiAnalysisResultRepository.findByReportOrderByCreatedAtDesc(report)
                .stream()
                .map(AiAnalysisResultResponse::from)
                .collect(Collectors.toList());
    }
    
    /**
     * 파일별 분석 결과 조회
     */
    public List<AiAnalysisResultResponse> getAnalysisResultsByFile(String fileId) {
        ReportFile reportFile = reportFileRepository.findById(UUID.fromString(fileId))
                .orElseThrow(() -> new IllegalArgumentException("리포트 파일을 찾을 수 없습니다: " + fileId));
        
        return aiAnalysisResultRepository.findByReportFileOrderByCreatedAtDesc(reportFile)
                .stream()
                .map(AiAnalysisResultResponse::from)
                .collect(Collectors.toList());
    }
    
    /**
     * 최신 성공 분석 결과 조회
     */
    public Optional<AiAnalysisResultResponse> getLatestSuccessfulResult(String reportId, AiAnalysisResult.AiServiceType aiService) {
        Report report = reportRepository.findById(UUID.fromString(reportId))
                .orElseThrow(() -> new IllegalArgumentException("리포트를 찾을 수 없습니다: " + reportId));
        
        return aiAnalysisResultRepository.findTopByReportAndAiServiceOrderByCreatedAtDesc(report, aiService)
                .filter(result -> result.getStatus() == AiAnalysisResult.AnalysisStatus.COMPLETED)
                .map(AiAnalysisResultResponse::from);
    }
    
    /**
     * 재시도가 필요한 실패 결과 조회
     */
    public List<AiAnalysisResultResponse> getFailedResultsNeedingRetry() {
        return aiAnalysisResultRepository.findFailedResultsNeedingRetry()
                .stream()
                .map(AiAnalysisResultResponse::from)
                .collect(Collectors.toList());
    }
    
    /**
     * 분석 결과 상태 업데이트
     */
    @Transactional
    public void updateAnalysisStatus(Long analysisId, AiAnalysisResult.AnalysisStatus status, String errorMessage) {
        AiAnalysisResult result = aiAnalysisResultRepository.findById(analysisId)
                .orElseThrow(() -> new IllegalArgumentException("분석 결과를 찾을 수 없습니다: " + analysisId));
        
        result.setStatus(status);
        if (errorMessage != null) {
            result.setErrorMessage(errorMessage);
        }
        
        aiAnalysisResultRepository.save(result);
        log.info("Updated analysis result {} status to {}", analysisId, status);
    }
    
    /**
     * 재시도 횟수 증가
     */
    @Transactional
    public void incrementRetryCount(Long analysisId) {
        AiAnalysisResult result = aiAnalysisResultRepository.findById(analysisId)
                .orElseThrow(() -> new IllegalArgumentException("분석 결과를 찾을 수 없습니다: " + analysisId));
        
        result.setRetryCount(result.getRetryCount() + 1);
        result.setStatus(AiAnalysisResult.AnalysisStatus.RETRYING);
        
        aiAnalysisResultRepository.save(result);
        log.info("Incremented retry count for analysis result {} to {}", analysisId, result.getRetryCount());
    }
    
    /**
     * AI 서비스별 성공률 통계
     */
    public List<Object[]> getSuccessRateByAiService() {
        return aiAnalysisResultRepository.getSuccessRateByAiService();
    }
    
    /**
     * 평균 처리 시간 조회
     */
    public Double getAverageProcessingTime() {
        return aiAnalysisResultRepository.getAverageProcessingTime();
    }
    
    /**
     * 특정 기간의 분석 결과 조회
     */
    public List<AiAnalysisResultResponse> getAnalysisResultsByPeriod(LocalDateTime startDate, LocalDateTime endDate) {
        return aiAnalysisResultRepository.findByCreatedAtBetween(startDate, endDate)
                .stream()
                .map(AiAnalysisResultResponse::from)
                .collect(Collectors.toList());
    }
}