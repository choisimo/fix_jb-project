package com.jeonbuk.report.dto.common;

import com.jeonbuk.report.domain.report.ReportPriority;
import com.jeonbuk.report.domain.report.ReportStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 보고서 검색 조건 DTO
 */
@Schema(description = "보고서 검색 조건")
public record ReportSearchCondition(
    @Schema(description = "검색 키워드 (제목, 내용에서 검색)", example = "안전")
    @Size(max = 100, message = "검색 키워드는 100자 이하여야 합니다")
    String keyword,
    
    @Schema(description = "상태 목록", example = "[\"SUBMITTED\", \"APPROVED\"]")
    List<ReportStatus> statuses,
    
    @Schema(description = "우선순위 목록", example = "[\"HIGH\", \"URGENT\"]")
    List<ReportPriority> priorities,
    
    @Schema(description = "카테고리 ID 목록", example = "[1, 2, 3]")
    List<Long> categoryIds,
    
    @Schema(description = "작성자 ID", example = "123")
    Long authorId,
    
    @Schema(description = "승인자 ID", example = "456")
    Long approverId,
    
    @Schema(description = "검색 시작일")
    LocalDateTime startDate,
    
    @Schema(description = "검색 종료일")
    LocalDateTime endDate
) {}

/**
 * 페이징 요청 DTO
 */
@Schema(description = "페이징 요청")
public record PageRequestDto(
    @Schema(description = "페이지 번호 (0부터 시작)", example = "0", defaultValue = "0")
    @Min(value = 0, message = "페이지 번호는 0 이상이어야 합니다")
    Integer page,
    
    @Schema(description = "페이지 크기", example = "20", defaultValue = "20")
    @Min(value = 1, message = "페이지 크기는 1 이상이어야 합니다")
    Integer size,
    
    @Schema(description = "정렬 기준", example = "createdAt", defaultValue = "createdAt")
    String sortBy,
    
    @Schema(description = "정렬 방향", example = "DESC", defaultValue = "DESC", allowableValues = {"ASC", "DESC"})
    String sortDirection
) {
    
    public Pageable toPageable() {
        int pageNumber = page != null ? page : 0;
        int pageSize = size != null ? size : 20;
        String sort = sortBy != null ? sortBy : "createdAt";
        Sort.Direction direction = "ASC".equalsIgnoreCase(sortDirection) ? 
            Sort.Direction.ASC : Sort.Direction.DESC;
            
        return PageRequest.of(pageNumber, pageSize, Sort.by(direction, sort));
    }
}

/**
 * 페이징 응답 DTO
 */
@Schema(description = "페이징 응답")
public record PageResponse<T>(
    @Schema(description = "데이터 목록")
    List<T> content,
    
    @Schema(description = "현재 페이지 번호", example = "0")
    int page,
    
    @Schema(description = "페이지 크기", example = "20")
    int size,
    
    @Schema(description = "전체 데이터 수", example = "150")
    long totalElements,
    
    @Schema(description = "전체 페이지 수", example = "8")
    int totalPages,
    
    @Schema(description = "첫 번째 페이지 여부", example = "true")
    boolean first,
    
    @Schema(description = "마지막 페이지 여부", example = "false")
    boolean last,
    
    @Schema(description = "비어있는 페이지 여부", example = "false")
    boolean empty
) {
    
    public static <T> PageResponse<T> from(org.springframework.data.domain.Page<T> page) {
        return new PageResponse<>(
            page.getContent(),
            page.getNumber(),
            page.getSize(),
            page.getTotalElements(),
            page.getTotalPages(),
            page.isFirst(),
            page.isLast(),
            page.isEmpty()
        );
    }
}

/**
 * API 공통 응답 DTO
 */
@Schema(description = "API 응답")
@com.fasterxml.jackson.annotation.JsonInclude(com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(
    @Schema(description = "성공 여부", example = "true")
    boolean success,
    
    @Schema(description = "응답 메시지", example = "요청이 성공적으로 처리되었습니다.")
    String message,
    
    @Schema(description = "응답 데이터")
    T data,
    
    @Schema(description = "에러 코드", example = "USER_NOT_FOUND")
    String errorCode,
    
    @Schema(description = "응답 시간")
    LocalDateTime timestamp
) {
    
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(
            true,
            "요청이 성공적으로 처리되었습니다.",
            data,
            null,
            LocalDateTime.now()
        );
    }
    
    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(
            true,
            message,
            data,
            null,
            LocalDateTime.now()
        );
    }
    
    public static <T> ApiResponse<T> error(String message, String errorCode) {
        return new ApiResponse<>(
            false,
            message,
            null,
            errorCode,
            LocalDateTime.now()
        );
    }
}

/**
 * 에러 응답 DTO
 */
@Schema(description = "에러 응답")
public record ErrorResponse(
    @Schema(description = "에러 코드", example = "VALIDATION_FAILED")
    String errorCode,
    
    @Schema(description = "에러 메시지", example = "입력값 검증에 실패했습니다.")
    String message,
    
    @Schema(description = "상세 에러 정보")
    Object details,
    
    @Schema(description = "발생 시간")
    LocalDateTime timestamp
) {
    
    public static ErrorResponse of(String errorCode, String message) {
        return new ErrorResponse(errorCode, message, null, LocalDateTime.now());
    }
    
    public static ErrorResponse of(String errorCode, String message, Object details) {
        return new ErrorResponse(errorCode, message, details, LocalDateTime.now());
    }
}
