package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 신고서 리포지토리
 * - 기본 CRUD 및 복합 검색 쿼리
 * - 위치 기반 검색 (PostGIS)
 * - 상태 및 카테고리별 조회
 * - 통계 쿼리
 */
@Repository
public interface ReportRepository extends JpaRepository<Report, UUID> {

  // 기본 조회 (소프트 삭제 제외)
  @Query("SELECT r FROM Report r WHERE r.deletedAt IS NULL")
  List<Report> findAllActive();

  @Query("SELECT r FROM Report r WHERE r.deletedAt IS NULL")
  Page<Report> findAllActive(Pageable pageable);

  Optional<Report> findByIdAndDeletedAtIsNull(UUID id);

  // 사용자별 조회
  List<Report> findByUserAndDeletedAtIsNull(User user);

  Page<Report> findByUserAndDeletedAtIsNull(User user, Pageable pageable);

  // 상태별 조회
  @Query("SELECT r FROM Report r WHERE r.status.id = :statusId AND r.deletedAt IS NULL")
  List<Report> findByStatusId(@Param("statusId") Long statusId);

  @Query("SELECT r FROM Report r WHERE r.status.id = :statusId AND r.deletedAt IS NULL")
  Page<Report> findByStatusId(@Param("statusId") Long statusId, Pageable pageable);

  // 카테고리별 조회
  @Query("SELECT r FROM Report r WHERE r.category.id = :categoryId AND r.deletedAt IS NULL")
  List<Report> findByCategoryId(@Param("categoryId") Long categoryId);

  @Query("SELECT r FROM Report r WHERE r.category.id = :categoryId AND r.deletedAt IS NULL")
  Page<Report> findByCategoryId(@Param("categoryId") Long categoryId, Pageable pageable);

  // 우선순위별 조회
  List<Report> findByPriorityAndDeletedAtIsNull(Report.Priority priority);

  // 관리자별 조회
  List<Report> findByManagerAndDeletedAtIsNull(User manager);

  Page<Report> findByManagerAndDeletedAtIsNull(User manager, Pageable pageable);

  // 복합 검색
  @Query("SELECT r FROM Report r WHERE " +
      "(:keyword IS NULL OR " +
      "LOWER(r.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
      "LOWER(r.description) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
      "LOWER(r.address) LIKE LOWER(CONCAT('%', :keyword, '%'))) AND " +
      "(:categoryId IS NULL OR r.category.id = :categoryId) AND " +
      "(:statusId IS NULL OR r.status.id = :statusId) AND " +
      "(:priority IS NULL OR r.priority = :priority) AND " +
      "(:userId IS NULL OR r.user.id = :userId) AND " +
      "(:managerId IS NULL OR r.manager.id = :managerId) AND " +
      "r.deletedAt IS NULL")
  Page<Report> searchReports(
      @Param("keyword") String keyword,
      @Param("categoryId") Long categoryId,
      @Param("statusId") Long statusId,
      @Param("priority") Report.Priority priority,
      @Param("userId") UUID userId,
      @Param("managerId") UUID managerId,
      Pageable pageable);

  // 위치 기반 검색 (PostGIS)
  @Query(value = "SELECT * FROM reports r WHERE " +
      "ST_DWithin(r.location_point, ST_MakePoint(:longitude, :latitude)::geography, :radiusMeters) AND " +
      "r.deleted_at IS NULL", nativeQuery = true)
  List<Report> findByLocationWithinRadius(
      @Param("latitude") BigDecimal latitude,
      @Param("longitude") BigDecimal longitude,
      @Param("radiusMeters") double radiusMeters);

  // 날짜 범위 조회
  @Query("SELECT r FROM Report r WHERE " +
      "r.createdAt >= :startDate AND r.createdAt <= :endDate AND " +
      "r.deletedAt IS NULL")
  List<Report> findByCreatedAtBetween(
      @Param("startDate") LocalDateTime startDate,
      @Param("endDate") LocalDateTime endDate);

  @Query("SELECT r FROM Report r WHERE " +
      "r.createdAt >= :startDate AND r.createdAt <= :endDate AND " +
      "r.deletedAt IS NULL")
  Page<Report> findByCreatedAtBetween(
      @Param("startDate") LocalDateTime startDate,
      @Param("endDate") LocalDateTime endDate,
      Pageable pageable);

  // AI 분석 관련
  List<Report> findByIsComplexSubjectTrueAndDeletedAtIsNull();

  @Query("SELECT r FROM Report r WHERE r.aiAnalysisResults IS NOT NULL AND r.deletedAt IS NULL")
  List<Report> findWithAiAnalysis();

  @Query("SELECT r FROM Report r WHERE r.aiConfidenceScore >= :minScore AND r.deletedAt IS NULL")
  List<Report> findByAiConfidenceScoreGreaterThanEqual(@Param("minScore") BigDecimal minScore);

  // 통계 쿼리
  @Query("SELECT COUNT(r) FROM Report r WHERE r.deletedAt IS NULL")
  long countActive();

  @Query("SELECT COUNT(r) FROM Report r WHERE r.status.id = :statusId AND r.deletedAt IS NULL")
  long countByStatusId(@Param("statusId") Long statusId);

  @Query("SELECT COUNT(r) FROM Report r WHERE r.category.id = :categoryId AND r.deletedAt IS NULL")
  long countByCategoryId(@Param("categoryId") Long categoryId);

  @Query("SELECT COUNT(r) FROM Report r WHERE r.priority = :priority AND r.deletedAt IS NULL")
  long countByPriority(@Param("priority") Report.Priority priority);

  @Query("SELECT COUNT(r) FROM Report r WHERE r.user.id = :userId AND r.deletedAt IS NULL")
  long countByUserId(@Param("userId") UUID userId);

  // 월별 통계
  @Query("SELECT YEAR(r.createdAt), MONTH(r.createdAt), COUNT(r) FROM Report r " +
      "WHERE r.deletedAt IS NULL AND r.createdAt >= :startDate " +
      "GROUP BY YEAR(r.createdAt), MONTH(r.createdAt) " +
      "ORDER BY YEAR(r.createdAt), MONTH(r.createdAt)")
  List<Object[]> getMonthlyStatistics(@Param("startDate") LocalDateTime startDate);

  // 상태별 통계
  @Query("SELECT s.name, COUNT(r) FROM Report r JOIN r.status s WHERE r.deletedAt IS NULL GROUP BY s.name")
  List<Object[]> getStatusStatistics();

  // 카테고리별 통계
  @Query("SELECT c.name, COUNT(r) FROM Report r JOIN r.category c WHERE r.deletedAt IS NULL GROUP BY c.name")
  List<Object[]> getCategoryStatistics();
}
