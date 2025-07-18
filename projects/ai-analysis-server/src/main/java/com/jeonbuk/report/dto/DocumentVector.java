package com.jeonbuk.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 문서 벡터 엔티티 (데이터베이스 저장용)
 */
@Entity
@Table(name = "document_vectors")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DocumentVector {
    
    /**
     * 벡터 ID
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 원본 문서 ID
     */
    @Column(name = "document_id", nullable = false)
    private String documentId;
    
    /**
     * 컨텐츠 타입
     */
    @Column(name = "content_type")
    private String contentType;
    
    /**
     * 청크 텍스트
     */
    @Column(name = "chunk_text", columnDefinition = "TEXT")
    private String chunkText;
    
    /**
     * 청크 인덱스
     */
    @Column(name = "chunk_index")
    private Integer chunkIndex;
    
    /**
     * 임베딩 벡터 (1536차원)
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "embedding", columnDefinition = "jsonb")
    private List<Float> embedding;
    
    /**
     * 메타데이터 (JSONB)
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "metadata", columnDefinition = "jsonb")
    private Map<String, Object> metadata;
    
    /**
     * 생성 시간
     */
    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
    
    /**
     * 수정 시간
     */
    @Column(name = "updated_at")
    @Builder.Default
    private LocalDateTime updatedAt = LocalDateTime.now();
    
    /**
     * JPA 이벤트 처리
     */
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    /**
     * 임베딩 차원 수
     */
    public int getEmbeddingDimension() {
        return embedding != null ? embedding.size() : 0;
    }
    
    /**
     * 메타데이터에서 특정 값 추출
     */
    public Object getMetadataValue(String key) {
        return metadata != null ? metadata.get(key) : null;
    }
    
    /**
     * 임베딩 벡터를 배열로 변환
     */
    public float[] getEmbeddingArray() {
        if (embedding == null) {
            return new float[0];
        }
        
        float[] array = new float[embedding.size()];
        for (int i = 0; i < embedding.size(); i++) {
            array[i] = embedding.get(i);
        }
        return array;
    }
}