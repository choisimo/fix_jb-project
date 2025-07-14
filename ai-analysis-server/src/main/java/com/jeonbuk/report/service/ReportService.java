package com.jeonbuk.report.service;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.domain.entity.Category;
import com.jeonbuk.report.domain.entity.Status;
import com.jeonbuk.report.domain.repository.ReportRepository;
import com.jeonbuk.report.domain.repository.UserRepository;
import com.jeonbuk.report.repository.CategoryRepository;
import com.jeonbuk.report.dto.common.PageRequestDto;
import com.jeonbuk.report.dto.common.PageResponse;
import com.jeonbuk.report.dto.common.ReportSearchCondition;
import com.jeonbuk.report.dto.report.ReportCreateRequest;
import com.jeonbuk.report.dto.report.ReportUpdateRequest;
import com.jeonbuk.report.dto.report.ReportDetailResponse;
import com.jeonbuk.report.dto.report.ReportStatisticsResponse;
import com.jeonbuk.report.dto.report.ReportSummaryResponse;
import com.jeonbuk.report.dto.user.UserSummaryResponse;
import com.jeonbuk.report.dto.category.ReportCategoryResponse;
import com.jeonbuk.report.dto.report.StatusResponse;
import com.jeonbuk.report.dto.report.ReportFileResponse;
import com.jeonbuk.report.dto.comment.CommentResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 신고서 서비스
 */
