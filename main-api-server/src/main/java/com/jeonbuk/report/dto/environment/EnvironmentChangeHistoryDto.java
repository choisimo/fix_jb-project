package com.jeonbuk.report.dto.environment;

import com.jeonbuk.report.domain.environment.EnvironmentChangeHistory;
import com.jeonbuk.report.domain.environment.EnvironmentVariable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

public class EnvironmentChangeHistoryDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Response {
        private Long id;
        private String keyName;
        private String oldValue;
        private String newValue;
        private String maskedOldValue;
        private String maskedNewValue;
        private EnvironmentVariable.EnvironmentType environment;
        private EnvironmentChangeHistory.ChangeType changeType;
        private String modifiedBy;
        private LocalDateTime modifiedAt;
        private String reason;
        private String approvedBy;
        private LocalDateTime approvedAt;
        private EnvironmentChangeHistory.ChangeStatus status;
        private Boolean isRolledBack;
        private Long rolledBackToHistoryId;

        public static Response from(EnvironmentChangeHistory entity, boolean isSecret) {
            return Response.builder()
                    .id(entity.getId())
                    .keyName(entity.getKeyName())
                    .oldValue(isSecret ? null : entity.getOldValue())
                    .newValue(isSecret ? null : entity.getNewValue())
                    .maskedOldValue(isSecret ? maskValue(entity.getOldValue()) : entity.getOldValue())
                    .maskedNewValue(isSecret ? maskValue(entity.getNewValue()) : entity.getNewValue())
                    .environment(entity.getEnvironment())
                    .changeType(entity.getChangeType())
                    .modifiedBy(entity.getModifiedBy())
                    .modifiedAt(entity.getModifiedAt())
                    .reason(entity.getReason())
                    .approvedBy(entity.getApprovedBy())
                    .approvedAt(entity.getApprovedAt())
                    .status(entity.getStatus())
                    .isRolledBack(entity.getIsRolledBack())
                    .rolledBackToHistoryId(entity.getRolledBackToHistoryId())
                    .build();
        }

        private static String maskValue(String value) {
            if (value == null || value.length() <= 8) {
                return "****";
            }
            return value.substring(0, 4) + "****" + value.substring(value.length() - 4);
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ApprovalRequest {
        private String approvedBy;
        private String comment;
        private Boolean approved;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RollbackRequest {
        private Long historyId;
        private String reason;
        private String requestedBy;
    }
}