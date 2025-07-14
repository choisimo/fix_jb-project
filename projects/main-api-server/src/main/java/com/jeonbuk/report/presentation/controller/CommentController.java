package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.CommentService;
import com.jeonbuk.report.domain.entity.Comment;
import com.jeonbuk.report.presentation.dto.request.CommentCreateRequest;
import com.jeonbuk.report.presentation.dto.request.CommentUpdateRequest;
import com.jeonbuk.report.presentation.dto.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Slf4j
public class CommentController {

    private final CommentService commentService;

    @PostMapping("/reports/{reportId}/comments")
    public ResponseEntity<ApiResponse<Comment>> createComment(
            @PathVariable UUID reportId,
            @RequestParam UUID userId,
            @RequestBody CommentCreateRequest request) {
        
        try {
            Comment comment = commentService.createComment(reportId, userId, request.getContent());
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success("Comment created successfully", comment));
                    
        } catch (RuntimeException e) {
            log.error("Error creating comment for report {}: {}", reportId, e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/reports/{reportId}/comments")
    public ResponseEntity<ApiResponse<List<Comment>>> getCommentsByReport(
            @PathVariable UUID reportId) {
        
        try {
            List<Comment> comments = commentService.getCommentsByReportId(reportId);
            return ResponseEntity.ok(
                    ApiResponse.success("Comments retrieved successfully", comments)
            );
            
        } catch (RuntimeException e) {
            log.error("Error retrieving comments for report {}: {}", reportId, e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/reports/{reportId}/comments/paged")
    public ResponseEntity<ApiResponse<Page<Comment>>> getCommentsByReportPaged(
            @PathVariable UUID reportId,
            Pageable pageable) {
        
        try {
            Page<Comment> comments = commentService.getCommentsByReportId(reportId, pageable);
            return ResponseEntity.ok(
                    ApiResponse.success("Comments retrieved successfully", comments)
            );
            
        } catch (RuntimeException e) {
            log.error("Error retrieving paged comments for report {}: {}", reportId, e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/comments/{commentId}")
    public ResponseEntity<ApiResponse<Comment>> getComment(@PathVariable UUID commentId) {
        try {
            Comment comment = commentService.getCommentById(commentId);
            return ResponseEntity.ok(
                    ApiResponse.success("Comment retrieved successfully", comment)
            );
            
        } catch (RuntimeException e) {
            log.error("Error retrieving comment {}: {}", commentId, e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PutMapping("/comments/{commentId}")
    public ResponseEntity<ApiResponse<Comment>> updateComment(
            @PathVariable UUID commentId,
            @RequestBody CommentUpdateRequest request) {
        
        try {
            Comment comment = commentService.updateComment(commentId, request.getContent());
            return ResponseEntity.ok(
                    ApiResponse.success("Comment updated successfully", comment)
            );
            
        } catch (RuntimeException e) {
            log.error("Error updating comment {}: {}", commentId, e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<ApiResponse<Void>> deleteComment(@PathVariable UUID commentId) {
        try {
            commentService.deleteComment(commentId);
            return ResponseEntity.ok(
                    ApiResponse.success("Comment deleted successfully", null)
            );
            
        } catch (RuntimeException e) {
            log.error("Error deleting comment {}: {}", commentId, e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/users/{userId}/comments")
    public ResponseEntity<ApiResponse<Page<Comment>>> getCommentsByUser(
            @PathVariable UUID userId,
            Pageable pageable) {
        
        try {
            Page<Comment> comments = commentService.getCommentsByUser(userId, pageable);
            return ResponseEntity.ok(
                    ApiResponse.success("User comments retrieved successfully", comments)
            );
            
        } catch (RuntimeException e) {
            log.error("Error retrieving comments by user {}: {}", userId, e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}