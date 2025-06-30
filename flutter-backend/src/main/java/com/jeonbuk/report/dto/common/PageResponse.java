package com.jeonbuk.report.dto.common;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 페이징 응답 DTO
 */
@Schema(description = "페이징 응답")
public record PageResponse<T>(
    @Schema(description = "데이터 목록") List<T> content,

    @Schema(description = "현재 페이지 번호", example = "0") int page,

    @Schema(description = "페이지 크기", example = "20") int size,

    @Schema(description = "전체 데이터 수", example = "150") long totalElements,

    @Schema(description = "전체 페이지 수", example = "8") int totalPages,

    @Schema(description = "첫 번째 페이지 여부", example = "true") boolean first,

    @Schema(description = "마지막 페이지 여부", example = "false") boolean last,

    @Schema(description = "비어있는 페이지 여부", example = "false") boolean empty) {

  public static <T> PageResponse<T> from(org.springframework.data.domain.Page<T> page) {
    return new PageResponse<>(
        page.getContent(),
        page.getNumber(),
        page.getSize(),
        page.getTotalElements(),
        page.getTotalPages(),
        page.isFirst(),
        page.isLast(),
        page.isEmpty());
  }
}
