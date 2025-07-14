package com.jeonbuk.report.dto.comment;

import com.jeonbuk.report.domain.entity.Comment;
import com.jeonbuk.report.dto.user.UserSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Schema(description = "댓글 응답")
public record CommentResponse(
        @Schema(description = "댓글 ID") UUID id,
        @Schema(description = "신고서 ID") UUID reportId,
        @Schema(description = "작성자 정보") UserSummaryResponse author,
        @Schema(description = "부모 댓글 ID") UUID parentId,
        @Schema(description = "내용") String content,
        @Schema(description = "내부 댓글 여부") Boolean isInternal,
        @Schema(description = "시스템 댓글 여부") Boolean isSystem,
        @Schema(description = "첨부파일 경로") String attachmentPath,
        @Schema(description = "첨부파일 URL") String attachmentUrl,
        @Schema(description = "생성일시") LocalDateTime createdAt,
        @Schema(description = "수정일시") LocalDateTime updatedAt,
        @Schema(description = "삭제일시") LocalDateTime deletedAt,
        @Schema(description = "답글 목록") List<CommentResponse> replies
) {
    public static CommentResponse from(Comment comment) {
        return new CommentResponse(
                comment.getId(),
                comment.getReport().getId(),
                UserSummaryResponse.from(comment.getUser()),
                comment.getParent() != null ? comment.getParent().getId() : null,
                comment.getContent(),
                comment.getIsInternal(),
                comment.getIsSystem(),
                comment.getAttachmentPath(),
                comment.getAttachmentUrl(),
                comment.getCreatedAt(),
                comment.getUpdatedAt(),
                comment.getDeletedAt(),
                comment.getReplies() != null ? 
                    comment.getReplies().stream().map(CommentResponse::from).toList() : 
                    List.of()
        );
    }
}