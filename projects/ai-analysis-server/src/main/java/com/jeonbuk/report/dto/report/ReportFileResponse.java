package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.ReportFile;
import java.time.LocalDateTime;
import java.util.UUID;

public record ReportFileResponse(
    UUID id,
    String fileName,
    String fileUrl,
    String fileType,
    long fileSize,
    LocalDateTime createdAt
) {
    public static ReportFileResponse from(ReportFile file) {
        return new ReportFileResponse(
            file.getId(),
            file.getOriginalFilename(),
            file.getFileUrl(),
            file.getFileType(),
            file.getFileSize(),
            file.getUploadedAt()
        );
    }
}
