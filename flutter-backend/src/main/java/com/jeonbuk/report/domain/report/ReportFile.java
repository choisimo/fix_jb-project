package com.jeonbuk.report.domain.report;

import com.jeonbuk.report.domain.common.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 보고서 첨부 파일 엔티티
 */
@Entity
@Table(name = "report_files")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ReportFile extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "file_id")
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "report_id", nullable = false)
    private Report report;
    
    @Column(name = "file_url", nullable = false, length = 512)
    private String fileUrl;
    
    @Column(name = "file_type", nullable = false, length = 50)
    private String fileType;
    
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "sort_order")
    private Integer sortOrder = 0;
    
    @Builder
    public ReportFile(Report report, String fileUrl, String fileType, 
                     String description, Integer sortOrder) {
        this.report = report;
        this.fileUrl = fileUrl;
        this.fileType = fileType;
        this.description = description;
        this.sortOrder = sortOrder != null ? sortOrder : 0;
    }
    
    public void setReport(Report report) {
        this.report = report;
    }
    
    public void updateDescription(String description) {
        this.description = description;
    }
    
    public void updateSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
    
    // 파일 타입 상수
    public static final String TYPE_IMAGE = "IMAGE";
    public static final String TYPE_VIDEO = "VIDEO";
    public static final String TYPE_DOCUMENT = "DOCUMENT";
}
