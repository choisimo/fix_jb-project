package com.jeonbuk.report.domain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 신고서 서명 엔티티
 */
@Entity
@Table(name = "report_signatures")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class ReportSignature {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(name = "id")
  private UUID id;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "report_id", nullable = false)
  private Report report;

  @Column(name = "signature_type", nullable = false, length = 50)
  private String signatureType;

  @Column(name = "signature_data", columnDefinition = "TEXT")
  private String signatureData;

  @Column(name = "signer_name", length = 100)
  private String signerName;

  @Column(name = "signer_role", length = 50)
  private String signerRole;

  @Column(name = "signed_at")
  private LocalDateTime signedAt;

  @CreatedDate
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;
}
