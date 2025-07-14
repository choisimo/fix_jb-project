package com.jbreport.platform.repository;

import com.jbreport.platform.entity.Report;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long>, JpaSpecificationExecutor<Report> {
    
    @Query("SELECT r FROM Report r WHERE " +
           "(:category IS NULL OR r.category = :category) AND " +
           "(:status IS NULL OR r.status = :status) AND " +
           "(:priority IS NULL OR r.priority = :priority)")
    Page<Report> findWithFilters(@Param("category") String category,
                                @Param("status") String status,
                                @Param("priority") String priority,
                                Pageable pageable);
    
    Page<Report> findByUserId(Long userId, Pageable pageable);
    
    List<Report> findByStatusAndCreatedAtBefore(String status, LocalDateTime date);
    
    @Query("SELECT COUNT(r) FROM Report r WHERE r.status = :status")
    Long countByStatus(@Param("status") String status);
    
    @Query("SELECT r.category, COUNT(r) FROM Report r GROUP BY r.category")
    List<Object[]> countByCategory();
    
    @Query("SELECT r FROM Report r WHERE r.aiAnalyzed = false AND r.createdAt < :date")
    List<Report> findUnanalyzedReports(@Param("date") LocalDateTime date);
}
