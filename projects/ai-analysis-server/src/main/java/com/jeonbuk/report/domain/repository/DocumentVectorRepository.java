package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.dto.DocumentVector;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 문서 벡터 저장소 Repository (간소화된 버전)
 * 복잡한 벡터 검색 기능은 추후 구현 예정
 */
@Repository
public interface DocumentVectorRepository extends JpaRepository<DocumentVector, Long> {

    /**
     * 문서 ID로 벡터 조회
     */
    List<DocumentVector> findByDocumentId(String documentId);

    /**
     * 문서 ID로 벡터 삭제
     */
    @Modifying
    @Transactional
    @Query("DELETE FROM DocumentVector dv WHERE dv.documentId = :documentId")
    void deleteByDocumentId(@Param("documentId") String documentId);

    /**
     * 컨텐츠 타입으로 벡터 조회
     */
    List<DocumentVector> findByContentType(String contentType);

    /**
     * 문서 ID와 청크 인덱스로 특정 벡터 조회
     */
    DocumentVector findByDocumentIdAndChunkIndex(String documentId, Integer chunkIndex);

    /**
     * 전체 문서 수 조회
     */
    @Query("SELECT COUNT(DISTINCT dv.documentId) FROM DocumentVector dv")
    long countDistinctDocuments();

    /**
     * 컨텐츠 타입별 통계 조회
     */
    @Query("SELECT dv.contentType, COUNT(dv) " +
           "FROM DocumentVector dv GROUP BY dv.contentType")
    List<Object[]> getContentTypeStatistics();

    /**
     * 최근 생성된 벡터 조회 (상위 10개)
     */
    @Query("SELECT dv FROM DocumentVector dv ORDER BY dv.createdAt DESC")
    List<DocumentVector> findTop10ByOrderByCreatedAtDesc();

    /**
     * 컨텐츠 타입과 문서 ID로 벡터 조회
     */
    List<DocumentVector> findByContentTypeAndDocumentId(String contentType, String documentId);
}