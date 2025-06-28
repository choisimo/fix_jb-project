package com.jeonbuk.report.controller;

import com.jeonbuk.report.dto.common.*;
import com.jeonbuk.report.dto.report.*;
import com.jeonbuk.report.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * 보고서 관리 API 컨트롤러
 */
@Tag(name = "보고서", description = "보고서 관리 API")
@RestController
@RequestMapping("/api/v1/reports")
@RequiredArgsConstructor
@Slf4j
public class ReportController {
    
    private final ReportService reportService;
    
    /**
     * 보고서 생성
     */
    @Operation(summary = "보고서 생성", description = "새로운 보고서를 생성합니다.")
    @PostMapping
    public ResponseEntity<ApiResponse<Long>> createReport(
            @Valid @RequestBody ReportCreateRequest request,
            @AuthenticationPrincipal String username) {
        
        log.info("보고서 생성 요청 - 사용자: {}, 제목: {}", username, request.title());
        
        Long reportId = reportService.createReport(request, username);
        
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success("보고서가 생성되었습니다.", reportId));
    }
    
    /**
     * 보고서 목록 조회
     */
    @Operation(summary = "보고서 목록 조회", description = "보고서 목록을 페이징하여 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<ReportSummaryResponse>>> getReports(
            @Valid @ModelAttribute ReportSearchCondition condition,
            @Valid @ModelAttribute PageRequestDto pageRequest) {
        
        log.info("보고서 목록 조회 - 검색조건: {}, 페이지: {}", condition, pageRequest);
        
        Page<ReportSummaryResponse> reports = reportService.getReports(condition, pageRequest.toPageable());
        PageResponse<ReportSummaryResponse> response = PageResponse.from(reports);
        
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    /**
     * 보고서 상세 조회
     */
    @Operation(summary = "보고서 상세 조회", description = "보고서 상세 정보를 조회합니다.")
    @GetMapping("/{reportId}")
    public ResponseEntity<ApiResponse<ReportDetailResponse>> getReport(
            @Parameter(description = "보고서 ID", example = "1")
            @PathVariable Long reportId) {
        
        log.info("보고서 상세 조회 - ID: {}", reportId);
        
        ReportDetailResponse report = reportService.getReport(reportId);
        return ResponseEntity.ok(ApiResponse.success(report));
    }
    
    /**
     * 보고서 수정
     */
    @Operation(summary = "보고서 수정", description = "보고서 정보를 수정합니다.")
    @PutMapping("/{reportId}")
    public ResponseEntity<ApiResponse<Void>> updateReport(
            @Parameter(description = "보고서 ID", example = "1")
            @PathVariable Long reportId,
            @Valid @RequestBody ReportUpdateRequest request,
            @AuthenticationPrincipal String username) {
        
        log.info("보고서 수정 - ID: {}, 사용자: {}", reportId, username);
        
        reportService.updateReport(reportId, request, username);
        return ResponseEntity.ok(ApiResponse.success("보고서가 수정되었습니다.", null));
    }
    
    /**
     * 보고서 상태 변경
     */
    @Operation(summary = "보고서 상태 변경", description = "보고서의 상태를 변경합니다.")
    @PatchMapping("/{reportId}/status")
    public ResponseEntity<ApiResponse<Void>> updateReportStatus(
            @Parameter(description = "보고서 ID", example = "1")
            @PathVariable Long reportId,
            @Valid @RequestBody ReportStatusUpdateRequest request,
            @AuthenticationPrincipal String username) {
        
        log.info("보고서 상태 변경 - ID: {}, 상태: {}, 사용자: {}", 
                reportId, request.status(), username);
        
        reportService.updateReportStatus(reportId, request, username);
        return ResponseEntity.ok(ApiResponse.success("보고서 상태가 변경되었습니다.", null));
    }
    
    /**
     * 보고서 제출
     */
    @Operation(summary = "보고서 제출", description = "작성 중인 보고서를 제출합니다.")
    @PostMapping("/{reportId}/submit")
    public ResponseEntity<ApiResponse<Void>> submitReport(
            @Parameter(description = "보고서 ID", example = "1")
            @PathVariable Long reportId,
            @AuthenticationPrincipal String username) {
        
        log.info("보고서 제출 - ID: {}, 사용자: {}", reportId, username);
        
        reportService.submitReport(reportId, username);
        return ResponseEntity.ok(ApiResponse.success("보고서가 제출되었습니다.", null));
    }
    
    /**
     * 보고서 삭제
     */
    @Operation(summary = "보고서 삭제", description = "보고서를 삭제합니다.")
    @DeleteMapping("/{reportId}")
    public ResponseEntity<ApiResponse<Void>> deleteReport(
            @Parameter(description = "보고서 ID", example = "1")
            @PathVariable Long reportId,
            @AuthenticationPrincipal String username) {
        
        log.info("보고서 삭제 - ID: {}, 사용자: {}", reportId, username);
        
        reportService.deleteReport(reportId, username);
        return ResponseEntity.ok(ApiResponse.success("보고서가 삭제되었습니다.", null));
    }
    
    /**
     * 내가 작성한 보고서 목록 조회
     */
    @Operation(summary = "내 보고서 목록", description = "현재 사용자가 작성한 보고서 목록을 조회합니다.")
    @GetMapping("/my")
    public ResponseEntity<ApiResponse<PageResponse<ReportSummaryResponse>>> getMyReports(
            @Valid @ModelAttribute PageRequestDto pageRequest,
            @AuthenticationPrincipal String username) {
        
        log.info("내 보고서 목록 조회 - 사용자: {}", username);
        
        Page<ReportSummaryResponse> reports = reportService.getMyReports(username, pageRequest.toPageable());
        PageResponse<ReportSummaryResponse> response = PageResponse.from(reports);
        
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    /**
     * 보고서 통계 조회
     */
    @Operation(summary = "보고서 통계", description = "보고서 현황 통계를 조회합니다.")
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<ReportStatisticsResponse>> getReportStatistics() {
        
        log.info("보고서 통계 조회");
        
        ReportStatisticsResponse statistics = reportService.getStatistics();
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }
}

/**
 * 보고서 통계 응답 DTO
 */
record ReportStatisticsResponse(
    long totalReports,
    long draftReports,
    long submittedReports,
    long approvedReports,
    long rejectedReports,
    java.util.Map<String, Long> categoryStats,
    java.util.Map<String, Long> priorityStats
) {}
