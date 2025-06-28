package com.jeonbuk.report.dto.report;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.jeonbuk.report.domain.report.*;
import com.jeonbuk.report.domain.user.User;
import com.jeonbuk.report.dto.user.UserSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 위치 정보 DTO
 */
@Schema(description = "위치 정보")
public record LocationInfo(
    @Schema(description = "위도", example = "35.824776")
    @NotNull(message = "위도는 필수입니다")
    @DecimalMin(value = "-90.0", message = "위도는 -90 이상이어야 합니다")
    @DecimalMax(value = "90.0", message = "위도는 90 이하여야 합니다")
    Double latitude,
    
    @Schema(description = "경도", example = "127.148029")
    @NotNull(message = "경도는 필수입니다")
    @DecimalMin(value = "-180.0", message = "경도는 -180 이상이어야 합니다")
    @DecimalMax(value = "180.0", message = "경도는 180 이하여야 합니다")
    Double longitude,
    
    @Schema(description = "주소", example = "전북 전주시 덕진구 백제대로 567")
    @Size(max = 500, message = "주소는 500자 이하여야 합니다")
    String address
) {}

/**
 * 보고서 생성 요청 DTO
 */
@Schema(description = "보고서 생성 요청")
public record ReportCreateRequest(
    @Schema(description = "카테고리 ID", example = "1")
    @NotNull(message = "카테고리는 필수입니다")
    @Positive(message = "카테고리 ID는 양수여야 합니다")
    Long categoryId,
    
    @Schema(description = "보고서 제목", example = "긴급 안전 점검 보고")
    @NotBlank(message = "제목은 필수입니다")
    @Size(max = 255, message = "제목은 255자 이하여야 합니다")
    String title,
    
    @Schema(description = "보고서 내용", example = "현장에서 발견된 안전상 문제점에 대한 상세 보고...")
    @Size(max = 10000, message = "내용은 10,000자 이하여야 합니다")
    String content,
    
    @Schema(description = "우선순위", example = "HIGH", allowableValues = {"LOW", "MEDIUM", "HIGH", "URGENT"})
    ReportPriority priority,
    
    @Schema(description = "위치 정보")
    @Valid
    LocationInfo location,
    
    @Schema(description = "첨부 파일 목록")
    @Valid
    List<ReportFileRequest> files,
    
    @Schema(description = "서명 정보")
    @Valid
    ReportSignatureRequest signature
) {
    
    public Report toEntity(User author, ReportCategory category) {
        Map<String, Object> locationMap = location != null ? 
            Map.of(
                "latitude", location.latitude(),
                "longitude", location.longitude(),
                "address", location.address() != null ? location.address() : ""
            ) : null;
            
        return Report.builder()
            .author(author)
            .category(category)
            .title(title)
            .content(content)
            .priority(priority != null ? priority : ReportPriority.MEDIUM)
            .location(locationMap)
            .build();
    }
}

/**
 * 보고서 파일 요청 DTO
 */
@Schema(description = "보고서 파일 정보")
public record ReportFileRequest(
    @Schema(description = "파일 URL", example = "https://storage.example.com/files/image1.jpg")
    @NotBlank(message = "파일 URL은 필수입니다")
    @Size(max = 512, message = "파일 URL은 512자 이하여야 합니다")
    String fileUrl,
    
    @Schema(description = "파일 타입", example = "IMAGE", allowableValues = {"IMAGE", "VIDEO", "DOCUMENT"})
    @NotBlank(message = "파일 타입은 필수입니다")
    String fileType,
    
    @Schema(description = "파일 설명", example = "현장 사진 1")
    @Size(max = 500, message = "파일 설명은 500자 이하여야 합니다")
    String description,
    
    @Schema(description = "정렬 순서", example = "1")
    @Min(value = 0, message = "정렬 순서는 0 이상이어야 합니다")
    Integer sortOrder
) {
    
    public ReportFile toEntity(Report report) {
        return ReportFile.builder()
            .report(report)
            .fileUrl(fileUrl)
            .fileType(fileType)
            .description(description)
            .sortOrder(sortOrder != null ? sortOrder : 0)
            .build();
    }
}

/**
 * 보고서 서명 요청 DTO
 */
@Schema(description = "보고서 서명 정보")
public record ReportSignatureRequest(
    @Schema(description = "서명 이미지 URL", example = "https://storage.example.com/signatures/sign1.png")
    @NotBlank(message = "서명 URL은 필수입니다")
    @Size(max = 512, message = "서명 URL은 512자 이하여야 합니다")
    String signatureUrl
) {
    
    public ReportSignature toEntity(Report report) {
        return ReportSignature.builder()
            .report(report)
            .signatureUrl(signatureUrl)
            .build();
    }
}

/**
 * 보고서 카테고리 응답 DTO
 */
@Schema(description = "보고서 카테고리 정보")
public record ReportCategoryResponse(
    @Schema(description = "카테고리 ID", example = "1")
    Long id,
    
    @Schema(description = "카테고리명", example = "안전")
    String name
) {
    
    public static ReportCategoryResponse from(ReportCategory category) {
        return new ReportCategoryResponse(
            category.getId(),
            category.getName()
        );
    }
}

/**
 * 보고서 파일 응답 DTO
 */
@Schema(description = "보고서 파일 응답")
public record ReportFileResponse(
    @Schema(description = "파일 ID", example = "1")
    Long id,
    
    @Schema(description = "파일 URL")
    String fileUrl,
    
    @Schema(description = "파일 타입", example = "IMAGE")
    String fileType,
    
    @Schema(description = "파일 설명")
    String description,
    
    @Schema(description = "정렬 순서", example = "1")
    Integer sortOrder
) {
    
    public static ReportFileResponse from(ReportFile reportFile) {
        return new ReportFileResponse(
            reportFile.getId(),
            reportFile.getFileUrl(),
            reportFile.getFileType(),
            reportFile.getDescription(),
            reportFile.getSortOrder()
        );
    }
}

/**
 * 보고서 서명 응답 DTO
 */
@Schema(description = "보고서 서명 응답")
public record ReportSignatureResponse(
    @Schema(description = "서명 ID", example = "1")
    Long id,
    
    @Schema(description = "서명 이미지 URL")
    String signatureUrl,
    
    @Schema(description = "생성일시")
    @JsonProperty("createdAt")
    LocalDateTime createdAt
) {
    
    public static ReportSignatureResponse from(ReportSignature signature) {
        return new ReportSignatureResponse(
            signature.getId(),
            signature.getSignatureUrl(),
            signature.getCreatedAt()
        );
    }
}

/**
 * 댓글 응답 DTO
 */
@Schema(description = "댓글 응답")
public record CommentResponse(
    @Schema(description = "댓글 ID", example = "1")
    Long id,
    
    @Schema(description = "작성자 정보")
    UserSummaryResponse author,
    
    @Schema(description = "댓글 내용")
    String content,
    
    @Schema(description = "생성일시")
    @JsonProperty("createdAt")
    LocalDateTime createdAt
) {
    
    public static CommentResponse from(Comment comment) {
        return new CommentResponse(
            comment.getId(),
            UserSummaryResponse.from(comment.getAuthor()),
            comment.getContent(),
            comment.getCreatedAt()
        );
    }
}