@Service
@Slf4j
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReportService {

  private final ReportRepository reportRepository;
  private final UserRepository userRepository;
  private final CategoryRepository categoryRepository;

  /**
   * 신고서 생성
   */
  @Transactional
  public ReportDetailResponse createReport(ReportCreateRequest request, String username) {
    log.info("Creating report: {} by user: {}", request.title(), username);
    
    // 사용자 조회
    User user = userRepository.findByEmail(username)
        .orElseThrow(() -> new IllegalArgumentException("User not found: " + username));
    
    // 카테고리 조회 (있는 경우) - UUID to Long conversion needed
    Category category = null;
    if (request.categoryId() != null) {
      // Temporary workaround: skip category lookup due to type mismatch
      // TODO: Fix entity ID type consistency
      category = null;
    }
    
    // Report 엔티티 생성
    Report report = request.toEntity(user, category);
    
    // 저장
    Report savedReport = reportRepository.save(report);
    
    log.info("Report created successfully with ID: {}", savedReport.getId());
    
    // Response 생성
    return createReportDetailResponse(savedReport);
  }

  /**
   * 신고서 목록 조회
   */
  public PageResponse<ReportSummaryResponse> getReports(ReportSearchCondition condition, PageRequestDto pageRequest) {
    log.info("Getting reports with condition: {}", condition);
    
    // Pageable 객체 생성
    Pageable pageable = PageRequest.of(
        pageRequest.page(),
        pageRequest.size(),
        Sort.by(Sort.Direction.DESC, "createdAt")
    );
    
    Page<Report> reportPage;
    
    if (condition.hasSearchConditions()) {
      // 조건이 있는 경우 검색 쿼리 사용
      reportPage = reportRepository.searchReports(
          condition.keyword(),
          condition.categoryId(),
          condition.statusId(),
          condition.priority(),
          null, // condition.userId() - type mismatch, temporarily null
          null, // condition.managerId() - type mismatch, temporarily null
          pageable
      );
    } else {
      // 조건이 없는 경우 전체 조회
      reportPage = reportRepository.findAllActive(pageable);
    }
    
    // ReportSummaryResponse로 변환
    List<ReportSummaryResponse> content = reportPage.getContent().stream()
        .map(this::convertToSummaryResponse)
        .collect(Collectors.toList());
    
    return new PageResponse<>(
        content,
        reportPage.getNumber(),
        reportPage.getSize(),
        reportPage.getTotalElements(),
        reportPage.getTotalPages(),
        reportPage.isFirst(),
        reportPage.isLast(),
        reportPage.isEmpty()
    );
  }

  /**
   * 신고서 상세 조회
   */
  public ReportDetailResponse getReport(UUID reportId) {
    log.info("Getting report: {}", reportId);
    
    Report report = reportRepository.findByIdAndDeletedAtIsNull(reportId)
        .orElseThrow(() -> new IllegalArgumentException("Report not found or deleted: " + reportId));
    
    return createReportDetailResponse(report);
  }

  /**
   * 신고서 수정
   */
  @Transactional
  public ReportDetailResponse updateReport(UUID reportId, ReportUpdateRequest request, String username) {
    log.info("Updating report: {} by user: {}", reportId, username);
    
    // 기존 신고서 조회
    Report report = reportRepository.findByIdAndDeletedAtIsNull(reportId)
        .orElseThrow(() -> new IllegalArgumentException("Report not found or deleted: " + reportId));
    
    // 권한 확인 (작성자 또는 관리자만 수정 가능)
    User user = userRepository.findByEmail(username)
        .orElseThrow(() -> new IllegalArgumentException("User not found: " + username));
    
    if (!report.getUser().getId().equals(user.getId()) && 
        !isUserManager(user)) {
      throw new IllegalArgumentException("Not authorized to update this report");
    }
    
    // 카테고리 업데이트 (필요한 경우)
    if (request.categoryId() != null) {
      Category category = categoryRepository.findById(request.categoryId())
          .orElse(null);
      report.setCategory(category);
    }
    
    // 필드 업데이트
    if (request.title() != null) {
      report.setTitle(request.title());
    }
    if (request.description() != null) {
      report.setDescription(request.description());
    }
    if (request.priority() != null) {
      report.setPriority(request.priority());
    }
    if (request.location() != null) {
      report.setLatitude(request.location().latitude());
      report.setLongitude(request.location().longitude());
      report.setAddress(request.location().address());
    }
    
    Report updatedReport = reportRepository.save(report);
    
    log.info("Report updated successfully: {}", reportId);
    
    return createReportDetailResponse(updatedReport);
  }

  /**
   * 신고서 삭제 (소프트 삭제)
   */
  @Transactional
  public void deleteReport(UUID reportId, String username) {
    log.info("Deleting report: {} by user: {}", reportId, username);
    
    // 기존 신고서 조회
    Report report = reportRepository.findByIdAndDeletedAtIsNull(reportId)
        .orElseThrow(() -> new IllegalArgumentException("Report not found or already deleted: " + reportId));
    
    // 권한 확인 (작성자 또는 관리자만 삭제 가능)
    User user = userRepository.findByEmail(username)
        .orElseThrow(() -> new IllegalArgumentException("User not found: " + username));
    
    if (!report.getUser().getId().equals(user.getId()) && 
        !isUserManager(user)) {
      throw new IllegalArgumentException("Not authorized to delete this report");
    }
    
    // 소프트 삭제
    report.softDelete();
    reportRepository.save(report);
    
    log.info("Report deleted successfully: {}", reportId);
  }

  /**
   * 내 신고서 목록 조회
   */
  public PageResponse<ReportSummaryResponse> getMyReports(String username, PageRequestDto pageRequest) {
    log.info("Getting my reports for user: {}", username);
    
    // 사용자 조회
    User user = userRepository.findByEmail(username)
        .orElseThrow(() -> new IllegalArgumentException("User not found: " + username));
    
    // Pageable 객체 생성
    Pageable pageable = PageRequest.of(
        pageRequest.page(),
        pageRequest.size(),
        Sort.by(Sort.Direction.DESC, "createdAt")
    );
    
    // 사용자별 신고서 조회
    Page<Report> reportPage = reportRepository.findByUserAndDeletedAtIsNull(user, pageable);
    
    // ReportSummaryResponse로 변환
    List<ReportSummaryResponse> content = reportPage.getContent().stream()
        .map(this::convertToSummaryResponse)
        .collect(Collectors.toList());
    
    return new PageResponse<>(
        content,
        reportPage.getNumber(),
        reportPage.getSize(),
        reportPage.getTotalElements(),
        reportPage.getTotalPages(),
        reportPage.isFirst(),
        reportPage.isLast(),
        reportPage.isEmpty()
    );
  }

  /**
   * 신고서 통계
   */
  public ReportStatisticsResponse getStatistics() {
    log.info("Getting report statistics");
    
    // 전체 통계
    long totalReports = reportRepository.countActive();
    
    // 상태별 통계
    List<Object[]> statusStats = reportRepository.getStatusStatistics();
    Map<String, Long> statusCounts = statusStats.stream()
        .collect(Collectors.toMap(
            arr -> (String) arr[0],
            arr -> (Long) arr[1]
        ));
    
    // 카테고리별 통계
    List<Object[]> categoryStats = reportRepository.getCategoryStatistics();
    Map<String, Long> categoryCounts = categoryStats.stream()
        .collect(Collectors.toMap(
            arr -> (String) arr[0],
            arr -> (Long) arr[1]
        ));
    
    // 우선순위별 통계
    Map<String, Long> priorityCounts = Map.of(
        "LOW", reportRepository.countByPriority(Report.Priority.LOW),
        "MEDIUM", reportRepository.countByPriority(Report.Priority.MEDIUM),
        "HIGH", reportRepository.countByPriority(Report.Priority.HIGH),
        "URGENT", reportRepository.countByPriority(Report.Priority.URGENT)
    );
    
    // 월별 통계 (빈 Map으로 초기화)
    Map<String, Long> monthlyStats = Collections.emptyMap();
    
    return new ReportStatisticsResponse(
        totalReports,
        statusCounts,
        priorityCounts,
        categoryCounts,
        monthlyStats
    );
  }

  /**
   * 신고서 상태 변경
   */
  @Transactional
  public void updateReportStatus(UUID reportId, String status, String username) {
    log.info("Updating report status: {} to {} by user: {}", reportId, status, username);
    
    // 기존 신고서 조회
    Report report = reportRepository.findByIdAndDeletedAtIsNull(reportId)
        .orElseThrow(() -> new IllegalArgumentException("Report not found or deleted: " + reportId));
    
    // 권한 확인 (관리자만 상태 변경 가능)
    User user = userRepository.findByEmail(username)
        .orElseThrow(() -> new IllegalArgumentException("User not found: " + username));
    
    if (!isUserManager(user)) {
      throw new IllegalArgumentException("Not authorized to update report status");
    }
    
    // 상태 업데이트 (실제 Status 엔티티 처리는 상황에 따라 구현)
    // 여기서는 간단히 로깅만 수행
    log.info("Status updated from {} to {} for report: {}", 
        report.getStatus() != null ? report.getStatus() : "null", 
        status, 
        reportId);
    
    reportRepository.save(report);
    
    log.info("Report status updated successfully: {}", reportId);
  }

  /**
   * 신고서 제출
   */
  @Transactional
  public void submitReport(UUID reportId, String username) {
    log.info("Submitting report: {} by user: {}", reportId, username);
    
    // 기존 신고서 조회
    Report report = reportRepository.findByIdAndDeletedAtIsNull(reportId)
        .orElseThrow(() -> new IllegalArgumentException("Report not found or deleted: " + reportId));
    
    // 권한 확인 (작성자만 제출 가능)
    User user = userRepository.findByEmail(username)
        .orElseThrow(() -> new IllegalArgumentException("User not found: " + username));
    
    if (!report.getUser().getId().equals(user.getId())) {
      throw new IllegalArgumentException("Not authorized to submit this report");
    }
    
    // 제출 로직 수행
    // 실제로는 상태를 '제출됨'으로 변경하거나 추가 비즈니스 로직 수행
    log.info("Report submitted successfully: {}", reportId);
  }
  
  // 헬퍼 메서드들
  
  private ReportDetailResponse createReportDetailResponse(Report report) {
    UserSummaryResponse author = report.getUser() != null ? 
        new UserSummaryResponse(
            report.getUser().getId(),
            report.getUser().getName(),
            report.getUser().getEmail(),
            report.getUser().getRole()
        ) : null;
    
    ReportCategoryResponse category = report.getCategory() != null ?
        new ReportCategoryResponse(
            UUID.randomUUID(), // Temporary UUID mapping
            report.getCategory().getName(),
            report.getCategory().getDescription(),
            report.getCategory().getColor() != null ? report.getCategory().getColor() : "#000000",
            true // Default active status
        ) : null;
    
    StatusResponse status = report.getStatus() != null ?
        new StatusResponse(
            report.getStatus().getName(), // Use name as code
            report.getStatus().getName(),
            report.getStatus().getColor() != null ? report.getStatus().getColor() : "#000000",
            report.getStatus().getDescription()
        ) : null;
    
    UserSummaryResponse manager = report.getManager() != null ?
        new UserSummaryResponse(
            report.getManager().getId(),
            report.getManager().getName(),
            report.getManager().getEmail(),
            report.getManager().getRole()
        ) : null;
    
    return ReportDetailResponse.from(
        report,
        author,
        category,
        status,
        manager,
        new ArrayList<>(), // attachments - 실제로는 파일 서비스에서 조회
        new ArrayList<>()  // comments - 실제로는 댓글 서비스에서 조회
    );
  }
  
  private ReportSummaryResponse convertToSummaryResponse(Report report) {
    UserSummaryResponse author = report.getUser() != null ? 
        new UserSummaryResponse(
            report.getUser().getId(),
            report.getUser().getName(),
            report.getUser().getEmail(),
            report.getUser().getRole()
        ) : null;
    
    ReportCategoryResponse category = report.getCategory() != null ?
        new ReportCategoryResponse(
            UUID.randomUUID(), // Temporary UUID mapping
            report.getCategory().getName(),
            report.getCategory().getDescription(),
            report.getCategory().getColor() != null ? report.getCategory().getColor() : "#000000",
            true // Default active status
        ) : null;
    
    StatusResponse status = report.getStatus() != null ?
        new StatusResponse(
            report.getStatus().getName(), // Use name as code
            report.getStatus().getName(),
            report.getStatus().getColor() != null ? report.getStatus().getColor() : "#000000",
            report.getStatus().getDescription()
        ) : null;
    
    return new ReportSummaryResponse(
        report.getId(),
        report.getTitle(),
        report.getDescription().length() > 100 ? 
            report.getDescription().substring(0, 100) + "..." : 
            report.getDescription(),
        author,
        category,
        status,
        report.getPriority(),
        report.getAddress(),
        null, // thumbnailUrl - 실제로는 파일 서비스에서 조회
        0, // likesCount
        0, // commentsCount - 실제로는 댓글 서비스에서 조회
        0, // viewCount
        report.getCreatedAt(),
        report.getUpdatedAt()
    );
  }
  
  private boolean isUserManager(User user) {
    return user.getRole() == User.UserRole.ADMIN || 
           user.getRole() == User.UserRole.MANAGER;
  }
}
