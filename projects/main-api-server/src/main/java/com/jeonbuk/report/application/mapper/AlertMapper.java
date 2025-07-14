package com.jeonbuk.report.application.mapper;

import com.jeonbuk.report.domain.entity.Alert;
import com.jeonbuk.report.presentation.dto.alert.AlertResponse;
import org.springframework.stereotype.Component;

/**
 * Alert Entity와 DTO 간 변환을 담당하는 매퍼
 */
@Component
public class AlertMapper {
    
    /**
     * Alert Entity를 AlertResponse DTO로 변환
     */
    public AlertResponse toResponse(Alert alert) {
        if (alert == null) {
            return null;
        }
        
        return AlertResponse.builder()
                .id(alert.getId())
                .userId(alert.getUser() != null ? alert.getUser().getId().toString() : null)
                .reportId(alert.getReport() != null ? alert.getReport().getId().toString() : null)
                .type(alert.getType())
                .title(alert.getTitle())
                .content(alert.getContent())
                .severity(alert.getSeverity())
                .isRead(alert.getIsRead())
                .isResolved(alert.getIsResolved())
                .readAt(alert.getReadAt())
                .resolvedAt(alert.getResolvedAt())
                .resolvedByUserId(alert.getResolvedByUser() != null ? alert.getResolvedByUser().getId().toString() : null)
                .createdAt(alert.getCreatedAt())
                .updatedAt(alert.getUpdatedAt())
                .expiresAt(alert.getExpiresAt())
                .isExpired(alert.isExpired())
                .isActive(alert.isActive())
                .build();
    }
}