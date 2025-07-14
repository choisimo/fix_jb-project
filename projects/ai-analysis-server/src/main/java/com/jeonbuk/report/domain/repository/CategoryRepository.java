package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * 카테고리 Repository
 */
@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    /**
     * 카테고리 이름으로 조회
     */
    Optional<Category> findByName(String name);

    /**
     * 활성화된 카테고리만 조회
     */
    Optional<Category> findByNameAndIsActiveTrue(String name);
}