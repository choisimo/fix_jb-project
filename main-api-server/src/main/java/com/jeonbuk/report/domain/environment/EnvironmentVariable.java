package com.jeonbuk.report.domain.environment;

import com.jeonbuk.report.domain.common.BaseEntity;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "environment_variables")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EnvironmentVariable extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String keyName;

    @Column(columnDefinition = "TEXT")
    private String value;

    @Column
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EnvironmentType environment;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VariableCategory category;

    @Column(nullable = false)
    private Boolean isSecret = false;

    @Column(nullable = false)
    private Boolean isRequired = false;

    @Column
    private String defaultValue;

    @Column
    private String validationPattern;

    @Column
    private String lastModifiedBy;

    @Column
    private LocalDateTime lastModifiedAt;

    @Version
    private Long version;

    public enum EnvironmentType {
        DEVELOPMENT("development"),
        STAGING("staging"),
        PRODUCTION("production"),
        ALL("all");

        private final String value;

        EnvironmentType(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }

    public enum VariableCategory {
        DATABASE("Database Configuration"),
        SECURITY("Security & Authentication"),
        AI_SERVICES("AI Services"),
        API("API Configuration"),
        INFRASTRUCTURE("Infrastructure"),
        FEATURE_FLAGS("Feature Flags"),
        LOGGING("Logging & Monitoring"),
        FILE_STORAGE("File Storage"),
        NOTIFICATION("Notification"),
        OAUTH("OAuth Configuration");

        private final String description;

        VariableCategory(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }
}