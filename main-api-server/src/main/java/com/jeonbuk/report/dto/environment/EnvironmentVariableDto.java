package com.jeonbuk.report.dto.environment;

import com.jeonbuk.report.domain.environment.EnvironmentVariable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

public class EnvironmentVariableDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Request {
        @NotBlank(message = "키 이름은 필수입니다")
        private String keyName;

        private String value;

        private String description;

        @NotNull(message = "환경 타입은 필수입니다")
        private EnvironmentVariable.EnvironmentType environment;

        @NotNull(message = "카테고리는 필수입니다")
        private EnvironmentVariable.VariableCategory category;

        private Boolean isSecret = false;
        private Boolean isRequired = false;
        private String defaultValue;
        private String validationPattern;
        private String reason; // 변경 사유
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Response {
        private Long id;
        private String keyName;
        private String value;
        private String maskedValue; // 보안 변수의 마스킹된 값
        private String description;
        private EnvironmentVariable.EnvironmentType environment;
        private EnvironmentVariable.VariableCategory category;
        private Boolean isSecret;
        private Boolean isRequired;
        private String defaultValue;
        private String validationPattern;
        private String lastModifiedBy;
        private LocalDateTime lastModifiedAt;
        private Long version;

        public static Response from(EnvironmentVariable entity) {
            return Response.builder()
                    .id(entity.getId())
                    .keyName(entity.getKeyName())
                    .value(entity.getIsSecret() ? null : entity.getValue())
                    .maskedValue(entity.getIsSecret() ? maskValue(entity.getValue()) : entity.getValue())
                    .description(entity.getDescription())
                    .environment(entity.getEnvironment())
                    .category(entity.getCategory())
                    .isSecret(entity.getIsSecret())
                    .isRequired(entity.getIsRequired())
                    .defaultValue(entity.getDefaultValue())
                    .validationPattern(entity.getValidationPattern())
                    .lastModifiedBy(entity.getLastModifiedBy())
                    .lastModifiedAt(entity.getLastModifiedAt())
                    .version(entity.getVersion())
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
    public static class UpdateRequest {
        private String value;
        private String description;
        private Boolean isSecret;
        private Boolean isRequired;
        private String defaultValue;
        private String validationPattern;
        private String reason; // 변경 사유
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BulkUpdateRequest {
        private EnvironmentVariable.EnvironmentType environment;
        private java.util.List<VariableUpdate> variables;
        private String reason;

        @Data
        @Builder
        @NoArgsConstructor
        @AllArgsConstructor
        public static class VariableUpdate {
            private String keyName;
            private String value;
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ValidationResult {
        private Boolean isValid;
        private java.util.List<String> errors;
        private java.util.List<String> warnings;
        private java.util.List<String> missingRequired;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExportRequest {
        private EnvironmentVariable.EnvironmentType environment;
        private java.util.List<EnvironmentVariable.VariableCategory> categories;
        private Boolean includeSecrets = false;
        private String format = "env"; // env, json, yaml
    }
}