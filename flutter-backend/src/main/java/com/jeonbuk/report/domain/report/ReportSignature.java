package com.jeonbuk.report.domain.report;

import com.jeonbuk.report.domain.common.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 보고서 서명 엔티티
 */
@Entity
@Table(name = "report_signatures")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ReportSignature extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "signature_id")
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "report_id", nullable = false)
    private Report report;
    
    @Column(name = "signature_url", nullable = false, length = 512)
    private String signatureUrl;
    
    @Builder
    public ReportSignature(Report report, String signatureUrl) {
        this.report = report;
        this.signatureUrl = signatureUrl;
    }
    
    public void setReport(Report report) {
        this.report = report;
    }
}
