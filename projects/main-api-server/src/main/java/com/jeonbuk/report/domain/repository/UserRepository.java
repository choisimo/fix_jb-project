package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 사용자 리포지토리
 * - 기본 CRUD 및 커스텀 쿼리 메서드
 * - OAuth 사용자 조회
 * - 역할별 사용자 검색
 */
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

  // 기본 조회 메서드
  Optional<User> findByEmail(String email);

  Optional<User> findByEmailAndIsActiveTrue(String email);

  boolean existsByEmail(String email);

  boolean existsByPhone(String phone);

  boolean existsByNameAndIsActiveTrue(String name);

  // OAuth 관련 메서드
  Optional<User> findByOauthProviderAndOauthId(String oauthProvider, String oauthId);

  Optional<User> findByOauthProviderAndOauthEmail(String oauthProvider, String oauthEmail);

  // 역할별 조회
  List<User> findByRole(User.UserRole role);

  List<User> findByRoleAndIsActiveTrue(User.UserRole role);

  // 활성 사용자 조회
  List<User> findByIsActiveTrue();

  Page<User> findByIsActiveTrue(Pageable pageable);

  // 검색 메서드
  @Query("SELECT u FROM User u WHERE " +
      "(LOWER(u.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
      "LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%'))) AND " +
      "u.isActive = true")
  Page<User> searchActiveUsers(@Param("keyword") String keyword, Pageable pageable);

  // 부서별 조회
  List<User> findByDepartmentAndIsActiveTrue(String department);

  // 최근 로그인 사용자
  @Query("SELECT u FROM User u WHERE u.isActive = true AND u.lastLogin >= :since ORDER BY u.lastLogin DESC")
  List<User> findRecentlyActiveUsers(@Param("since") LocalDateTime since);

  // 관리자 조회
  @Query("SELECT u FROM User u WHERE u.role IN ('MANAGER', 'ADMIN') AND u.isActive = true")
  List<User> findActiveManagers();

  // 통계 쿼리
  @Query("SELECT COUNT(u) FROM User u WHERE u.isActive = true")
  long countActiveUsers();
  
  // Alternative method name for compatibility
  long countByIsActiveTrue();

  @Query("SELECT COUNT(u) FROM User u WHERE u.role = :role AND u.isActive = true")
  long countByRoleAndActive(@Param("role") User.UserRole role);

  // OAuth 사용자 통계
  @Query("SELECT COUNT(u) FROM User u WHERE u.oauthProvider IS NOT NULL AND u.isActive = true")
  long countOAuthUsers();

  @Query("SELECT u.oauthProvider, COUNT(u) FROM User u WHERE u.oauthProvider IS NOT NULL AND u.isActive = true GROUP BY u.oauthProvider")
  List<Object[]> countByOAuthProvider();
}
