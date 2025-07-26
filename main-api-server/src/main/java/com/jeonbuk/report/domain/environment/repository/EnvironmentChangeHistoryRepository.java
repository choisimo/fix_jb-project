package com.jeonbuk.report.domain.environment.repository;

import com.jeonbuk.report.domain.environment.EnvironmentChangeHistory;
import com.jeonbuk.report.domain.environment.EnvironmentVariable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EnvironmentChangeHistoryRepository extends JpaRepository<EnvironmentChangeHistory, Long> {

    List<EnvironmentChangeHistory> findByKeyNameOrderByModifiedAtDesc(String keyName);

    List<EnvironmentChangeHistory> findByEnvironmentOrderByModifiedAtDesc(
            EnvironmentVariable.EnvironmentType environment
    );

    Page<EnvironmentChangeHistory> findByModifiedByOrderByModifiedAtDesc(
            String modifiedBy,
            Pageable pageable
    );

    @Query("SELECT ech FROM EnvironmentChangeHistory ech WHERE " +
           "ech.modifiedAt BETWEEN :startDate AND :endDate " +
           "ORDER BY ech.modifiedAt DESC")
    List<EnvironmentChangeHistory> findByDateRange(
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    @Query("SELECT ech FROM EnvironmentChangeHistory ech WHERE " +
           "(:environment IS NULL OR ech.environment = :environment) AND " +
           "(:changeType IS NULL OR ech.changeType = :changeType) AND " +
           "(:status IS NULL OR ech.status = :status) AND " +
           "(:modifiedBy IS NULL OR LOWER(ech.modifiedBy) LIKE LOWER(CONCAT('%', :modifiedBy, '%'))) AND " +
           "(:keyName IS NULL OR LOWER(ech.keyName) LIKE LOWER(CONCAT('%', :keyName, '%'))) " +
           "ORDER BY ech.modifiedAt DESC")
    Page<EnvironmentChangeHistory> findByFilters(
            @Param("environment") EnvironmentVariable.EnvironmentType environment,
            @Param("changeType") EnvironmentChangeHistory.ChangeType changeType,
            @Param("status") EnvironmentChangeHistory.ChangeStatus status,
            @Param("modifiedBy") String modifiedBy,
            @Param("keyName") String keyName,
            Pageable pageable
    );

    List<EnvironmentChangeHistory> findByStatusAndEnvironment(
            EnvironmentChangeHistory.ChangeStatus status,
            EnvironmentVariable.EnvironmentType environment
    );
}