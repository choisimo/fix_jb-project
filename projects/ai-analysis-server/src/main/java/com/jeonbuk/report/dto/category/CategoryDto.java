package com.jeonbuk.report.dto.category;

import com.jeonbuk.report.domain.entity.Category;
import com.jeonbuk.report.domain.entity.ReportCategory;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 카테고리 관련 DTO 클래스들
 */
public class CategoryDto {

  /**
   * 카테고리 응답 DTO
   */
  @Builder
  @Schema(description = "카테고리 응답")
  public record CategoryResponse(
      @Schema(description = "카테고리 ID", example = "123e4567-e89b-12d3-a456-426614174000") UUID id,

      @Schema(description = "카테고리 명", example = "도로 안전") String name,

      @Schema(description = "카테고리 설명", example = "도로 관련 안전 문제") String description,

      @Schema(description = "카테고리 색상", example = "#FF5722") String color,

      @Schema(description = "활성 상태", example = "true") Boolean isActive,

      @Schema(description = "정렬 순서", example = "1") Integer sortOrder,

      @Schema(description = "생성일") LocalDateTime createdAt,

      @Schema(description = "수정일") LocalDateTime updatedAt) {
    public static CategoryResponse from(ReportCategory category) {
      return CategoryResponse.builder()
          .id(category.getId())
          .name(category.getName())
          .description(category.getDescription())
          .color(category.getColor())
          .isActive(category.getIsActive())
          .sortOrder(category.getSortOrder())
          .createdAt(category.getCreatedAt())
          .updatedAt(category.getUpdatedAt())
          .build();
    }
  }

  /**
   * 카테고리 생성 요청 DTO
   */
  @Builder
  @Schema(description = "카테고리 생성 요청")
  public record CategoryCreateRequest(
      @Schema(description = "카테고리 명", example = "도로 안전") @NotBlank(message = "카테고리명은 필수입니다") @Size(max = 100, message = "카테고리명은 100자 이하여야 합니다") String name,

      @Schema(description = "카테고리 설명", example = "도로 관련 안전 문제") @Size(max = 500, message = "설명은 500자 이하여야 합니다") String description,

      @Schema(description = "카테고리 색상 (HEX)", example = "#FF5722") @Pattern(regexp = "^#[0-9A-Fa-f]{6}$", message = "색상은 HEX 형식이어야 합니다 (예: #FF5722)") String color,

      @Schema(description = "활성 상태", example = "true") Boolean isActive,

      @Schema(description = "정렬 순서", example = "1") Integer sortOrder) {
    public ReportCategory toEntity() {
      return ReportCategory.builder()
          .name(name)
          .description(description)
          .color(color)
          .isActive(isActive != null ? isActive : true)
          .sortOrder(sortOrder != null ? sortOrder : 0)
          .build();
    }
  }

  /**
   * 카테고리 수정 요청 DTO
   */
  @Builder
  @Schema(description = "카테고리 수정 요청")
  public record CategoryUpdateRequest(
      @Schema(description = "카테고리 명", example = "도로 안전") @Size(max = 100, message = "카테고리명은 100자 이하여야 합니다") String name,

      @Schema(description = "카테고리 설명", example = "도로 관련 안전 문제") @Size(max = 500, message = "설명은 500자 이하여야 합니다") String description,

      @Schema(description = "카테고리 색상 (HEX)", example = "#FF5722") @Pattern(regexp = "^#[0-9A-Fa-f]{6}$", message = "색상은 HEX 형식이어야 합니다 (예: #FF5722)") String color,

      @Schema(description = "활성 상태", example = "true") Boolean isActive,

      @Schema(description = "정렬 순서", example = "1") Integer sortOrder) {
  }

  /**
   * 카테고리 요약 DTO (목록용)
   */
  @Builder
  @Schema(description = "카테고리 요약")
  public record CategorySummary(
      @Schema(description = "카테고리 ID", example = "123e4567-e89b-12d3-a456-426614174000") UUID id,

      @Schema(description = "카테고리 명", example = "도로 안전") String name,

      @Schema(description = "카테고리 색상", example = "#FF5722") String color,

      @Schema(description = "활성 상태", example = "true") Boolean isActive) {
    public static CategorySummary from(Category category) {
      return CategorySummary.builder()
          .id(new UUID(category.getId(), 0L))
          .name(category.getName())
          .color(category.getColor())
          .isActive(category.getIsActive())
          .build();
    }

    public static CategorySummary from(ReportCategory category) {
      return CategorySummary.builder()
          .id(category.getId())
          .name(category.getName())
          .color(category.getColor())
          .isActive(category.getIsActive())
          .build();
    }
  }
}
