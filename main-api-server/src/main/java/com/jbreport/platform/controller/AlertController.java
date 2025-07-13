package com.jbreport.platform.controller;

import com.jbreport.platform.dto.AlertDTO;
import com.jbreport.platform.entity.Alert;
import com.jbreport.platform.service.AlertService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/v1/alerts")
@RequiredArgsConstructor
@Tag(name = "Alert Management", description = "Alert related operations")
public class AlertController {
    
    private final AlertService alertService;
    
    @GetMapping
    @Operation(summary = "Get user alerts", description = "Retrieve alerts for the authenticated user")
    public ResponseEntity<Page<AlertDTO>> getUserAlerts(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String severity,
            @RequestParam(required = false) Boolean isRead,
            Pageable pageable) {
        
        Page<AlertDTO> alerts = alertService.getUserAlerts(
            userDetails.getUsername(), type, severity, isRead, pageable);
        return ResponseEntity.ok(alerts);
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get alert by ID", description = "Retrieve a specific alert")
    public ResponseEntity<AlertDTO> getAlert(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        AlertDTO alert = alertService.getAlert(id, userDetails.getUsername());
        return ResponseEntity.ok(alert);
    }
    
    @PutMapping("/{id}/read")
    @Operation(summary = "Mark alert as read", description = "Mark a specific alert as read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        alertService.markAsRead(id, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }
    
    @PutMapping("/read-all")
    @Operation(summary = "Mark all alerts as read", description = "Mark all user alerts as read")
    public ResponseEntity<Void> markAllAsRead(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        alertService.markAllAsRead(userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete alert", description = "Delete a specific alert")
    public ResponseEntity<Void> deleteAlert(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        alertService.deleteAlert(id, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/unread-count")
    @Operation(summary = "Get unread alert count", description = "Get the count of unread alerts")
    public ResponseEntity<Long> getUnreadCount(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long count = alertService.getUnreadCount(userDetails.getUsername());
        return ResponseEntity.ok(count);
    }
}
