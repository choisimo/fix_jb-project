package com.jbreport.platform.service;

import com.jbreport.platform.dto.AlertDTO;
import com.jbreport.platform.entity.Alert;
import com.jbreport.platform.entity.User;
import com.jbreport.platform.exception.ResourceNotFoundException;
import com.jbreport.platform.repository.AlertRepository;
import com.jbreport.platform.repository.UserRepository;
import com.jbreport.platform.websocket.AlertWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.criteria.Predicate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AlertService {
    
    private final AlertRepository alertRepository;
    private final UserRepository userRepository;
    private final AlertWebSocketHandler webSocketHandler;
    
    public Alert createAlert(Alert.AlertType type, Alert.AlertSeverity severity, 
                           String title, String message, Long userId, Long relatedId) {
        Alert alert = new Alert();
        alert.setType(type);
        alert.setSeverity(severity);
        alert.setTitle(title);
        alert.setMessage(message);
        alert.setUserId(userId);
        alert.setRelatedId(relatedId);
        alert.setRead(false);
        alert.setCreatedAt(LocalDateTime.now());
        
        Alert savedAlert = alertRepository.save(alert);
        
        // Send real-time notification via WebSocket
        try {
            webSocketHandler.sendAlertToUser(userId, convertToDTO(savedAlert));
        } catch (Exception e) {
            log.error("Failed to send WebSocket notification for alert {}", savedAlert.getId(), e);
        }
        
        return savedAlert;
    }
    
    public Page<AlertDTO> getUserAlerts(String username, String type, String severity, 
                                       Boolean isRead, Pageable pageable) {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        Specification<Alert> spec = buildSpecification(user.getId(), type, severity, isRead);
        Page<Alert> alerts = alertRepository.findAll(spec, pageable);
        
        return alerts.map(this::convertToDTO);
    }
    
    public AlertDTO getAlert(Long alertId, String username) {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        Alert alert = alertRepository.findByIdAndUserId(alertId, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Alert not found"));
        
        return convertToDTO(alert);
    }
    
    public void markAsRead(Long alertId, String username) {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        Alert alert = alertRepository.findByIdAndUserId(alertId, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Alert not found"));
        
        alert.setIsRead(true);
        alert.setReadAt(LocalDateTime.now());
        alertRepository.save(alert);
    }
    
    public void markAllAsRead(String username) {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        alertRepository.markAllAsReadByUserId(user.getId());
    }
    
    public void deleteAlert(Long alertId, String username) {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        Alert alert = alertRepository.findByIdAndUserId(alertId, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Alert not found"));
        
        alertRepository.delete(alert);
    }
    
    public Long getUnreadCount(String username) {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        return alertRepository.countByUserIdAndIsReadFalse(user.getId());
    }
    
    private Specification<Alert> buildSpecification(Long userId, String type, 
                                                   String severity, Boolean isRead) {
        return (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();
            
            predicates.add(criteriaBuilder.equal(root.get("userId"), userId));
            
            if (type != null) {
                predicates.add(criteriaBuilder.equal(root.get("type"), Alert.AlertType.valueOf(type)));
            }
            
            if (severity != null) {
                predicates.add(criteriaBuilder.equal(root.get("severity"), Alert.AlertSeverity.valueOf(severity)));
            }
            
            if (isRead != null) {
                predicates.add(criteriaBuilder.equal(root.get("isRead"), isRead));
            }
            
            // Only show non-expired alerts
            predicates.add(criteriaBuilder.or(
                criteriaBuilder.isNull(root.get("expiresAt")),
                criteriaBuilder.greaterThan(root.get("expiresAt"), LocalDateTime.now())
            ));
            
            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
    }
    
    private AlertDTO convertToDTO(Alert alert) {
        return AlertDTO.builder()
                .id(alert.getId())
                .type(alert.getType().name())
                .severity(alert.getSeverity().name())
                .title(alert.getTitle())
                .message(alert.getMessage())
                .isRead(alert.getIsRead())
                .createdAt(alert.getCreatedAt())
                .readAt(alert.getReadAt())
                .expiresAt(alert.getExpiresAt())
                .relatedId(alert.getRelatedId())
                .build();
    }
}
