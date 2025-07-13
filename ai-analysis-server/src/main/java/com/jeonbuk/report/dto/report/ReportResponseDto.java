package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.dto.user.UserSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;

/**
 * 신고서 응답 관련 공통 DTO들
 */
public class ReportResponseDto {
    
    /**
     * 위치 정보 DTO
     */
    @Schema(description = "위치 정보")
    public record LocationInfo(
            @Schema(description = "위도", example = "35.8242")
            @DecimalMin(value = "-90.0", message = "위도는 -90도 이상이어야 합니다")
            @DecimalMax(value = "90.0", message = "위도는 90도 이하여야 합니다")
            Double latitude,

            @Schema(description = "경도", example = "127.1479")
            @DecimalMin(value = "-180.0", message = "경도는 -180도 이상이어야 합니다")
            @DecimalMax(value = "180.0", message = "경도는 180도 이하여야 합니다")
            Double longitude,

            @Schema(description = "주소", example = "전라북도 전주시 덕진구")
            String address,

            @Schema(description = "상세 위치", example = "전북대학교 정문 앞")
            String detailedLocation
    ) {}

    /**
     * 신고서 파일 응답 DTO
     */
    @Schema(description = "신고서 첨부 파일")
    public record ReportFileResponse(
            @Schema(description = "파일 ID") Long id,
            @Schema(description = "파일명") String fileName,
            @Schema(description = "파일 URL") String fileUrl,
            @Schema(description = "파일 크기(bytes)") Long fileSize,
            @Schema(description = "파일 타입") String fileType,
            @Schema(description = "썸네일 URL") String thumbnailUrl
    ) {}

    /**
     * 카테고리 응답 DTO
     */
    @Schema(description = "신고서 카테고리")
    public record ReportCategoryResponse(
            @Schema(description = "카테고리 ID") Long id,
            @Schema(description = "카테고리명") String name,
            @Schema(description = "카테고리 설명") String description,
            @Schema(description = "아이콘") String icon,
            @Schema(description = "색상") String color
    ) {}
}