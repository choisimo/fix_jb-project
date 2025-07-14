package com.jeonbuk.report.domain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 신고서 파일 엔티티
 * - 이미지/비디오 파일 관리
 * - 메타데이터 및 EXIF 정보 저장
 * - 썸네일 지원
 * - 파일 순서 및 대표 이미지 관리
 */
@Entity
@Table(name = "report_files")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class ReportFile {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(name = "id")
  private UUID id;

  // 연관 관계
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "report_id", nullable = false)
  private Report report;

  // 파일 정보
  @Column(name = "original_filename", nullable = false)
  private String originalFilename;

  @Column(name = "file_path", nullable = false, length = 500)
  private String filePath; // 실제 저장 경로

  @Column(name = "file_url", length = 500)
  private String fileUrl; // 접근 가능한 URL

  @Column(name = "file_size", nullable = false)
  private Long fileSize; // 바이트 단위

  @Column(name = "file_type", nullable = false, length = 50)
  private String fileType; // MIME 타입

  @Column(name = "file_hash", length = 64)
  private String fileHash; // SHA-256 해시 (중복 검사용)

  // 이미지 메타데이터
  @Column(name = "image_width")
  private Integer imageWidth;

  @Column(name = "image_height")
  private Integer imageHeight;

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(name = "exif_data", columnDefinition = "TEXT")
  private Map<String, Object> exifData; // EXIF 정보

  // 썸네일 정보
  @Column(name = "thumbnail_path", length = 500)
  private String thumbnailPath;

  @Column(name = "thumbnail_url", length = 500)
  private String thumbnailUrl;

  // 순서 및 분류
  @Column(name = "file_order")
  @Builder.Default
  private Integer fileOrder = 0; // 파일 순서

  @Column(name = "is_primary")
  @Builder.Default
  private Boolean isPrimary = false; // 대표 이미지 여부

  @JdbcTypeCode(SqlTypes.JSON)
  @Column(name = "tags", columnDefinition = "TEXT")
  private List<String> tags; // 태그 배열

  // 메타데이터
  @CreatedDate
  @Column(name = "uploaded_at", nullable = false, updatable = false)
  private LocalDateTime uploadedAt;

  @Column(name = "deleted_at")
  private LocalDateTime deletedAt; // 소프트 삭제

  // 비즈니스 메서드
  public boolean isDeleted() {
    return deletedAt != null;
  }

  public boolean isImage() {
    return fileType != null && fileType.startsWith("image/");
  }

  public boolean isVideo() {
    return fileType != null && fileType.startsWith("video/");
  }

  public boolean isPrimary() {
    return Boolean.TRUE.equals(isPrimary);
  }

  public void softDelete() {
    this.deletedAt = LocalDateTime.now();
  }

  public void restore() {
    this.deletedAt = null;
  }

  public void setPrimary() {
    this.isPrimary = true;
  }

  public void unsetPrimary() {
    this.isPrimary = false;
  }

  // 파일 크기를 사람이 읽기 쉬운 형태로 반환
  public String getHumanReadableFileSize() {
    if (fileSize == null)
      return "Unknown";

    long bytes = fileSize;
    if (bytes < 1024)
      return bytes + " B";
    int exp = (int) (Math.log(bytes) / Math.log(1024));
    String pre = "KMGTPE".charAt(exp - 1) + "i";
    return String.format("%.1f %sB", bytes / Math.pow(1024, exp), pre);
  }
}
