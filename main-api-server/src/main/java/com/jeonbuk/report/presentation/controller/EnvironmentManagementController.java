package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.EnvironmentVariableService;
import com.jeonbuk.report.domain.environment.EnvironmentVariable;
import com.jeonbuk.report.dto.common.ApiResponse;
import com.jeonbuk.report.dto.environment.EnvironmentVariableDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/environment")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Environment Management", description = "환경변수 관리 API")
@PreAuthorize("hasRole('ADMIN') or hasRole('SYSTEM_ADMIN')")
public class EnvironmentManagementController {

    private final EnvironmentVariableService environmentVariableService;

    @GetMapping("/variables")
    @Operation(summary = "환경변수 목록 조회", description = "필터링 조건에 따라 환경변수 목록을 조회합니다")
    public ResponseEntity<ApiResponse<Page<EnvironmentVariableDto.Response>>> getVariables(
            @Parameter(description = "환경 타입") @RequestParam(required = false) EnvironmentVariable.EnvironmentType environment,
            @Parameter(description = "카테고리") @RequestParam(required = false) EnvironmentVariable.VariableCategory category,
            @Parameter(description = "보안 변수 여부") @RequestParam(required = false) Boolean isSecret,
            @Parameter(description = "키 이름 검색") @RequestParam(required = false) String keyName,
            Pageable pageable) {

        Page<EnvironmentVariableDto.Response> variables = environmentVariableService
                .getVariablesWithFilters(environment, category, isSecret, keyName, pageable);

        return ResponseEntity.ok(ApiResponse.success(variables));
    }

    @GetMapping("/variables/all")
    @Operation(summary = "전체 환경변수 조회", description = "특정 환경의 모든 환경변수를 조회합니다")
    public ResponseEntity<ApiResponse<List<EnvironmentVariableDto.Response>>> getAllVariables(
            @Parameter(description = "환경 타입") @RequestParam(required = false) EnvironmentVariable.EnvironmentType environment) {

        List<EnvironmentVariableDto.Response> variables = environmentVariableService.getAllVariables(environment);
        return ResponseEntity.ok(ApiResponse.success(variables));
    }

    @GetMapping("/variables/{id}")
    @Operation(summary = "환경변수 상세 조회", description = "특정 환경변수의 상세 정보를 조회합니다")
    public ResponseEntity<ApiResponse<EnvironmentVariableDto.Response>> getVariable(
            @Parameter(description = "환경변수 ID") @PathVariable Long id) {

        EnvironmentVariableDto.Response variable = environmentVariableService.getVariable(id);
        return ResponseEntity.ok(ApiResponse.success(variable));
    }

    @PostMapping("/variables")
    @Operation(summary = "환경변수 생성", description = "새로운 환경변수를 생성합니다")
    public ResponseEntity<ApiResponse<EnvironmentVariableDto.Response>> createVariable(
            @Valid @RequestBody EnvironmentVariableDto.Request request,
            Principal principal) {

        EnvironmentVariableDto.Response variable = environmentVariableService
                .createVariable(request, principal.getName());
        
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(variable));
    }

    @PutMapping("/variables/{id}")
    @Operation(summary = "환경변수 수정", description = "기존 환경변수를 수정합니다")
    public ResponseEntity<ApiResponse<EnvironmentVariableDto.Response>> updateVariable(
            @Parameter(description = "환경변수 ID") @PathVariable Long id,
            @Valid @RequestBody EnvironmentVariableDto.UpdateRequest request,
            Principal principal) {

        EnvironmentVariableDto.Response variable = environmentVariableService
                .updateVariable(id, request, principal.getName());
        
        return ResponseEntity.ok(ApiResponse.success(variable));
    }

    @DeleteMapping("/variables/{id}")
    @Operation(summary = "환경변수 삭제", description = "환경변수를 삭제합니다")
    public ResponseEntity<ApiResponse<Void>> deleteVariable(
            @Parameter(description = "환경변수 ID") @PathVariable Long id,
            @Parameter(description = "삭제 사유") @RequestParam String reason,
            Principal principal) {

        environmentVariableService.deleteVariable(id, principal.getName(), reason);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/variables/bulk-update")
    @Operation(summary = "환경변수 대량 수정", description = "여러 환경변수를 한번에 수정합니다")
    public ResponseEntity<ApiResponse<Void>> bulkUpdateVariables(
            @Valid @RequestBody EnvironmentVariableDto.BulkUpdateRequest request,
            Principal principal) {

        environmentVariableService.bulkUpdateVariables(request, principal.getName());
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/validate")
    @Operation(summary = "환경변수 검증", description = "특정 환경의 환경변수 설정을 검증합니다")
    public ResponseEntity<ApiResponse<EnvironmentVariableDto.ValidationResult>> validateEnvironment(
            @Parameter(description = "환경 타입") @RequestParam EnvironmentVariable.EnvironmentType environment) {

        EnvironmentVariableDto.ValidationResult result = environmentVariableService.validateEnvironment(environment);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @PostMapping("/export")
    @Operation(summary = "환경변수 파일 내보내기", description = "환경변수를 .env 파일 형태로 내보냅니다")
    public ResponseEntity<byte[]> exportEnvironmentFile(
            @Valid @RequestBody EnvironmentVariableDto.ExportRequest request) {

        try {
            String filePath = environmentVariableService.exportEnvironmentFile(request);
            byte[] fileContent = Files.readAllBytes(Paths.get(filePath));
            
            String filename = String.format("env_%s_%s.env", 
                    request.getEnvironment().getValue(),
                    System.currentTimeMillis());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            headers.setContentDispositionFormData("attachment", filename);

            // 파일 삭제 (임시 파일)
            Files.deleteIfExists(Paths.get(filePath));

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(fileContent);

        } catch (IOException e) {
            log.error("환경변수 파일 내보내기 실패", e);
            throw new RuntimeException("파일 내보내기에 실패했습니다", e);
        }
    }

    @GetMapping("/categories")
    @Operation(summary = "환경변수 카테고리 목록", description = "사용 가능한 환경변수 카테고리 목록을 반환합니다")
    public ResponseEntity<ApiResponse<EnvironmentVariable.VariableCategory[]>> getCategories() {
        return ResponseEntity.ok(ApiResponse.success(EnvironmentVariable.VariableCategory.values()));
    }

    @GetMapping("/environments")
    @Operation(summary = "환경 타입 목록", description = "사용 가능한 환경 타입 목록을 반환합니다")
    public ResponseEntity<ApiResponse<EnvironmentVariable.EnvironmentType[]>> getEnvironmentTypes() {
        return ResponseEntity.ok(ApiResponse.success(EnvironmentVariable.EnvironmentType.values()));
    }
}