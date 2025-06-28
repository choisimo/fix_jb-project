package com.jeonbuk.report.domain.report;

import com.jeonbuk.report.domain.common.BaseEntity;
import com.jeonbuk.report.domain.user.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 댓글 엔티티
 */
@Entity
@Table(name = "comments")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Comment extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "comment_id")
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "report_id", nullable = false)
    private Report report;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;
    
    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content;
    
    @Builder
    public Comment(Report report, User author, String content) {
        this.report = report;
        this.author = author;
        this.content = content;
    }
    
    public void updateContent(String content) {
        this.content = content;
    }
    
    public boolean isAuthor(User user) {
        return this.author.getId().equals(user.getId());
    }
}
