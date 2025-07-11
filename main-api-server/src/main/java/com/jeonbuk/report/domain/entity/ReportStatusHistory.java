package com.jeonbuk.report.domain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "report_status_histories")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportStatusHistory {
    
    @Id
    @Column(name = "id")
    private String id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "report_id")
    private Report report;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "changed_by_user_id")
    private User changedBy;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "previous_status_id")
    private Status previousStatus;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "new_status_id")
    private Status newStatus;
    
    @Column(name = "reason")
    private String reason;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}