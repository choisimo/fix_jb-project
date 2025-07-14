package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.ReportCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * 신고 카테고리 Repository
 */
@Repository
public interface ReportCategoryRepository extends JpaRepository<ReportCategory, UUID> {

    /**
     * 카테고리 이름으로 조회
     */
    Optional<ReportCategory> findByName(String name);

    /**
     * 카테고리 코드로 조회
     */
    Optional<ReportCategory> findByCode(String code);

    /**
     * 활성화된 카테고리만 조회
     */
    Optional<ReportCategory> findByNameAndIsActiveTrue(String name);
}
