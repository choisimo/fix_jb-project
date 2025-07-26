package com.jeonbuk.report.domain.environment;

import com.jeonbuk.report.domain.common.BaseEntity;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "environment_change_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EnvironmentChangeHistory extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String keyName;

    @Column(columnDefinition = "TEXT")
    private String oldValue;

    @Column(columnDefinition = "TEXT")
    private String newValue;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EnvironmentVariable.EnvironmentType environment;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ChangeType changeType;

    @Column(nullable = false)
    private String modifiedBy;

    @Column(nullable = false)
    private LocalDateTime modifiedAt;

    @Column
    private String reason;

    @Column
    private String approvedBy;

    @Column
    private LocalDateTime approvedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ChangeStatus status;

    @Column
    private Boolean isRolledBack = false;

    @Column
    private Long rolledBackToHistoryId;

    public enum ChangeType {
        CREATE("생성"),
        UPDATE("수정"),
        DELETE("삭제"),
        ROLLBACK("롤백");

        private final String description;

        ChangeType(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    public enum ChangeStatus {
        PENDING("승인 대기"),
        APPROVED("승인됨"),
        REJECTED("거절됨"),
        APPLIED("적용됨"),
        FAILED("적용 실패");

        private final String description;

        ChangeStatus(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }
}