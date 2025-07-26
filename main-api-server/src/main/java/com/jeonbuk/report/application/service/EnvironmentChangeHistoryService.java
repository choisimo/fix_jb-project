package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.environment.EnvironmentChangeHistory;
import com.jeonbuk.report.domain.environment.EnvironmentVariable;
import com.jeonbuk.report.domain.environment.repository.EnvironmentChangeHistoryRepository;
import com.jeonbuk.report.domain.environment.repository.EnvironmentVariableRepository;
import com.jeonbuk.report.dto.environment.EnvironmentChangeHistoryDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class EnvironmentChangeHistoryService {

    private final EnvironmentChangeHistoryRepository historyRepository;
    private final EnvironmentVariableRepository variableRepository;
    private final EncryptionService encryptionService;

    public Page<EnvironmentChangeHistoryDto.Response> getChangeHistory(
            EnvironmentVariable.EnvironmentType environment,
            EnvironmentChangeHistory.ChangeType changeType,
            EnvironmentChangeHistory.ChangeStatus status,
            String modifiedBy,
            String keyName,
            Pageable pageable) {

        return historyRepository.findByFilters(environment, changeType, status, modifiedBy, keyName, pageable)
                .map(history -> {
                    // 보안 변수인지 확인
                    boolean isSecret = variableRepository.findByKeyNameAndEnvironment(history.getKeyName(), history.getEnvironment())
                            .map(EnvironmentVariable::getIsSecret)
                            .orElse(false);
                    return EnvironmentChangeHistoryDto.Response.from(history, isSecret);
                });
    }

    public List<EnvironmentChangeHistoryDto.Response> getVariableHistory(String keyName) {
        List<EnvironmentChangeHistory> histories = historyRepository.findByKeyNameOrderByModifiedAtDesc(keyName);
        
        // 보안 변수인지 확인
        boolean isSecret = variableRepository.findByKeyNameAndEnvironment(keyName, EnvironmentVariable.EnvironmentType.ALL)
                .map(EnvironmentVariable::getIsSecret)
                .orElse(false);

        return histories.stream()
                .map(history -> EnvironmentChangeHistoryDto.Response.from(history, isSecret))
                .collect(Collectors.toList());
    }

    public EnvironmentChangeHistoryDto.Response approveChange(Long historyId, EnvironmentChangeHistoryDto.ApprovalRequest request) {
        EnvironmentChangeHistory history = historyRepository.findById(historyId)
                .orElseThrow(() -> new RuntimeException("변경 이력을 찾을 수 없습니다: " + historyId));

        if (history.getStatus() != EnvironmentChangeHistory.ChangeStatus.PENDING) {
            throw new RuntimeException("승인 대기 중인 변경 사항이 아닙니다");
        }

        if (request.getApproved()) {
            history.setStatus(EnvironmentChangeHistory.ChangeStatus.APPROVED);
            history.setApprovedBy(request.getApprovedBy());
            history.setApprovedAt(LocalDateTime.now());
            
            // 실제 환경변수 적용
            applyChange(history);
            history.setStatus(EnvironmentChangeHistory.ChangeStatus.APPLIED);
        } else {
            history.setStatus(EnvironmentChangeHistory.ChangeStatus.REJECTED);
            history.setApprovedBy(request.getApprovedBy());
            history.setApprovedAt(LocalDateTime.now());
        }

        EnvironmentChangeHistory saved = historyRepository.save(history);
        
        boolean isSecret = variableRepository.findByKeyNameAndEnvironment(saved.getKeyName(), saved.getEnvironment())
                .map(EnvironmentVariable::getIsSecret)
                .orElse(false);
        
        return EnvironmentChangeHistoryDto.Response.from(saved, isSecret);
    }

    public EnvironmentChangeHistoryDto.Response rollbackToHistory(EnvironmentChangeHistoryDto.RollbackRequest request) {
        EnvironmentChangeHistory targetHistory = historyRepository.findById(request.getHistoryId())
                .orElseThrow(() -> new RuntimeException("롤백 대상 이력을 찾을 수 없습니다: " + request.getHistoryId()));

        // 현재 환경변수 조회
        EnvironmentVariable currentVariable = variableRepository
                .findByKeyNameAndEnvironment(targetHistory.getKeyName(), targetHistory.getEnvironment())
                .orElseThrow(() -> new RuntimeException("환경변수를 찾을 수 없습니다: " + targetHistory.getKeyName()));

        String currentValue = currentVariable.getValue();
        String rollbackValue = targetHistory.getNewValue();

        // 롤백 실행
        currentVariable.setValue(rollbackValue);
        currentVariable.setLastModifiedBy(request.getRequestedBy());
        currentVariable.setLastModifiedAt(LocalDateTime.now());
        variableRepository.save(currentVariable);

        // 롤백 이력 생성
        EnvironmentChangeHistory rollbackHistory = new EnvironmentChangeHistory();
        rollbackHistory.setKeyName(targetHistory.getKeyName());
        rollbackHistory.setOldValue(currentValue);
        rollbackHistory.setNewValue(rollbackValue);
        rollbackHistory.setEnvironment(targetHistory.getEnvironment());
        rollbackHistory.setChangeType(EnvironmentChangeHistory.ChangeType.ROLLBACK);
        rollbackHistory.setModifiedBy(request.getRequestedBy());
        rollbackHistory.setModifiedAt(LocalDateTime.now());
        rollbackHistory.setReason(request.getReason());
        rollbackHistory.setStatus(EnvironmentChangeHistory.ChangeStatus.APPLIED);
        rollbackHistory.setRolledBackToHistoryId(request.getHistoryId());

        EnvironmentChangeHistory saved = historyRepository.save(rollbackHistory);

        // 원본 이력에 롤백 표시
        targetHistory.setIsRolledBack(true);
        historyRepository.save(targetHistory);

        boolean isSecret = currentVariable.getIsSecret();
        return EnvironmentChangeHistoryDto.Response.from(saved, isSecret);
    }

    public List<EnvironmentChangeHistoryDto.Response> getPendingChanges(EnvironmentVariable.EnvironmentType environment) {
        List<EnvironmentChangeHistory> histories = historyRepository
                .findByStatusAndEnvironment(EnvironmentChangeHistory.ChangeStatus.PENDING, environment);

        return histories.stream()
                .map(history -> {
                    boolean isSecret = variableRepository.findByKeyNameAndEnvironment(history.getKeyName(), history.getEnvironment())
                            .map(EnvironmentVariable::getIsSecret)
                            .orElse(false);
                    return EnvironmentChangeHistoryDto.Response.from(history, isSecret);
                })
                .collect(Collectors.toList());
    }

    private void applyChange(EnvironmentChangeHistory history) {
        switch (history.getChangeType()) {
            case CREATE:
                createVariableFromHistory(history);
                break;
            case UPDATE:
                updateVariableFromHistory(history);
                break;
            case DELETE:
                deleteVariableFromHistory(history);
                break;
            default:
                throw new RuntimeException("지원하지 않는 변경 타입입니다: " + history.getChangeType());
        }
    }

    private void createVariableFromHistory(EnvironmentChangeHistory history) {
        EnvironmentVariable variable = new EnvironmentVariable();
        variable.setKeyName(history.getKeyName());
        variable.setValue(history.getNewValue());
        variable.setEnvironment(history.getEnvironment());
        variable.setLastModifiedBy(history.getModifiedBy());
        variable.setLastModifiedAt(history.getModifiedAt());
        
        variableRepository.save(variable);
    }

    private void updateVariableFromHistory(EnvironmentChangeHistory history) {
        EnvironmentVariable variable = variableRepository
                .findByKeyNameAndEnvironment(history.getKeyName(), history.getEnvironment())
                .orElseThrow(() -> new RuntimeException("환경변수를 찾을 수 없습니다: " + history.getKeyName()));

        variable.setValue(history.getNewValue());
        variable.setLastModifiedBy(history.getModifiedBy());
        variable.setLastModifiedAt(history.getModifiedAt());
        
        variableRepository.save(variable);
    }

    private void deleteVariableFromHistory(EnvironmentChangeHistory history) {
        EnvironmentVariable variable = variableRepository
                .findByKeyNameAndEnvironment(history.getKeyName(), history.getEnvironment())
                .orElseThrow(() -> new RuntimeException("환경변수를 찾을 수 없습니다: " + history.getKeyName()));

        variableRepository.delete(variable);
    }
}