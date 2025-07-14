package com.jeonbuk.report.domain.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;

import org.hibernate.type.SqlTypes;
import org.locationtech.jts.geom.Point;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 신고서 엔티티
 * - 사용자 신고 정보 관리
 * - AI 분석 결과 저장
 * - 위치 정보 및 PostGIS 지원
 * - 상태 관리 및 이력 추적
 */
@Entity
@Table(name = "reports")
@Data
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Report {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(name = "id")
  private UUID id;

  // 기본 정보
  @Column(name = "title", nullable = false, length = 200)
  private String title;

  @Column(name = "description", nullable = false, columnDefinition = "TEXT")
  private String description;

  @Enumerated(EnumType.STRING)
  @Column(name = "priority")
  @Builder.Default
  private Priority priority = Priority.MEDIUM;

  // 연관 관계
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "category_id")
  private Category category;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "status_id")
  private Status status;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "manager_id")
  private User manager;

  // 위치 정보
  @Column(name = "latitude", precision = 10, scale = 8)
  private BigDecimal latitude;

  @Column(name = "longitude", precision = 11, scale = 8)
  private BigDecimal longitude;

  @Column(name = "address", columnDefinition = "TEXT")
  private String address;

  @Column(name = "location_point", columnDefinition = "geometry(Point,4326)")
  private Point locationPoint;

  // AI 분석 정보
  @JdbcTypeCode(SqlTypes.JSON)
  @Column(name = "ai_analysis_results", columnDefinition = "TEXT")
  private Map<String, Object> aiAnalysisResults;

  @Column(name = "ai_confidence_score", precision = 5, scale = 2)
  private BigDecimal aiConfidenceScore;

  @Column(name = "is_complex_subject")
  @Builder.Default
  private Boolean isComplexSubject = false;

  @Column(name = "primary_image_index")
  @Builder.Default
  private Integer primaryImageIndex = 0;

  // 관리 정보
  @Column(name = "manager_notes", columnDefinition = "TEXT")
  private String managerNotes;

  @Column(name = "estimated_completion")
  private LocalDate estimatedCompletion;

  @Column(name = "actual_completion")
  private LocalDate actualCompletion;

  @Column(name = "completed_at")
  private LocalDateTime completedAt;

  @Column(name = "observation", columnDefinition = "TEXT")
  private String observation;

  @Column(name = "equipment", columnDefinition = "TEXT")
  private String equipment;

  @Column(name = "action_taken", columnDefinition = "TEXT")
  private String actionTaken;

  @Column(name = "estimated_cost")
  private BigDecimal estimatedCost;

  @Column(name = "external_id")
  private String externalId;

  // 서명 및 인증
  @Column(name = "signature_data", columnDefinition = "TEXT")
  private String signatureData;

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(name = "device_info", columnDefinition = "TEXT")
  private Map<String, Object> deviceInfo;

  // 메타데이터
  @CreatedDate
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @LastModifiedDate
  @Column(name = "updated_at")
  private LocalDateTime updatedAt;

  @Column(name = "deleted_at")
  private LocalDateTime deletedAt;

  // 연관 관계 (컬렉션)
  @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  @JsonIgnore
  @Builder.Default
  private List<ReportFile> files = new ArrayList<>();

  @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  @JsonIgnore
  @Builder.Default
  private List<Comment> comments = new ArrayList<>();

  @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  @JsonIgnore
  @Builder.Default
  private List<ReportStatusHistory> statusHistories = new ArrayList<>();

  @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  @JsonIgnore
  @Builder.Default
  private List<Notification> notifications = new ArrayList<>();

  // 비즈니스 메서드
  public boolean isDeleted() {
    return deletedAt != null;
  }

  public boolean isCompleted() {
    return status != null && status.getIsTerminal();
  }

  public boolean hasLocation() {
    return latitude != null && longitude != null;
  }

  public boolean hasAiAnalysis() {
    return aiAnalysisResults != null && !aiAnalysisResults.isEmpty();
  }

  public void softDelete() {
    this.deletedAt = LocalDateTime.now();
  }

  public void restore() {
    this.deletedAt = null;
  }

  // 우선순위 열거형
  public enum Priority {
    LOW("낮음"),
    MEDIUM("보통"),
    HIGH("높음"),
    URGENT("긴급");

    private final String description;

    Priority(String description) {
      this.description = description;
    }

    public String getDescription() {
      return description;
    }
  }
}
