package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.dto.user.UserSummaryResponse;
import com.jeonbuk.report.dto.category.ReportCategoryResponse;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 신고서 요약 응답 DTO - 목록용
 */
@Schema(description = "신고서 요약 정보")
public record ReportSummaryResponse(
        @Schema(description = "신고서 ID") UUID id,

        @Schema(description = "제목") String title,

        @Schema(description = "설명 요약", example = "도로 파손이 심각합니다. (최대 100자)") String summaryDescription,

        @Schema(description = "작성자 정보") UserSummaryResponse author,

        @Schema(description = "카테고리 정보") ReportCategoryResponse category,

        @Schema(description = "상태 정보") StatusResponse status,

        @Schema(description = "우선순위", example = "HIGH") Report.Priority priority,

        @Schema(description = "주소") String address,

        @Schema(description = "대표 이미지 URL") String thumbnailUrl,

        @Schema(description = "좋아요 수") int likesCount,

        @Schema(description = "댓글 수") int commentsCount,

        @Schema(description = "조회수") int viewCount,

        @Schema(description = "작성일") LocalDateTime createdAt,

        @Schema(description = "수정일") LocalDateTime updatedAt
) {

    /**
     * Report 엔티티로부터 요약 Response 생성
     */
    public static ReportSummaryResponse from(Report report, UserSummaryResponse author,
                                             ReportCategoryResponse category, StatusResponse status,
                                             String thumbnailUrl, int commentsCount) {
        return new ReportSummaryResponse(
                report.getId(),
                report.getTitle(),
                truncateDescription(report.getDescription(), 100),
                author,
                category,
                status,
                report.getPriority(),
                report.getAddress(),
                thumbnailUrl,
                0, // likesCount field doesn't exist in Report entity
                commentsCount,
                0, // viewCount field doesn't exist in Report entity
                report.getCreatedAt(),
                report.getUpdatedAt()
        );
    }

    /**
     * 설명을 지정된 길이로 자르기
     */
    private static String truncateDescription(String description, int maxLength) {
        if (description == null) return null;
        if (description.length() <= maxLength) return description;
        return description.substring(0, maxLength) + "...";
    }
}