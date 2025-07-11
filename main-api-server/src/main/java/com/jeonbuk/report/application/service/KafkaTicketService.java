package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Report;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class KafkaTicketService {
    
    public void sendToWorkspace(Report report, String workspace) {
        log.info("Sending report {} to workspace: {}", report.getId(), workspace);
        // TODO: Implement Kafka message sending logic
    }
    
    public void sendPriorityAlert(Report report) {
        log.info("Sending priority alert for report: {}", report.getId());
        // TODO: Implement priority alert sending
    }
}