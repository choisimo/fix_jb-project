package com.jeonbuk.report.presentation.dto.alert;

import com.jeonbuk.report.domain.entity.Alert.AlertSeverity;
import com.jeonbuk.report.domain.entity.Alert.AlertType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Alert 응답 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AlertResponse {
    
    private String id;
    
    private String userId;
    
    private String reportId;
    
    private AlertType type;
    
    private String title;
    
    private String content;
    
    private AlertSeverity severity;
    
    private Boolean isRead;
    
    private Boolean isResolved;
    
    private LocalDateTime readAt;
    
    private LocalDateTime resolvedAt;
    
    private String resolvedByUserId;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    private LocalDateTime expiresAt;
    
    private Boolean isExpired;
    
    private Boolean isActive;
}