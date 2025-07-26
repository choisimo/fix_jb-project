package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.environment.EnvironmentChangeHistory;
import com.jeonbuk.report.domain.environment.EnvironmentVariable;
import com.jeonbuk.report.domain.environment.repository.EnvironmentChangeHistoryRepository;
import com.jeonbuk.report.domain.environment.repository.EnvironmentVariableRepository;
import com.jeonbuk.report.dto.environment.EnvironmentVariableDto;
import com.jeonbuk.report.dto.environment.EnvironmentChangeHistoryDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class EnvironmentVariableService {

    private final EnvironmentVariableRepository environmentVariableRepository;
    private final EnvironmentChangeHistoryRepository changeHistoryRepository;
    private final EncryptionService encryptionService;

    public List<EnvironmentVariableDto.Response> getAllVariables(EnvironmentVariable.EnvironmentType environment) {
        List<EnvironmentVariable> variables;
        if (environment == null) {
            variables = environmentVariableRepository.findAll();
        } else {
            variables = environmentVariableRepository.findByEnvironmentOrEnvironment(
                    environment, EnvironmentVariable.EnvironmentType.ALL
            );
        }
        
        return variables.stream()
                .map(EnvironmentVariableDto.Response::from)
                .collect(Collectors.toList());
    }

    public Page<EnvironmentVariableDto.Response> getVariablesWithFilters(
            EnvironmentVariable.EnvironmentType environment,
            EnvironmentVariable.VariableCategory category,
            Boolean isSecret,
            String keyName,
            Pageable pageable) {
        
        return environmentVariableRepository.findByFilters(environment, category, isSecret, keyName, pageable)
                .map(EnvironmentVariableDto.Response::from);
    }

    public EnvironmentVariableDto.Response getVariable(Long id) {
        EnvironmentVariable variable = environmentVariableRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("환경변수를 찾을 수 없습니다: " + id));
        return EnvironmentVariableDto.Response.from(variable);
    }

    public EnvironmentVariableDto.Response createVariable(EnvironmentVariableDto.Request request, String createdBy) {
        // 중복 확인
        environmentVariableRepository.findByKeyNameAndEnvironment(request.getKeyName(), request.getEnvironment())
                .ifPresent(existing -> {
                    throw new RuntimeException("이미 존재하는 환경변수입니다: " + request.getKeyName());
                });

        // 검증
        validateVariable(request);

        EnvironmentVariable variable = new EnvironmentVariable();
        variable.setKeyName(request.getKeyName());
        variable.setValue(request.getIsSecret() ? encryptionService.encrypt(request.getValue()) : request.getValue());
        variable.setDescription(request.getDescription());
        variable.setEnvironment(request.getEnvironment());
        variable.setCategory(request.getCategory());
        variable.setIsSecret(request.getIsSecret());
        variable.setIsRequired(request.getIsRequired());
        variable.setDefaultValue(request.getDefaultValue());
        variable.setValidationPattern(request.getValidationPattern());
        variable.setLastModifiedBy(createdBy);
        variable.setLastModifiedAt(LocalDateTime.now());

        EnvironmentVariable saved = environmentVariableRepository.save(variable);

        // 변경 이력 기록
        recordChange(saved, null, saved.getValue(), EnvironmentChangeHistory.ChangeType.CREATE, 
                    createdBy, request.getReason());

        return EnvironmentVariableDto.Response.from(saved);
    }

    public EnvironmentVariableDto.Response updateVariable(Long id, EnvironmentVariableDto.UpdateRequest request, String modifiedBy) {
        EnvironmentVariable variable = environmentVariableRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("환경변수를 찾을 수 없습니다: " + id));

        String oldValue = variable.getValue();
        
        if (request.getValue() != null) {
            variable.setValue(variable.getIsSecret() ? encryptionService.encrypt(request.getValue()) : request.getValue());
        }
        if (request.getDescription() != null) {
            variable.setDescription(request.getDescription());
        }
        if (request.getIsSecret() != null) {
            variable.setIsSecret(request.getIsSecret());
        }
        if (request.getIsRequired() != null) {
            variable.setIsRequired(request.getIsRequired());
        }
        if (request.getDefaultValue() != null) {
            variable.setDefaultValue(request.getDefaultValue());
        }
        if (request.getValidationPattern() != null) {
            variable.setValidationPattern(request.getValidationPattern());
        }

        variable.setLastModifiedBy(modifiedBy);
        variable.setLastModifiedAt(LocalDateTime.now());

        EnvironmentVariable saved = environmentVariableRepository.save(variable);

        // 변경 이력 기록
        recordChange(saved, oldValue, saved.getValue(), EnvironmentChangeHistory.ChangeType.UPDATE, 
                    modifiedBy, request.getReason());

        return EnvironmentVariableDto.Response.from(saved);
    }

    public void deleteVariable(Long id, String deletedBy, String reason) {
        EnvironmentVariable variable = environmentVariableRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("환경변수를 찾을 수 없습니다: " + id));

        // 변경 이력 기록
        recordChange(variable, variable.getValue(), null, EnvironmentChangeHistory.ChangeType.DELETE, 
                    deletedBy, reason);

        environmentVariableRepository.delete(variable);
    }

    public void bulkUpdateVariables(EnvironmentVariableDto.BulkUpdateRequest request, String modifiedBy) {
        for (EnvironmentVariableDto.BulkUpdateRequest.VariableUpdate update : request.getVariables()) {
            EnvironmentVariable variable = environmentVariableRepository
                    .findByKeyNameAndEnvironment(update.getKeyName(), request.getEnvironment())
                    .orElseThrow(() -> new RuntimeException("환경변수를 찾을 수 없습니다: " + update.getKeyName()));

            String oldValue = variable.getValue();
            variable.setValue(variable.getIsSecret() ? 
                encryptionService.encrypt(update.getValue()) : update.getValue());
            variable.setLastModifiedBy(modifiedBy);
            variable.setLastModifiedAt(LocalDateTime.now());

            environmentVariableRepository.save(variable);

            // 변경 이력 기록
            recordChange(variable, oldValue, variable.getValue(), EnvironmentChangeHistory.ChangeType.UPDATE, 
                        modifiedBy, request.getReason());
        }
    }

    public EnvironmentVariableDto.ValidationResult validateEnvironment(EnvironmentVariable.EnvironmentType environment) {
        List<EnvironmentVariable> variables = environmentVariableRepository
                .findByEnvironmentOrEnvironment(environment, EnvironmentVariable.EnvironmentType.ALL);

        List<String> errors = variables.stream()
                .filter(var -> var.getValidationPattern() != null && var.getValue() != null)
                .filter(var -> !Pattern.matches(var.getValidationPattern(), 
                    var.getIsSecret() ? encryptionService.decrypt(var.getValue()) : var.getValue()))
                .map(var -> "검증 실패: " + var.getKeyName())
                .collect(Collectors.toList());

        List<String> missingRequired = environmentVariableRepository
                .findMissingRequiredVariables(environment)
                .stream()
                .map(EnvironmentVariable::getKeyName)
                .collect(Collectors.toList());

        return EnvironmentVariableDto.ValidationResult.builder()
                .isValid(errors.isEmpty() && missingRequired.isEmpty())
                .errors(errors)
                .missingRequired(missingRequired)
                .build();
    }

    public String exportEnvironmentFile(EnvironmentVariableDto.ExportRequest request) throws IOException {
        List<EnvironmentVariable> variables = environmentVariableRepository
                .findByEnvironmentOrEnvironment(request.getEnvironment(), EnvironmentVariable.EnvironmentType.ALL);

        if (request.getCategories() != null && !request.getCategories().isEmpty()) {
            variables = variables.stream()
                    .filter(var -> request.getCategories().contains(var.getCategory()))
                    .collect(Collectors.toList());
        }

        StringBuilder content = new StringBuilder();
        content.append("# =============================================================================\n");
        content.append("# JB Report Platform - Environment Variables Export\n");
        content.append("# Environment: ").append(request.getEnvironment()).append("\n");
        content.append("# Generated: ").append(LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)).append("\n");
        content.append("# =============================================================================\n\n");

        Map<EnvironmentVariable.VariableCategory, List<EnvironmentVariable>> grouped = variables.stream()
                .collect(Collectors.groupingBy(EnvironmentVariable::getCategory));

        for (Map.Entry<EnvironmentVariable.VariableCategory, List<EnvironmentVariable>> entry : grouped.entrySet()) {
            content.append("# ").append(entry.getKey().getDescription()).append("\n");
            for (EnvironmentVariable var : entry.getValue()) {
                if (var.getDescription() != null) {
                    content.append("# ").append(var.getDescription()).append("\n");
                }
                
                String value = var.getValue();
                if (var.getIsSecret() && value != null) {
                    if (request.getIncludeSecrets()) {
                        value = encryptionService.decrypt(value);
                    } else {
                        value = "CHANGE_THIS_SECRET_VALUE";
                    }
                }
                
                content.append(var.getKeyName()).append("=").append(value != null ? value : "").append("\n");
            }
            content.append("\n");
        }

        // 파일 저장
        String filename = String.format(".env.%s_%s", 
                request.getEnvironment().getValue(),
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")));
        
        Path filePath = Paths.get(filename);
        Files.write(filePath, content.toString().getBytes(), StandardOpenOption.CREATE);

        return filePath.toAbsolutePath().toString();
    }

    private void validateVariable(EnvironmentVariableDto.Request request) {
        if (request.getValidationPattern() != null && request.getValue() != null) {
            if (!Pattern.matches(request.getValidationPattern(), request.getValue())) {
                throw new RuntimeException("값이 검증 패턴과 일치하지 않습니다: " + request.getKeyName());
            }
        }
    }

    private void recordChange(EnvironmentVariable variable, String oldValue, String newValue, 
                            EnvironmentChangeHistory.ChangeType changeType, String modifiedBy, String reason) {
        EnvironmentChangeHistory history = new EnvironmentChangeHistory();
        history.setKeyName(variable.getKeyName());
        history.setOldValue(oldValue);
        history.setNewValue(newValue);
        history.setEnvironment(variable.getEnvironment());
        history.setChangeType(changeType);
        history.setModifiedBy(modifiedBy);
        history.setModifiedAt(LocalDateTime.now());
        history.setReason(reason);
        history.setStatus(EnvironmentChangeHistory.ChangeStatus.APPLIED);

        changeHistoryRepository.save(history);
    }
}