package com.jeonbuk.report.domain.report;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 보고서 카테고리 엔티티
 */
@Entity
@Table(name = "report_categories")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ReportCategory {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private Long id;
    
    @Column(name = "name", unique = true, nullable = false, length = 100)
    private String name;
    
    @Builder
    public ReportCategory(String name) {
        this.name = name;
    }
    
    public void updateName(String name) {
        this.name = name;
    }
}
