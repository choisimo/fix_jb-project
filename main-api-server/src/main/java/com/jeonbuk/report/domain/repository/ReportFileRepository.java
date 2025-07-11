package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.ReportFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReportFileRepository extends JpaRepository<ReportFile, UUID> {
    
    @Query("SELECT rf FROM ReportFile rf WHERE rf.report.id = :reportId AND rf.deletedAt IS NULL ORDER BY rf.fileOrder ASC")
    List<ReportFile> findByReportIdAndNotDeleted(@Param("reportId") UUID reportId);
    
    @Query("SELECT rf FROM ReportFile rf WHERE rf.report.id = :reportId AND rf.isPrimary = true AND rf.deletedAt IS NULL")
    ReportFile findPrimaryByReportId(@Param("reportId") UUID reportId);
    
    @Query("SELECT rf FROM ReportFile rf WHERE rf.fileHash = :hash AND rf.deletedAt IS NULL")
    List<ReportFile> findByFileHash(@Param("hash") String hash);
}