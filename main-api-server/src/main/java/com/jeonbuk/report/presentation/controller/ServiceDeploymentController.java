package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.ServiceDeploymentService;
import com.jeonbuk.report.dto.common.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@RestController
@RequestMapping("/api/v1/admin/deployment")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Service Deployment", description = "서비스 배포 및 재시작 관리 API")
@PreAuthorize("hasRole('ADMIN') or hasRole('SYSTEM_ADMIN')")
public class ServiceDeploymentController {

    private final ServiceDeploymentService deploymentService;

    @PostMapping("/deploy")
    @Operation(summary = "환경변수 변경 배포", description = "환경변수 변경사항을 배포하고 서비스를 재시작합니다")
    @PreAuthorize("hasRole('SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> deployEnvironmentChanges(
            @Parameter(description = "환경 타입") @RequestParam String environment,
            @Parameter(description = "변경된 환경변수") @RequestBody Map<String, String> changedVariables,
            Principal principal) {

        log.info("환경변수 배포 요청 - 환경: {}, 요청자: {}", environment, principal.getName());

        CompletableFuture<ServiceDeploymentService.DeploymentResult> future = 
                deploymentService.deployEnvironmentChanges(environment, changedVariables, principal.getName());

        // 비동기 배포 시작 응답
        return ResponseEntity.ok(ApiResponse.success("배포가 시작되었습니다. 진행 상황은 알림을 통해 확인하세요."));
    }

    @PostMapping("/restart")
    @Operation(summary = "전체 서비스 재시작", description = "모든 서비스를 재시작합니다")
    @PreAuthorize("hasRole('SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> restartAllServices(
            @Parameter(description = "환경 타입") @RequestParam String environment,
            Principal principal) {

        log.info("전체 서비스 재시작 요청 - 환경: {}, 요청자: {}", environment, principal.getName());

        // 전체 서비스 재시작 (환경변수 변경 없이)
        CompletableFuture<ServiceDeploymentService.DeploymentResult> future = 
                deploymentService.deployEnvironmentChanges(environment, Map.of(), principal.getName());

        return ResponseEntity.ok(ApiResponse.success("서비스 재시작이 시작되었습니다."));
    }

    @PostMapping("/restart-services")
    @Operation(summary = "선택된 서비스 재시작", description = "지정된 서비스들만 재시작합니다")
    public ResponseEntity<ApiResponse<String>> restartSelectedServices(
            @Parameter(description = "환경 타입") @RequestParam String environment,
            @Parameter(description = "재시작할 서비스 목록") @RequestBody List<String> serviceNames,
            Principal principal) {

        log.info("선택된 서비스 재시작 요청 - 환경: {}, 서비스: {}, 요청자: {}", 
                environment, serviceNames, principal.getName());

        CompletableFuture<ServiceDeploymentService.DeploymentResult> future = 
                deploymentService.restartSpecificServices(environment, serviceNames, principal.getName());

        return ResponseEntity.ok(ApiResponse.success("선택된 서비스 재시작이 시작되었습니다."));
    }

    @GetMapping("/status")
    @Operation(summary = "서비스 상태 조회", description = "현재 서비스들의 상태를 조회합니다")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getServiceStatus(
            @Parameter(description = "환경 타입") @RequestParam String environment) {

        // 여기서는 간단한 상태 정보를 반환
        // 실제로는 각 서비스의 헬스체크 결과를 수집해야 함
        Map<String, Object> status = Map.of(
            "environment", environment,
            "timestamp", System.currentTimeMillis(),
            "services", Map.of(
                "main-api", "checking",
                "ai-analysis", "checking",
                "postgres", "checking",
                "redis", "checking",
                "kafka", "checking"
            )
        );

        return ResponseEntity.ok(ApiResponse.success(status));
    }

    @GetMapping("/services")
    @Operation(summary = "사용 가능한 서비스 목록", description = "재시작 가능한 서비스 목록을 반환합니다")
    public ResponseEntity<ApiResponse<List<String>>> getAvailableServices() {
        List<String> services = List.of(
            "main-api",
            "ai-analysis", 
            "postgres",
            "redis",
            "kafka"
        );

        return ResponseEntity.ok(ApiResponse.success(services));
    }
}