package com.jeonbuk.report.domain.environment.repository;

import com.jeonbuk.report.domain.environment.EnvironmentVariable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EnvironmentVariableRepository extends JpaRepository<EnvironmentVariable, Long> {

    List<EnvironmentVariable> findByEnvironment(EnvironmentVariable.EnvironmentType environment);

    List<EnvironmentVariable> findByEnvironmentOrEnvironment(
            EnvironmentVariable.EnvironmentType environment1,
            EnvironmentVariable.EnvironmentType environment2
    );

    Optional<EnvironmentVariable> findByKeyNameAndEnvironment(
            String keyName,
            EnvironmentVariable.EnvironmentType environment
    );

    List<EnvironmentVariable> findByCategory(EnvironmentVariable.VariableCategory category);

    List<EnvironmentVariable> findByIsSecretTrue();

    List<EnvironmentVariable> findByIsRequiredTrue();

    @Query("SELECT ev FROM EnvironmentVariable ev WHERE " +
           "(:environment IS NULL OR ev.environment = :environment OR ev.environment = 'ALL') AND " +
           "(:category IS NULL OR ev.category = :category) AND " +
           "(:isSecret IS NULL OR ev.isSecret = :isSecret) AND " +
           "(:keyName IS NULL OR LOWER(ev.keyName) LIKE LOWER(CONCAT('%', :keyName, '%')))")
    Page<EnvironmentVariable> findByFilters(
            @Param("environment") EnvironmentVariable.EnvironmentType environment,
            @Param("category") EnvironmentVariable.VariableCategory category,
            @Param("isSecret") Boolean isSecret,
            @Param("keyName") String keyName,
            Pageable pageable
    );

    @Query("SELECT ev FROM EnvironmentVariable ev WHERE " +
           "(ev.environment = :environment OR ev.environment = 'ALL') AND " +
           "ev.isRequired = true AND " +
           "(ev.value IS NULL OR ev.value = '')")
    List<EnvironmentVariable> findMissingRequiredVariables(
            @Param("environment") EnvironmentVariable.EnvironmentType environment
    );
}