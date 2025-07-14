package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.dto.user.UserSummaryResponse;
import com.jeonbuk.report.dto.category.ReportCategoryResponse;
import com.jeonbuk.report.dto.comment.CommentResponse;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

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

        @Schema(description = "첨부파일 목록") List<ReportFileResponse> attachments,

        @Schema(description = "댓글 목록") List<CommentResponse> comments,

        @Schema(description = "태그 목록") List<String> tags,

        @Schema(description = "좋아요 수") int likesCount,

        @Schema(description = "조회수") int viewCount,

        @Schema(description = "즐겨찾기 여부") boolean isFavorite,

        @Schema(description = "작성일") LocalDateTime createdAt,

        @Schema(description = "수정일") LocalDateTime updatedAt
) {

    /**
     * Report 엔티티로부터 Response 생성
     */
    public static ReportDetailResponse from(Report report, UserSummaryResponse author,
                                            ReportCategoryResponse category, StatusResponse status,
                                            UserSummaryResponse manager,
                                            List<ReportFileResponse> attachments,
                                            List<CommentResponse> comments) {
        return new ReportDetailResponse(
                report.getId(),
                report.getTitle(),
                report.getDescription(),
                author,
                category,
                status,
                report.getPriority(),
                new LocationInfo(
                        report.getLatitude(),
                        report.getLongitude(),
                        report.getAddress()
                ),
                manager,
                report.getManagerNotes(),
                report.getEstimatedCompletion(),
                report.getActualCompletion(),
                report.getAiAnalysisResults(),
                attachments,
                comments,
                null, // tags field doesn't exist in Report entity
                0, // likesCount field doesn't exist in Report entity
                0, // viewCount field doesn't exist in Report entity
                false, // TODO: 즐겨찾기 기능 구현 시 수정
                report.getCreatedAt(),
                report.getUpdatedAt()
        );
    }
}