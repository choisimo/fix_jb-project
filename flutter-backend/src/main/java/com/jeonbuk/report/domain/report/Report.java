package com.jeonbuk.report.domain.report;

import com.jeonbuk.report.domain.common.BaseEntity;
import com.jeonbuk.report.domain.user.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 보고서 엔티티
 */
@Entity
@Table(name = "reports")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Report extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private ReportCategory category;
    
    @Column(name = "title", nullable = false, length = 255)
    private String title;
    
    @Column(name = "content", columnDefinition = "TEXT")
    private String content;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ReportStatus status = ReportStatus.DRAFT;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "priority", nullable = false, length = 20)
    private ReportPriority priority = ReportPriority.MEDIUM;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "location", columnDefinition = "jsonb")
    private Map<String, Object> location;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approver_id")
    private User approver;
    
    @Column(name = "approved_at")
    private LocalDateTime approvedAt;
    
    @Column(name = "feedback", columnDefinition = "TEXT")
    private String feedback;
    
    @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ReportFile> reportFiles = new ArrayList<>();
    
    @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ReportSignature> reportSignatures = new ArrayList<>();
    
    @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Comment> comments = new ArrayList<>();
    
    @Builder
    public Report(User author, ReportCategory category, String title, String content,
                  ReportStatus status, ReportPriority priority, Map<String, Object> location) {
        this.author = author;
        this.category = category;
        this.title = title;
        this.content = content;
        this.status = status != null ? status : ReportStatus.DRAFT;
        this.priority = priority != null ? priority : ReportPriority.MEDIUM;
        this.location = location;
    }
    
    // 비즈니스 메서드
    public void submit() {
        if (this.status != ReportStatus.DRAFT) {
            throw new IllegalStateException("초안 상태의 보고서만 제출할 수 있습니다.");
        }
        this.status = ReportStatus.SUBMITTED;
    }
    
    public void approve(User approver, String feedback) {
        if (this.status != ReportStatus.SUBMITTED) {
            throw new IllegalStateException("제출된 보고서만 승인할 수 있습니다.");
        }
        this.status = ReportStatus.APPROVED;
        this.approver = approver;
        this.approvedAt = LocalDateTime.now();
        this.feedback = feedback;
    }
    
    public void reject(User approver, String feedback) {
        if (this.status != ReportStatus.SUBMITTED) {
            throw new IllegalStateException("제출된 보고서만 반려할 수 있습니다.");
        }
        this.status = ReportStatus.REJECTED;
        this.approver = approver;
        this.approvedAt = LocalDateTime.now();
        this.feedback = feedback;
    }
    
    public void update(String title, String content, ReportCategory category, 
                      ReportPriority priority, Map<String, Object> location) {
        if (this.status != ReportStatus.DRAFT) {
            throw new IllegalStateException("초안 상태의 보고서만 수정할 수 있습니다.");
        }
        this.title = title;
        this.content = content;
        this.category = category;
        this.priority = priority;
        this.location = location;
    }
    
    public void addFile(ReportFile reportFile) {
        this.reportFiles.add(reportFile);
        reportFile.setReport(this);
    }
    
    public void addSignature(ReportSignature signature) {
        this.reportSignatures.add(signature);
        signature.setReport(this);
    }
    
    public boolean canBeModified() {
        return this.status == ReportStatus.DRAFT;
    }
    
    public boolean canBeApproved() {
        return this.status == ReportStatus.SUBMITTED;
    }
}
