package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.Comment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CommentRepository extends JpaRepository<Comment, UUID> {
    
    @Query("SELECT c FROM Comment c WHERE c.report.id = :reportId AND c.deletedAt IS NULL ORDER BY c.createdAt ASC")
    List<Comment> findByReportIdAndNotDeleted(@Param("reportId") UUID reportId);
    
    @Query("SELECT c FROM Comment c WHERE c.report.id = :reportId AND c.deletedAt IS NULL")
    Page<Comment> findByReportIdAndNotDeleted(@Param("reportId") UUID reportId, Pageable pageable);
    
    @Query("SELECT c FROM Comment c WHERE c.user.id = :userId AND c.deletedAt IS NULL ORDER BY c.createdAt DESC")
    Page<Comment> findByUserIdAndNotDeleted(@Param("userId") UUID userId, Pageable pageable);
}