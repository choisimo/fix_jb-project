package com.jeonbuk.report.domain.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 상태 엔티티
 * - 신고서 상태 관리
 * - 워크플로우 순서 관리
 * - 최종 상태 구분
 */
@Entity
@Table(name = "statuses")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Status {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id")
  private Long id;

  @Column(name = "name", nullable = false, unique = true, length = 50)
  private String name;

  @Column(name = "description", columnDefinition = "TEXT")
  private String description;

  @Column(name = "color", length = 7)
  private String color; // HEX 색상 코드

  @Column(name = "is_terminal")
  @Builder.Default
  private Boolean isTerminal = false; // 최종 상태 여부

  @Column(name = "order_index")
  @Builder.Default
  private Integer orderIndex = 0;

  @Column(name = "is_active")
  @Builder.Default
  private Boolean isActive = true;

  @CreatedDate
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  // 연관 관계
  @OneToMany(mappedBy = "status", fetch = FetchType.LAZY)
  @JsonIgnore
  @Builder.Default
  private List<Report> reports = new ArrayList<>();

  // 비즈니스 메서드
  public boolean isActive() {
    return Boolean.TRUE.equals(isActive);
  }

  public boolean isTerminal() {
    return Boolean.TRUE.equals(isTerminal);
  }

  public void activate() {
    this.isActive = true;
  }

  public void deactivate() {
    this.isActive = false;
  }

  // Getter 메서드 (Lombok @Data가 생성하지 않는 경우를 대비)
  public Boolean getIsTerminal() {
    return isTerminal;
  }

  public Boolean getIsActive() {
    return isActive;
  }
}
