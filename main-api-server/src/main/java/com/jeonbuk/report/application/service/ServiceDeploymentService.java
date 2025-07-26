package com.jeonbuk.report.application.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class ServiceDeploymentService {

    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    @Value("${app.deployment.script-path:./scripts}")
    private String scriptPath;
    
    @Value("${app.deployment.env-file-path:.}")
    private String envFilePath;
    
    @Value("${app.deployment.backup-path:./backups}")
    private String backupPath;

    public CompletableFuture<DeploymentResult> deployEnvironmentChanges(
            String environment, 
            Map<String, String> changedVariables,
            String requestedBy) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("환경변수 배포 시작 - 환경: {}, 요청자: {}", environment, requestedBy);
                
                // 1. 현재 .env 파일 백업
                String backupFile = createBackup(environment);
                
                // 2. 새로운 .env 파일 생성
                String newEnvFile = generateEnvironmentFile(environment, changedVariables);
                
                // 3. 환경변수 검증
                ValidationResult validation = validateEnvironmentFile(newEnvFile);
                if (!validation.isValid()) {
                    throw new RuntimeException("환경변수 검증 실패: " + String.join(", ", validation.getErrors()));
                }
                
                // 4. 서비스 재시작
                ServiceRestartResult restartResult = restartServices(environment, newEnvFile);
                
                // 5. 헬스체크
                boolean healthCheckPassed = performHealthCheck(environment);
                
                if (!healthCheckPassed) {
                    // 롤백 수행
                    log.warn("헬스체크 실패, 롤백 수행");
                    rollbackEnvironment(backupFile, environment);
                    throw new RuntimeException("배포 후 헬스체크 실패로 롤백되었습니다");
                }
                
                // 6. 배포 완료 알림
                sendDeploymentNotification(environment, requestedBy, true, null);
                
                return DeploymentResult.builder()
                        .success(true)
                        .environment(environment)
                        .backupFile(backupFile)
                        .deployedAt(LocalDateTime.now())
                        .requestedBy(requestedBy)
                        .restartResult(restartResult)
                        .healthCheckPassed(healthCheckPassed)
                        .build();
                        
            } catch (Exception e) {
                log.error("환경변수 배포 실패", e);
                sendDeploymentNotification(environment, requestedBy, false, e.getMessage());
                
                return DeploymentResult.builder()
                        .success(false)
                        .environment(environment)
                        .error(e.getMessage())
                        .deployedAt(LocalDateTime.now())
                        .requestedBy(requestedBy)
                        .build();
            }
        });
    }

    public CompletableFuture<DeploymentResult> restartSpecificServices(
            String environment, 
            List<String> serviceNames,
            String requestedBy) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("특정 서비스 재시작 - 환경: {}, 서비스: {}, 요청자: {}", 
                        environment, serviceNames, requestedBy);
                
                ServiceRestartResult restartResult = restartSelectedServices(environment, serviceNames);
                
                // 헬스체크
                boolean healthCheckPassed = performHealthCheck(environment);
                
                return DeploymentResult.builder()
                        .success(healthCheckPassed)
                        .environment(environment)
                        .deployedAt(LocalDateTime.now())
                        .requestedBy(requestedBy)
                        .restartResult(restartResult)
                        .healthCheckPassed(healthCheckPassed)
                        .build();
                        
            } catch (Exception e) {
                log.error("서비스 재시작 실패", e);
                return DeploymentResult.builder()
                        .success(false)
                        .environment(environment)
                        .error(e.getMessage())
                        .deployedAt(LocalDateTime.now())
                        .requestedBy(requestedBy)
                        .build();
            }
        });
    }

    private String createBackup(String environment) throws IOException {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String backupFileName = String.format("env_%s_backup_%s", environment, timestamp);
        Path backupPath = Paths.get(this.backupPath, backupFileName);
        
        // 백업 디렉토리 생성
        Files.createDirectories(backupPath.getParent());
        
        // 현재 .env 파일 복사
        Path currentEnvFile = Paths.get(envFilePath, ".env");
        if (Files.exists(currentEnvFile)) {
            Files.copy(currentEnvFile, backupPath);
        }
        
        return backupPath.toString();
    }

    private String generateEnvironmentFile(String environment, Map<String, String> changedVariables) throws IOException {
        // 환경별 템플릿 파일에서 시작
        Path templateFile = Paths.get(envFilePath, ".env." + environment);
        String newEnvFile = Paths.get(envFilePath, ".env").toString();
        
        if (Files.exists(templateFile)) {
            // 템플릿 파일을 .env로 복사
            Files.copy(templateFile, Paths.get(newEnvFile));
        }
        
        // 변경된 변수들을 적용
        List<String> lines = Files.readAllLines(Paths.get(newEnvFile));
        StringBuilder newContent = new StringBuilder();
        
        for (String line : lines) {
            boolean replaced = false;
            for (Map.Entry<String, String> entry : changedVariables.entrySet()) {
                if (line.startsWith(entry.getKey() + "=")) {
                    newContent.append(entry.getKey()).append("=").append(entry.getValue()).append("\n");
                    replaced = true;
                    break;
                }
            }
            if (!replaced) {
                newContent.append(line).append("\n");
            }
        }
        
        // 새로운 변수들 추가
        for (Map.Entry<String, String> entry : changedVariables.entrySet()) {
            if (lines.stream().noneMatch(line -> line.startsWith(entry.getKey() + "="))) {
                newContent.append(entry.getKey()).append("=").append(entry.getValue()).append("\n");
            }
        }
        
        Files.write(Paths.get(newEnvFile), newContent.toString().getBytes(), StandardOpenOption.TRUNCATE_EXISTING);
        
        return newEnvFile;
    }

    private ValidationResult validateEnvironmentFile(String envFile) {
        try {
            ProcessBuilder processBuilder = new ProcessBuilder(
                    "bash", Paths.get(scriptPath, "validate-env.sh").toString(), envFile
            );
            Process process = processBuilder.start();
            
            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
            }
            
            int exitCode = process.waitFor();
            return new ValidationResult(exitCode == 0, output.toString());
            
        } catch (Exception e) {
            log.error("환경변수 검증 실패", e);
            return new ValidationResult(false, "검증 스크립트 실행 실패: " + e.getMessage());
        }
    }

    private ServiceRestartResult restartServices(String environment, String envFile) {
        try {
            // 환경변수 파일 설정
            Map<String, String> env = new HashMap<>();
            env.put("ENVIRONMENT", environment);
            env.put("ENV_FILE", envFile);
            
            ProcessBuilder processBuilder = new ProcessBuilder(
                    "bash", Paths.get(scriptPath, "restart-services.sh").toString()
            );
            processBuilder.environment().putAll(env);
            
            Process process = processBuilder.start();
            
            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
            }
            
            boolean success = process.waitFor(300, TimeUnit.SECONDS) && process.exitValue() == 0;
            
            return ServiceRestartResult.builder()
                    .success(success)
                    .output(output.toString())
                    .restartedAt(LocalDateTime.now())
                    .build();
                    
        } catch (Exception e) {
            log.error("서비스 재시작 실패", e);
            return ServiceRestartResult.builder()
                    .success(false)
                    .output("재시작 실패: " + e.getMessage())
                    .restartedAt(LocalDateTime.now())
                    .build();
        }
    }

    private ServiceRestartResult restartSelectedServices(String environment, List<String> serviceNames) {
        try {
            Map<String, String> env = new HashMap<>();
            env.put("ENVIRONMENT", environment);
            env.put("SERVICES", String.join(",", serviceNames));
            
            ProcessBuilder processBuilder = new ProcessBuilder(
                    "bash", Paths.get(scriptPath, "restart-selected-services.sh").toString()
            );
            processBuilder.environment().putAll(env);
            
            Process process = processBuilder.start();
            
            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
            }
            
            boolean success = process.waitFor(180, TimeUnit.SECONDS) && process.exitValue() == 0;
            
            return ServiceRestartResult.builder()
                    .success(success)
                    .output(output.toString())
                    .restartedAt(LocalDateTime.now())
                    .restartedServices(serviceNames)
                    .build();
                    
        } catch (Exception e) {
            log.error("선택된 서비스 재시작 실패", e);
            return ServiceRestartResult.builder()
                    .success(false)
                    .output("재시작 실패: " + e.getMessage())
                    .restartedAt(LocalDateTime.now())
                    .restartedServices(serviceNames)
                    .build();
        }
    }

    private boolean performHealthCheck(String environment) {
        try {
            ProcessBuilder processBuilder = new ProcessBuilder(
                    "bash", Paths.get(scriptPath, "health-check.sh").toString(), environment
            );
            Process process = processBuilder.start();
            
            return process.waitFor(60, TimeUnit.SECONDS) && process.exitValue() == 0;
            
        } catch (Exception e) {
            log.error("헬스체크 실패", e);
            return false;
        }
    }

    private void rollbackEnvironment(String backupFile, String environment) {
        try {
            // 백업 파일을 .env로 복구
            Files.copy(Paths.get(backupFile), Paths.get(envFilePath, ".env"));
            
            // 서비스 재시작
            restartServices(environment, Paths.get(envFilePath, ".env").toString());
            
        } catch (Exception e) {
            log.error("롤백 실패", e);
        }
    }

    private void sendDeploymentNotification(String environment, String requestedBy, boolean success, String error) {
        try {
            Map<String, Object> notification = new HashMap<>();
            notification.put("type", "deployment");
            notification.put("environment", environment);
            notification.put("requestedBy", requestedBy);
            notification.put("success", success);
            notification.put("timestamp", LocalDateTime.now());
            if (error != null) {
                notification.put("error", error);
            }
            
            kafkaTemplate.send("deployment_notifications", notification);
            
        } catch (Exception e) {
            log.error("배포 알림 전송 실패", e);
        }
    }

    // Inner classes for results
    public static class ValidationResult {
        private final boolean valid;
        private final String output;
        
        public ValidationResult(boolean valid, String output) {
            this.valid = valid;
            this.output = output;
        }
        
        public boolean isValid() { return valid; }
        public List<String> getErrors() { 
            return output.lines()
                    .filter(line -> line.contains("ERROR") || line.contains("FAIL"))
                    .toList();
        }
    }

    @lombok.Data
    @lombok.Builder
    public static class DeploymentResult {
        private boolean success;
        private String environment;
        private String backupFile;
        private LocalDateTime deployedAt;
        private String requestedBy;
        private ServiceRestartResult restartResult;
        private boolean healthCheckPassed;
        private String error;
    }

    @lombok.Data
    @lombok.Builder
    public static class ServiceRestartResult {
        private boolean success;
        private String output;
        private LocalDateTime restartedAt;
        private List<String> restartedServices;
    }
}