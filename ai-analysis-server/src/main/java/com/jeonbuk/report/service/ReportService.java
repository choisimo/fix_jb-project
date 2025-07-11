package com.jeonbuk.report.service;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.domain.repository.ReportRepository;
import com.jeonbuk.report.dto.common.PageRequestDto;
import com.jeonbuk.report.dto.common.PageResponse;
import com.jeonbuk.report.dto.common.ReportSearchCondition;
import com.jeonbuk.report.dto.report.ReportCreateRequest;
import com.jeonbuk.report.dto.report.ReportUpdateRequest;
import com.jeonbuk.report.dto.report.ReportDetailResponse;
import com.jeonbuk.report.dto.report.ReportStatisticsResponse;
import com.jeonbuk.report.dto.report.ReportSummaryResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 신고서 서비스
 */
@Service
@Slf4j
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReportService {

  private final ReportRepository reportRepository;

  /**
   * 신고서 생성
   */
  @Transactional
  public ReportDetailResponse createReport(ReportCreateRequest request, String username) {
    // TODO: 실제 구현
    log.info("Creating report: {}", request.title());
    throw new UnsupportedOperationException("Not implemented yet");
  }

  /**
   * 신고서 목록 조회
   */
  public PageResponse<ReportSummaryResponse> getReports(ReportSearchCondition condition, PageRequestDto pageRequest) {
    // TODO: 실제 구현
    log.info("Getting reports with condition: {}", condition);
    throw new UnsupportedOperationException("Not implemented yet");
  }

  /**
   * 신고서 상세 조회
   */
  public ReportDetailResponse getReport(UUID reportId) {
    // TODO: 실제 구현
    log.info("Getting report: {}", reportId);
    throw new UnsupportedOperationException("Not implemented yet");
  }

  /**
   * 신고서 수정
   */
  @Transactional
  public ReportDetailResponse updateReport(UUID reportId, ReportUpdateRequest request, String username) {
    // TODO: 실제 구현
    log.info("Updating report: {}", reportId);
    throw new UnsupportedOperationException("Not implemented yet");
  }

  /**
   * 신고서 삭제
   */
  @Transactional
  public void deleteReport(UUID reportId, String username) {
    // TODO: 실제 구현
    log.info("Deleting report: {}", reportId);
    throw new UnsupportedOperationException("Not implemented yet");
  }

  /**
   * 내 신고서 목록 조회
   */
  public PageResponse<ReportSummaryResponse> getMyReports(String username, PageRequestDto pageRequest) {
    // TODO: 실제 구현
    log.info("Getting my reports for user: {}", username);
    throw new UnsupportedOperationException("Not implemented yet");
  }

  /**
   * 신고서 통계
   */
  public ReportStatisticsResponse getStatistics() {
    // TODO: 실제 구현
    log.info("Getting report statistics");
    throw new UnsupportedOperationException("Not implemented yet");
  }

  /**
   * 신고서 상태 변경
   */
  @Transactional
  public void updateReportStatus(UUID reportId, String status, String username) {
    // TODO: 실제 구현
    log.info("Updating report status: {} to {}", reportId, status);
    throw new UnsupportedOperationException("Not implemented yet");
  }

  /**
   * 신고서 제출
   */
  @Transactional
  public void submitReport(UUID reportId, String username) {
    // TODO: 실제 구현
    log.info("Submitting report: {}", reportId);
    throw new UnsupportedOperationException("Not implemented yet");
  }
}
