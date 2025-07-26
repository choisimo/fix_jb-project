package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.EnvironmentChangeHistoryService;
import com.jeonbuk.report.domain.environment.EnvironmentChangeHistory;
import com.jeonbuk.report.domain.environment.EnvironmentVariable;
import com.jeonbuk.report.dto.common.ApiResponse;
import com.jeonbuk.report.dto.environment.EnvironmentChangeHistoryDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/environment/history")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Environment Change History", description = "환경변수 변경 이력 관리 API")
@PreAuthorize("hasRole('ADMIN') or hasRole('SYSTEM_ADMIN')")
public class EnvironmentChangeHistoryController {

    private final EnvironmentChangeHistoryService historyService;

    @GetMapping
    @Operation(summary = "환경변수 변경 이력 조회", description = "필터링 조건에 따라 환경변수 변경 이력을 조회합니다")
    public ResponseEntity<ApiResponse<Page<EnvironmentChangeHistoryDto.Response>>> getChangeHistory(
            @Parameter(description = "환경 타입") @RequestParam(required = false) EnvironmentVariable.EnvironmentType environment,
            @Parameter(description = "변경 타입") @RequestParam(required = false) EnvironmentChangeHistory.ChangeType changeType,
            @Parameter(description = "변경 상태") @RequestParam(required = false) EnvironmentChangeHistory.ChangeStatus status,
            @Parameter(description = "수정자") @RequestParam(required = false) String modifiedBy,
            @Parameter(description = "키 이름") @RequestParam(required = false) String keyName,
            Pageable pageable) {

        Page<EnvironmentChangeHistoryDto.Response> histories = historyService
                .getChangeHistory(environment, changeType, status, modifiedBy, keyName, pageable);

        return ResponseEntity.ok(ApiResponse.success(histories));
    }

    @GetMapping("/variable/{keyName}")
    @Operation(summary = "특정 환경변수 변경 이력", description = "특정 환경변수의 모든 변경 이력을 조회합니다")
    public ResponseEntity<ApiResponse<List<EnvironmentChangeHistoryDto.Response>>> getVariableHistory(
            @Parameter(description = "환경변수 키 이름") @PathVariable String keyName) {

        List<EnvironmentChangeHistoryDto.Response> histories = historyService.getVariableHistory(keyName);
        return ResponseEntity.ok(ApiResponse.success(histories));
    }

    @GetMapping("/pending")
    @Operation(summary = "승인 대기 중인 변경 사항", description = "승인 대기 중인 환경변수 변경 사항을 조회합니다")
    public ResponseEntity<ApiResponse<List<EnvironmentChangeHistoryDto.Response>>> getPendingChanges(
            @Parameter(description = "환경 타입") @RequestParam EnvironmentVariable.EnvironmentType environment) {

        List<EnvironmentChangeHistoryDto.Response> pendingChanges = historyService.getPendingChanges(environment);
        return ResponseEntity.ok(ApiResponse.success(pendingChanges));
    }

    @PostMapping("/{historyId}/approve")
    @Operation(summary = "변경 사항 승인/거절", description = "환경변수 변경 사항을 승인하거나 거절합니다")
    @PreAuthorize("hasRole('SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<EnvironmentChangeHistoryDto.Response>> approveChange(
            @Parameter(description = "변경 이력 ID") @PathVariable Long historyId,
            @Valid @RequestBody EnvironmentChangeHistoryDto.ApprovalRequest request) {

        EnvironmentChangeHistoryDto.Response result = historyService.approveChange(historyId, request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @PostMapping("/rollback")
    @Operation(summary = "환경변수 롤백", description = "환경변수를 이전 상태로 롤백합니다")
    @PreAuthorize("hasRole('SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<EnvironmentChangeHistoryDto.Response>> rollbackToHistory(
            @Valid @RequestBody EnvironmentChangeHistoryDto.RollbackRequest request) {

        EnvironmentChangeHistoryDto.Response result = historyService.rollbackToHistory(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}