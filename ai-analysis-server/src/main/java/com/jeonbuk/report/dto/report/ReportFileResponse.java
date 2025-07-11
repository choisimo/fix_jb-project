package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.ReportFile;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 신고서 파일 응답 DTO
 */
@Schema(description = "신고서 파일 정보")
public record ReportFileResponse(
    @Schema(description = "파일 ID") UUID id,

    @Schema(description = "원본 파일명") String originalFilename,

    @Schema(description = "파일 URL") String fileUrl,

    @Schema(description = "파일 타입") String fileType,

    @Schema(description = "파일 크기") Long fileSize,

    @Schema(description = "파일 순서") Integer fileOrder,

    @Schema(description = "업로드일") LocalDateTime uploadedAt) {
  public static ReportFileResponse from(ReportFile file) {
    return new ReportFileResponse(
        file.getId(),
        file.getOriginalFilename(),
        file.getFileUrl(),
        file.getFileType(),
        file.getFileSize(),
        file.getFileOrder(),
        file.getUploadedAt());
  }
}
