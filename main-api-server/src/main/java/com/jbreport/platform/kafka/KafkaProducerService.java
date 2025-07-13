package com.jbreport.platform.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;
import org.springframework.util.concurrent.ListenableFutureCallback;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class KafkaProducerService {
    
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;
    
    private static final String REPORT_TOPIC = "report-events";
    private static final String AI_ANALYSIS_TOPIC = "ai-analysis-events";
    private static final String ALERT_TOPIC = "alert-events";
    
    public void sendReportEvent(String eventType, Long reportId, Map<String, Object> data) {
        try {
            Map<String, Object> event = createEvent(eventType, reportId, data);
            String message = objectMapper.writeValueAsString(event);
            
            kafkaTemplate.send(REPORT_TOPIC, String.valueOf(reportId), message)
                .whenComplete((result, ex) -> {
                    if (ex != null) {
                        log.error("Failed to send report event: {} - {}", eventType, reportId, ex);
                    } else {
                        log.debug("Report event sent successfully: {} - {}", eventType, reportId);
                    }
                });
                
        } catch (Exception e) {
            log.error("Error sending report event", e);
        }
    }
    
    public void sendAiAnalysisRequest(Long reportId, String analysisType, Map<String, Object> data) {
        try {
            Map<String, Object> request = new HashMap<>();
            request.put("reportId", reportId);
            request.put("analysisType", analysisType);
            request.put("requestId", UUID.randomUUID().toString());
            request.put("timestamp", LocalDateTime.now().toString());
            request.putAll(data);
            
            String message = objectMapper.writeValueAsString(request);
            
            kafkaTemplate.send(AI_ANALYSIS_TOPIC, String.valueOf(reportId), message)
                .whenComplete((result, ex) -> {
                    if (ex != null) {
                        log.error("Failed to send AI analysis request", ex);
                    } else {
                        log.info("AI analysis request sent: {} for report {}", analysisType, reportId);
                    }
                });
                
        } catch (Exception e) {
            log.error("Error sending AI analysis request", e);
        }
    }
    
    public void sendAiAnalysisResult(String eventType, Long reportId, Map<String, Object> result) {
        try {
            Map<String, Object> event = createEvent(eventType, reportId, result);
            String message = objectMapper.writeValueAsString(event);
            
            kafkaTemplate.send(AI_ANALYSIS_TOPIC, String.valueOf(reportId), message);
            log.info("AI analysis result sent for report {}", reportId);
            
        } catch (Exception e) {
            log.error("Error sending AI analysis result", e);
        }
    }
    
    public void sendAlertEvent(String eventType, Long alertId, Map<String, Object> data) {
        try {
            Map<String, Object> event = createEvent(eventType, alertId, data);
            String message = objectMapper.writeValueAsString(event);
            
            kafkaTemplate.send(ALERT_TOPIC, String.valueOf(alertId), message);
            log.debug("Alert event sent: {} - {}", eventType, alertId);
            
        } catch (Exception e) {
            log.error("Error sending alert event", e);
        }
    }
    
    private Map<String, Object> createEvent(String eventType, Long entityId, Map<String, Object> data) {
        Map<String, Object> event = new HashMap<>();
        event.put("eventType", eventType);
        event.put("entityId", entityId);
        event.put("timestamp", LocalDateTime.now().toString());
        event.put("eventId", UUID.randomUUID().toString());
        event.put("data", data);
        return event;
    }
}
