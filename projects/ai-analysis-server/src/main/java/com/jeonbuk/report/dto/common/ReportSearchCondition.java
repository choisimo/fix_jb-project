package com.jeonbuk.report.dto.common;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.report.ReportStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 보고서 검색 조건 DTO
 */
@Schema(description = "보고서 검색 조건")
public record ReportSearchCondition(
    @Schema(description = "검색 키워드 (제목, 내용에서 검색)", example = "안전") @Size(max = 100, message = "검색 키워드는 100자 이하여야 합니다") String keyword,

    @Schema(description = "상태 목록", example = "[\"SUBMITTED\", \"APPROVED\"]") List<ReportStatus> statuses,

    @Schema(description = "우선순위 목록", example = "[\"HIGH\", \"URGENT\"]") List<Report.Priority> priorities,

    @Schema(description = "카테고리 ID 목록", example = "[1, 2, 3]") List<Long> categoryIds,

    @Schema(description = "작성자 ID", example = "123e4567-e89b-12d3-a456-426614174000") UUID authorId,

    @Schema(description = "승인자 ID", example = "123e4567-e89b-12d3-a456-426614174001") UUID approverId,

    @Schema(description = "검색 시작일") LocalDateTime startDate,

    @Schema(description = "검색 종료일") LocalDateTime endDate) {
    
    /**
     * 검색 조건이 있는지 확인
     */
    public boolean hasSearchConditions() {
        return keyword != null || 
               (statuses != null && !statuses.isEmpty()) || 
               (priorities != null && !priorities.isEmpty()) || 
               (categoryIds != null && !categoryIds.isEmpty()) || 
               authorId != null || 
               approverId != null || 
               startDate != null || 
               endDate != null;
    }
    
    /**
     * 단일 카테고리 ID 반환 (첫 번째 카테고리)
     */
    public Long categoryId() {
        return categoryIds != null && !categoryIds.isEmpty() ? categoryIds.get(0) : null;
    }
    
    /**
     * 단일 상태 반환 (첫 번째 상태)
     */
    public Long statusId() {
        return null; // 상태는 enum이므로 Long ID가 없음
    }
    
    /**
     * 단일 우선순위 반환 (첫 번째 우선순위)
     */
    public Report.Priority priority() {
        return priorities != null && !priorities.isEmpty() ? priorities.get(0) : null;
    }
    
    /**
     * 사용자 ID 반환
     */
    public UUID userId() {
        return authorId;
    }
    
    /**
     * 관리자 ID 반환
     */
    public UUID managerId() {
        return approverId;
    }
}
