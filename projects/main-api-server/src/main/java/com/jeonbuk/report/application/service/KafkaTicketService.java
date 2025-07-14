package com.jeonbuk.report.application.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jeonbuk.report.domain.entity.Report;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;
import org.springframework.util.concurrent.FailureCallback;
import org.springframework.util.concurrent.SuccessCallback;

import java.util.concurrent.CompletableFuture;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
public class KafkaTicketService {
    
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    public KafkaTicketService(@Autowired(required = false) KafkaTemplate<String, String> kafkaTemplate, 
                             ObjectMapper objectMapper) {
        this.kafkaTemplate = kafkaTemplate;
        this.objectMapper = objectMapper;
    }
    
    @Value("${kafka.topics.workspace-tickets:workspace-tickets}")
    private String workspaceTicketsTopic;
    
    @Value("${kafka.topics.priority-alerts:priority-alerts}")
    private String priorityAlertsTopic;
    
    /**
     * 작업공간으로 신고서 티켓 전송
     */
    public void sendToWorkspace(Report report, String workspace) {
        if (kafkaTemplate == null) {
            log.warn("KafkaTemplate is not available. Skipping workspace ticket for report {}", report.getId());
            return;
        }
        
        log.info("Sending report {} to workspace: {}", report.getId(), workspace);
        
        try {
            // 워크스페이스 티켓 메시지 생성
            Map<String, Object> workspaceTicket = createWorkspaceTicketMessage(report, workspace);
            String messageJson = objectMapper.writeValueAsString(workspaceTicket);
            
            // Kafka로 메시지 전송
            CompletableFuture<SendResult<String, String>> future = kafkaTemplate.send(workspaceTicketsTopic, report.getId().toString(), messageJson);
            future.whenComplete((result, throwable) -> {
                if (throwable == null) {
                    log.info("Successfully sent workspace ticket for report {} to topic {} with offset: {}", 
                        report.getId(), workspaceTicketsTopic, result.getRecordMetadata().offset());
                } else {
                    log.error("Failed to send workspace ticket for report {} to topic {}: {}", 
                        report.getId(), workspaceTicketsTopic, throwable.getMessage(), throwable);
                }
            });
                
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize workspace ticket message for report {}: {}", 
                report.getId(), e.getMessage(), e);
        } catch (Exception e) {
            log.error("Unexpected error while sending workspace ticket for report {}: {}", 
                report.getId(), e.getMessage(), e);
        }
    }
    
    /**
     * 우선순위 알림 전송
     */
    public void sendPriorityAlert(Report report) {
        if (kafkaTemplate == null) {
            log.warn("KafkaTemplate is not available. Skipping priority alert for report {}", report.getId());
            return;
        }
        
        log.info("Sending priority alert for report: {}", report.getId());
        
        try {
            // 우선순위 알림 메시지 생성
            Map<String, Object> priorityAlert = createPriorityAlertMessage(report);
            String messageJson = objectMapper.writeValueAsString(priorityAlert);
            
            // Kafka로 메시지 전송
            CompletableFuture<SendResult<String, String>> future = kafkaTemplate.send(priorityAlertsTopic, report.getId().toString(), messageJson);
            future.whenComplete((result, throwable) -> {
                if (throwable == null) {
                    log.info("Successfully sent priority alert for report {} to topic {} with offset: {}", 
                        report.getId(), priorityAlertsTopic, result.getRecordMetadata().offset());
                } else {
                    log.error("Failed to send priority alert for report {} to topic {}: {}", 
                        report.getId(), priorityAlertsTopic, throwable.getMessage(), throwable);
                }
            });
                
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize priority alert message for report {}: {}", 
                report.getId(), e.getMessage(), e);
        } catch (Exception e) {
            log.error("Unexpected error while sending priority alert for report {}: {}", 
                report.getId(), e.getMessage(), e);
        }
    }
    
    /**
     * 워크스페이스 티켓 메시지 생성
     */
    private Map<String, Object> createWorkspaceTicketMessage(Report report, String workspace) {
        Map<String, Object> message = new HashMap<>();
        message.put("reportId", report.getId().toString());
        message.put("workspace", workspace);
        message.put("title", report.getTitle());
        message.put("description", report.getDescription());
        message.put("priority", report.getPriority().name());
        message.put("category", report.getCategory() != null ? report.getCategory().getName() : "미분류");
        message.put("status", report.getStatus() != null ? report.getStatus().getName() : "신규");
        message.put("submittedBy", report.getUser().getName());
        message.put("submittedAt", report.getCreatedAt().toString());
        message.put("messageType", "WORKSPACE_TICKET");
        message.put("timestamp", LocalDateTime.now().toString());
        
        // 위치 정보 추가 (있는 경우)
        if (report.getLatitude() != null && report.getLongitude() != null) {
            Map<String, Object> location = new HashMap<>();
            location.put("latitude", report.getLatitude());
            location.put("longitude", report.getLongitude());
            location.put("address", report.getAddress());
            message.put("location", location);
        }
        
        // AI 분석 결과 추가 (있는 경우)
        if (report.getAiAnalysisResults() != null) {
            message.put("aiAnalysis", report.getAiAnalysisResults());
            message.put("aiConfidenceScore", report.getAiConfidenceScore());
        }
        
        return message;
    }
    
    /**
     * 우선순위 알림 메시지 생성
     */
    private Map<String, Object> createPriorityAlertMessage(Report report) {
        Map<String, Object> message = new HashMap<>();
        message.put("reportId", report.getId().toString());
        message.put("title", report.getTitle());
        message.put("priority", report.getPriority().name());
        message.put("category", report.getCategory() != null ? report.getCategory().getName() : "미분류");
        message.put("submittedBy", report.getUser().getName());
        message.put("submittedAt", report.getCreatedAt().toString());
        message.put("messageType", "PRIORITY_ALERT");
        message.put("timestamp", LocalDateTime.now().toString());
        message.put("alertLevel", determineAlertLevel(report.getPriority()));
        
        // 긴급도에 따른 추가 정보
        if (report.getPriority() == Report.Priority.URGENT || report.getPriority() == Report.Priority.HIGH) {
            message.put("requiresImmediateAttention", true);
            message.put("escalationRequired", true);
        }
        
        // 위치 정보 (긴급 대응을 위해)
        if (report.getLatitude() != null && report.getLongitude() != null) {
            Map<String, Object> location = new HashMap<>();
            location.put("latitude", report.getLatitude());
            location.put("longitude", report.getLongitude());
            location.put("address", report.getAddress());
            message.put("location", location);
        }
        
        return message;
    }
    
    /**
     * 우선순위에 따른 알림 레벨 결정
     */
    private String determineAlertLevel(Report.Priority priority) {
        return switch (priority) {
            case URGENT -> "CRITICAL";
            case HIGH -> "HIGH";
            case MEDIUM -> "MEDIUM";
            case LOW -> "LOW";
        };
    }
}