package com.jeonbuk.report.domain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 댓글 엔티티
 * - 신고서 댓글 관리
 * - 대댓글 지원 (자기 참조)
 * - 내부 댓글 및 시스템 댓글 구분
 * - 첨부파일 지원
 */
@Entity
@Table(name = "comments")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Comment {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(name = "id")
  private UUID id;

  // 연관 관계
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "report_id", nullable = false)
  private Report report;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "parent_id")
  private Comment parent; // 대댓글을 위한 부모 댓글

  // 댓글 내용
  @Column(name = "content", nullable = false, columnDefinition = "TEXT")
  private String content;

  @Column(name = "is_internal")
  @Builder.Default
  private Boolean isInternal = false; // 내부 댓글 여부 (관리자만 볼 수 있음)

  @Column(name = "is_system")
  @Builder.Default
  private Boolean isSystem = false; // 시스템 자동 생성 댓글

  // 첨부파일
  @Column(name = "attachment_path", length = 500)
  private String attachmentPath;

  @Column(name = "attachment_url", length = 500)
  private String attachmentUrl;

  // 메타데이터
  @CreatedDate
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @LastModifiedDate
  @Column(name = "updated_at")
  private LocalDateTime updatedAt;

  @Column(name = "deleted_at")
  private LocalDateTime deletedAt; // 소프트 삭제

  // 자식 댓글들 (대댓글)
  @OneToMany(mappedBy = "parent", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  @Builder.Default
  private List<Comment> replies = new ArrayList<>();

  // 비즈니스 메서드
  public boolean isDeleted() {
    return deletedAt != null;
  }

  public boolean isInternal() {
    return Boolean.TRUE.equals(isInternal);
  }

  public boolean isSystem() {
    return Boolean.TRUE.equals(isSystem);
  }

  public boolean isReply() {
    return parent != null;
  }

  public boolean hasAttachment() {
    return attachmentPath != null && !attachmentPath.isEmpty();
  }

  public void softDelete() {
    this.deletedAt = LocalDateTime.now();
  }

  public void restore() {
    this.deletedAt = null;
  }

  // 대댓글 추가
  public void addReply(Comment reply) {
    reply.setParent(this);
    this.replies.add(reply);
  }

  // 댓글 수정
  public void updateContent(String newContent) {
    this.content = newContent;
    this.updatedAt = LocalDateTime.now();
  }

  // Lombok이 작동하지 않을 경우를 위한 수동 setter
  public void setParent(Comment parent) {
    this.parent = parent;
  }
}
