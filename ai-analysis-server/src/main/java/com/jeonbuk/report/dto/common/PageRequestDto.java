package com.jeonbuk.report.dto.common;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

/**
 * 페이징 요청 DTO
 */
@Schema(description = "페이징 요청")
public record PageRequestDto(
    @Schema(description = "페이지 번호 (0부터 시작)", example = "0", defaultValue = "0") @Min(value = 0, message = "페이지 번호는 0 이상이어야 합니다") Integer page,

    @Schema(description = "페이지 크기", example = "20", defaultValue = "20") @Min(value = 1, message = "페이지 크기는 1 이상이어야 합니다") Integer size,

    @Schema(description = "정렬 기준", example = "createdAt", defaultValue = "createdAt") String sortBy,

    @Schema(description = "정렬 방향", example = "DESC", defaultValue = "DESC", allowableValues = {
        "ASC", "DESC" }) String sortDirection){

  public Pageable toPageable() {
    int pageNumber = page != null ? page : 0;
    int pageSize = size != null ? size : 20;
    String sort = sortBy != null ? sortBy : "createdAt";
    Sort.Direction direction = "ASC".equalsIgnoreCase(sortDirection) ? Sort.Direction.ASC : Sort.Direction.DESC;

    return PageRequest.of(pageNumber, pageSize, Sort.by(direction, sort));
  }
}
