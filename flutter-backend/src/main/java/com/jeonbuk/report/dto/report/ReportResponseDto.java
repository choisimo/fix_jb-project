package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.*;
import com.jeonbuk.report.dto.user.UserSummary;
import com.jeonbuk.report.dto.report.ReportRequestDto.*;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 신고서 상세 응답 DTO
 */
@Schema(description = "신고서 상세 정보")
public record ReportDetailResponse(
                @Schema(description = "신고서 ID") UUID id,

                @Schema(description = "제목") String title,

                @Schema(description = "설명") String description,

                @Schema(description = "작성자 정보") UserSummaryResponse author,

                @Schema(description = "카테고리 정보") ReportCategoryResponse category,

                @Schema(description = "상태 정보") StatusResponse status,

                @Schema(description = "우선순위", example = "HIGH") Report.Priority priority,

                @Schema(description = "위치 정보") LocationInfo location,

                @Schema(description = "담당자 정보") UserSummaryResponse manager,

                @Schema(description = "관리자 메모") String managerNotes,

                @Schema(description = "예상 완료일") LocalDate estimatedCompletion,

                @Schema(description = "실제 완료일") LocalDate actualCompletion,

                @Schema(description = "AI 분석 결과") Map<String, Object> aiAnalysisResults,

                @Schema(description = "AI 신뢰도 점수") BigDecimal aiConfidenceScore,

                @Schema(description = "복잡한 주제 여부") Boolean isComplexSubject,

                @Schema(description = "서명 데이터") String signatureData,

                @Schema(description = "장치 정보") Map<String, Object> deviceInfo,

                @Schema(description = "파일 목록") List<ReportFileResponse> files,

                @Schema(description = "서명 목록") List<ReportSignatureResponse> signatures,

                @Schema(description = "댓글 목록") List<CommentResponse> comments,

                @Schema(description = "생성일시") LocalDateTime createdAt,

                @Schema(description = "수정일시") LocalDateTime updatedAt,

                @Schema(description = "삭제일시") LocalDateTime deletedAt) {
        public static ReportDetailResponse from(Report report) {
                LocationInfo locationInfo = null;
                if (report.getLatitude() != null && report.getLongitude() != null) {
                        locationInfo = new LocationInfo(
                                        report.getLatitude(),
                                        report.getLongitude(),
                                        report.getAddress());
                }

                return new ReportDetailResponse(
                                report.getId(),
                                report.getTitle(),
                                report.getDescription(),
                                UserSummaryResponse.from(report.getUser()), // Use getUser() instead of getAuthor()
                                report.getCategory() != null ? ReportCategoryResponse.from(report.getCategory()) : null,
                                report.getStatus() != null ? StatusResponse.from(report.getStatus()) : null,
                                report.getPriority(),
                                locationInfo,
                                report.getManager() != null ? UserSummaryResponse.from(report.getManager()) : null,
                                report.getManagerNotes(),
                                report.getEstimatedCompletion(),
                                report.getActualCompletion(),
                                report.getAiAnalysisResults(),
                                report.getAiConfidenceScore(),
                                report.getIsComplexSubject(),
                                report.getSignatureData(),
                                report.getDeviceInfo(),
                                report.getFiles().stream()
                                                .map(ReportFileResponse::from)
                                                .collect(Collectors.toList()),
                                List.of(), // ReportSignature is separate entity, will need to query separately
                                report.getComments().stream()
                                                .map(CommentResponse::from)
                                                .collect(Collectors.toList()),
                                report.getCreatedAt(),
                                report.getUpdatedAt(),
                                report.getDeletedAt());
        }
}

/**
 * 신고서 요약 응답 DTO
 */
@Schema(description = "신고서 요약 정보")
public record ReportSummaryResponse(
                @Schema(description = "신고서 ID") UUID id,

                @Schema(description = "제목") String title,

                @Schema(description = "작성자 이름") String authorName,

                @Schema(description = "카테고리명") String categoryName,

                @Schema(description = "상태명") String statusName,

                @Schema(description = "우선순위") Report.Priority priority,

                @Schema(description = "위치 정보") LocationInfo location,

                @Schema(description = "생성일시") LocalDateTime createdAt,

                @Schema(description = "수정일시") LocalDateTime updatedAt) {
        public static ReportSummaryResponse from(Report report) {
                LocationInfo locationInfo = null;
                if (report.getLatitude() != null && report.getLongitude() != null) {
                        locationInfo = new LocationInfo(
                                        report.getLatitude(),
                                        report.getLongitude(),
                                        report.getAddress());
                }

                return new ReportSummaryResponse(
                                report.getId(),
                                report.getTitle(),
                                report.getUser().getName(), // Use getUser().getName()
                                report.getCategory() != null ? report.getCategory().getName() : null,
                                report.getStatus() != null ? report.getStatus().getName() : null,
                                report.getPriority(),
                                locationInfo,
                                report.getCreatedAt(),
                                report.getUpdatedAt());
        }
}

/**
 * 상태 응답 DTO
 */
@Schema(description = "상태 정보")
public record StatusResponse(
                @Schema(description = "상태 ID") Long id,

                @Schema(description = "상태명") String name,

                @Schema(description = "상태 설명") String description,

                @Schema(description = "색상") String color,

                @Schema(description = "최종 상태 여부") Boolean isTerminal) {
        public static StatusResponse from(Status status) {
                return new StatusResponse(
                                status.getId(),
                                status.getName(),
                                status.getDescription(),
                                status.getColor(),
                                status.getIsTerminal());
        }
}

/**
 * 신고서 상태 변경 요청 DTO
 */
@Schema(description = "신고서 상태 변경 요청")
public record ReportStatusUpdateRequest(
                @NotNull(message = "상태 ID는 필수입니다") @Schema(description = "상태 ID") Long statusId,

                @Schema(description = "변경 사유") String reason) {
}

/**
 * 신고서 수정 요청 DTO
 */
@Schema(description = "신고서 수정 요청")
public record ReportUpdateRequest(
                @Size(max = 200, message = "제목은 200자 이하여야 합니다") @Schema(description = "제목") String title,

                @Schema(description = "설명") String description,

                @Schema(description = "우선순위") Report.Priority priority,

                @Valid @Schema(description = "위치 정보") LocationInfo location,

                @Schema(description = "카테고리 ID") UUID categoryId,

                @Schema(description = "관리자 메모") String managerNotes,

                @Schema(description = "예상 완료일") LocalDate estimatedCompletion) {
}
