package com.jeonbuk.report.dto.comment;

import com.jeonbuk.report.domain.entity.Comment;
import com.jeonbuk.report.dto.user.UserSummary;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

/**
 * 댓글 관련 DTO 클래스들
 */
public class CommentDto {

  /**
   * 댓글 응답 DTO
   */
  @Schema(description = "댓글 응답")
  public record CommentResponse(
      @Schema(description = "댓글 ID", example = "123e4567-e89b-12d3-a456-426614174000") UUID id,

      @Schema(description = "신고서 ID", example = "123e4567-e89b-12d3-a456-426614174000") UUID reportId,

      @Schema(description = "작성자 정보") UserSummary user,

      @Schema(description = "부모 댓글 ID (대댓글인 경우)", example = "123e4567-e89b-12d3-a456-426614174000") UUID parentId,

      @Schema(description = "댓글 내용", example = "검토가 필요한 사항입니다.") String content,

      @Schema(description = "내부 댓글 여부", example = "false") Boolean isInternal,

      @Schema(description = "시스템 댓글 여부", example = "false") Boolean isSystem,

      @Schema(description = "첨부파일 경로") String attachmentPath,

      @Schema(description = "첨부파일 URL") String attachmentUrl,

      @Schema(description = "생성일") LocalDateTime createdAt,

      @Schema(description = "수정일") LocalDateTime updatedAt,

      @Schema(description = "삭제일") LocalDateTime deletedAt,

      @Schema(description = "대댓글 목록") List<CommentResponse> replies) {
    public static CommentResponse from(Comment comment) {
      return new CommentResponse(
          comment.getId(),
          comment.getReport().getId(),
          UserSummary.from(comment.getUser()),
          comment.getParent() != null ? comment.getParent().getId() : null,
          comment.getContent(),
          comment.getIsInternal(),
          comment.getIsSystem(),
          comment.getAttachmentPath(),
          comment.getAttachmentUrl(),
          comment.getCreatedAt(),
          comment.getUpdatedAt(),
          comment.getDeletedAt(),
          comment.getReplies() != null ? comment.getReplies().stream().map(CommentResponse::from).toList()
              : Collections.emptyList());
    }
  }

  /**
   * 댓글 생성 요청 DTO
   */
  @Schema(description = "댓글 생성 요청")
  public record CommentCreateRequest(
      @Schema(description = "신고서 ID", example = "123e4567-e89b-12d3-a456-426614174000") UUID reportId,

      @Schema(description = "부모 댓글 ID (대댓글인 경우)", example = "123e4567-e89b-12d3-a456-426614174000") UUID parentId,

      @Schema(description = "댓글 내용", example = "검토가 필요한 사항입니다.") @NotBlank(message = "댓글 내용은 필수입니다") @Size(max = 1000, message = "댓글 내용은 1000자 이하여야 합니다") String content,

      @Schema(description = "내부 댓글 여부", example = "false") Boolean isInternal,

      @Schema(description = "첨부파일 경로") String attachmentPath,

      @Schema(description = "첨부파일 URL") String attachmentUrl) {
  }

  /**
   * 댓글 수정 요청 DTO
   */
  @Schema(description = "댓글 수정 요청")
  public record CommentUpdateRequest(
      @Schema(description = "댓글 내용", example = "수정된 댓글입니다.") @Size(max = 1000, message = "댓글 내용은 1000자 이하여야 합니다") String content,

      @Schema(description = "첨부파일 경로") String attachmentPath,

      @Schema(description = "첨부파일 URL") String attachmentUrl) {
  }

  /**
   * 댓글 요약 DTO (목록용)
   */
  @Schema(description = "댓글 요약")
  public record CommentSummary(
      @Schema(description = "댓글 ID", example = "123e4567-e89b-12d3-a456-426614174000") UUID id,

      @Schema(description = "작성자 정보") UserSummary user,

      @Schema(description = "댓글 내용", example = "검토가 필요한 사항입니다.") String content,

      @Schema(description = "내부 댓글 여부", example = "false") Boolean isInternal,

      @Schema(description = "시스템 댓글 여부", example = "false") Boolean isSystem,

      @Schema(description = "생성일") LocalDateTime createdAt,

      @Schema(description = "대댓글 개수", example = "3") Integer replyCount) {
    public static CommentSummary from(Comment comment) {
      return new CommentSummary(
          comment.getId(),
          UserSummary.from(comment.getUser()),
          comment.getContent(),
          comment.getIsInternal(),
          comment.getIsSystem(),
          comment.getCreatedAt(),
          comment.getReplies() != null ? comment.getReplies().size() : 0);
    }
  }
}
