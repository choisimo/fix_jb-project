package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Comment;
import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.domain.repository.CommentRepository;
import com.jeonbuk.report.domain.repository.ReportRepository;
import com.jeonbuk.report.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class CommentService {

    private final CommentRepository commentRepository;
    private final ReportRepository reportRepository;
    private final UserRepository userRepository;

    public Comment createComment(UUID reportId, UUID userId, String content) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found with id: " + reportId));
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        Comment comment = Comment.builder()
                .report(report)
                .user(user)
                .content(content)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        return commentRepository.save(comment);
    }

    @Transactional(readOnly = true)
    public List<Comment> getCommentsByReportId(UUID reportId) {
        return commentRepository.findByReportIdAndNotDeleted(reportId);
    }

    @Transactional(readOnly = true)
    public Page<Comment> getCommentsByReportId(UUID reportId, Pageable pageable) {
        return commentRepository.findByReportIdAndNotDeleted(reportId, pageable);
    }

    @Transactional(readOnly = true)
    public Page<Comment> getCommentsByUser(UUID userId, Pageable pageable) {
        return commentRepository.findByUserIdAndNotDeleted(userId, pageable);
    }

    public Comment updateComment(UUID commentId, String content) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found with id: " + commentId));

        if (comment.isDeleted()) {
            throw new RuntimeException("Cannot update deleted comment");
        }

        comment.setContent(content);
        comment.setUpdatedAt(LocalDateTime.now());

        return commentRepository.save(comment);
    }

    public void deleteComment(UUID commentId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found with id: " + commentId));

        comment.softDelete();
        commentRepository.save(comment);
        
        log.info("Comment {} has been soft deleted", commentId);
    }

    @Transactional(readOnly = true)
    public Comment getCommentById(UUID commentId) {
        return commentRepository.findById(commentId)
                .filter(comment -> !comment.isDeleted())
                .orElseThrow(() -> new RuntimeException("Comment not found with id: " + commentId));
    }
}