package com.jeonbuk.report.dto.report;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.jeonbuk.report.domain.report.*;
import com.jeonbuk.report.dto.user.UserSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 보고서 상세 응답 DTO
 */
@Schema(description = "보고서 상세 정보")
public record ReportDetailResponse(
    @Schema(description = "보고서 ID", example = "1")
    Long id,
    
    @Schema(description = "작성자 정보")
    UserSummaryResponse author,
    
    @Schema(description = "카테고리 정보")
    ReportCategoryResponse category,
    
    @Schema(description = "제목", example = "긴급 안전 점검 보고")
    String title,
    
    @Schema(description = "내용", example = "현장에서 발견된 안전상 문제점...")
    String content,
    
    @Schema(description = "상태", example = "SUBMITTED")
    ReportStatus status,
    
    @Schema(description = "우선순위", example = "HIGH")
    ReportPriority priority,
    
    @Schema(description = "위치 정보")
    LocationInfo location,
    
    @Schema(description = "승인자 정보")
    UserSummaryResponse approver,
    
    @Schema(description = "승인/반려 일시")
    @JsonProperty("approvedAt")
    LocalDateTime approvedAt,
    
    @Schema(description = "피드백")
    String feedback,
    
    @Schema(description = "첨부 파일 목록")
    List<ReportFileResponse> files,
    
    @Schema(description = "서명 목록")
    List<ReportSignatureResponse> signatures,
    
    @Schema(description = "댓글 목록")
    List<CommentResponse> comments,
    
    @Schema(description = "생성일시")
    @JsonProperty("createdAt")
    LocalDateTime createdAt,
    
    @Schema(description = "수정일시")
    @JsonProperty("updatedAt")
    LocalDateTime updatedAt
) {
    
    public static ReportDetailResponse from(Report report) {
        LocationInfo locationInfo = null;
        if (report.getLocation() != null) {
            Map<String, Object> loc = report.getLocation();
            locationInfo = new LocationInfo(
                (Double) loc.get("latitude"),
                (Double) loc.get("longitude"),
                (String) loc.get("address")
            );
        }
        
        return new ReportDetailResponse(
            report.getId(),
            UserSummaryResponse.from(report.getAuthor()),
            report.getCategory() != null ? ReportCategoryResponse.from(report.getCategory()) : null,
            report.getTitle(),
            report.getContent(),
            report.getStatus(),
            report.getPriority(),
            locationInfo,
            report.getApprover() != null ? UserSummaryResponse.from(report.getApprover()) : null,
            report.getApprovedAt(),
            report.getFeedback(),
            report.getReportFiles().stream()
                .map(ReportFileResponse::from)
                .toList(),
            report.getReportSignatures().stream()
                .map(ReportSignatureResponse::from)
                .toList(),
            report.getComments().stream()
                .map(CommentResponse::from)
                .toList(),
            report.getCreatedAt(),
            report.getUpdatedAt()
        );
    }
}

/**
 * 보고서 목록 조회용 요약 DTO
 */
@Schema(description = "보고서 목록 응답")
public record ReportSummaryResponse(
    @Schema(description = "보고서 ID", example = "1")
    Long id,
    
    @Schema(description = "제목", example = "긴급 안전 점검 보고")
    String title,
    
    @Schema(description = "작성자명", example = "홍길동")
    String authorName,
    
    @Schema(description = "카테고리명", example = "안전")
    String categoryName,
    
    @Schema(description = "상태", example = "SUBMITTED")
    ReportStatus status,
    
    @Schema(description = "우선순위", example = "HIGH")
    ReportPriority priority,
    
    @Schema(description = "생성일시")
    @JsonProperty("createdAt")
    LocalDateTime createdAt
) {
    
    public static ReportSummaryResponse from(Report report) {
        return new ReportSummaryResponse(
            report.getId(),
            report.getTitle(),
            report.getAuthor().getName(),
            report.getCategory() != null ? report.getCategory().getName() : null,
            report.getStatus(),
            report.getPriority(),
            report.getCreatedAt()
        );
    }
}

/**
 * 보고서 상태 변경 요청 DTO
 */
@Schema(description = "보고서 상태 변경 요청")
public record ReportStatusUpdateRequest(
    @Schema(description = "변경할 상태", example = "APPROVED", allowableValues = {"APPROVED", "REJECTED"})
    @jakarta.validation.constraints.NotNull(message = "상태는 필수입니다")
    ReportStatus status,
    
    @Schema(description = "피드백", example = "검토 완료하였습니다.")
    @jakarta.validation.constraints.Size(max = 1000, message = "피드백은 1,000자 이하여야 합니다")
    String feedback
) {}

/**
 * 보고서 수정 요청 DTO
 */
@Schema(description = "보고서 수정 요청")
public record ReportUpdateRequest(
    @Schema(description = "카테고리 ID", example = "1")
    @jakarta.validation.constraints.NotNull(message = "카테고리는 필수입니다")
    @jakarta.validation.constraints.Positive(message = "카테고리 ID는 양수여야 합니다")
    Long categoryId,
    
    @Schema(description = "보고서 제목", example = "긴급 안전 점검 보고")
    @jakarta.validation.constraints.NotBlank(message = "제목은 필수입니다")
    @jakarta.validation.constraints.Size(max = 255, message = "제목은 255자 이하여야 합니다")
    String title,
    
    @Schema(description = "보고서 내용", example = "현장에서 발견된 안전상 문제점에 대한 상세 보고...")
    @jakarta.validation.constraints.Size(max = 10000, message = "내용은 10,000자 이하여야 합니다")
    String content,
    
    @Schema(description = "우선순위", example = "HIGH", allowableValues = {"LOW", "MEDIUM", "HIGH", "URGENT"})
    ReportPriority priority,
    
    @Schema(description = "위치 정보")
    @jakarta.validation.Valid
    LocationInfo location
) {}
