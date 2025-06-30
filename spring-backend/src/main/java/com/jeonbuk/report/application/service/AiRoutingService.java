package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.infrastructure.external.roboflow.RoboflowApiClient;
import com.jeonbuk.report.infrastructure.external.roboflow.RoboflowDto;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class AiRoutingService {
  private final RoboflowApiClient roboflowApiClient;
  private final PriorityEscalationService priorityEscalationService;
  private final GisService gisService;
  private final KafkaTicketService kafkaTicketService;

  public AiRoutingService(RoboflowApiClient roboflowApiClient,
      PriorityEscalationService priorityEscalationService,
      GisService gisService,
      KafkaTicketService kafkaTicketService) {
    this.roboflowApiClient = roboflowApiClient;
    this.priorityEscalationService = priorityEscalationService;
    this.gisService = gisService;
    this.kafkaTicketService = kafkaTicketService;
  }

  public void processReport(Report report, MultipartFile image) {
    // Step 1: Initial analysis with Qwen2.5 VL model
    RoboflowDto.AnalysisResult analysisResult = roboflowApiClient.analyzeWithQwen(image);

    // Step 2: Apply routing logic
    if (isCriticalDetection(analysisResult)) {
      priorityEscalationService.handleCriticalDetection(report, analysisResult);
    } else {
      routeToWorkspace(report, analysisResult);
    }

    // Step 3: Generate and send ticket
    kafkaTicketService.generateTicket(report, analysisResult);
  }

  private boolean isCriticalDetection(RoboflowDto.AnalysisResult analysisResult) {
    return analysisResult.getMaxConfidence() > 0.9 ||
        analysisResult.containsCriticalObjects();
  }

  private void routeToWorkspace(Report report, RoboflowDto.AnalysisResult analysisResult) {
    String dominantCategory = analysisResult.getDominantCategory();
    String workspaceId = switch (dominantCategory) {
      case "ROAD" -> "jeonbuk-road";
      case "ENVIRONMENT" -> "jeonbuk-env";
      case "FACILITY" -> "jeonbuk-facility";
      default -> "integrated-detection";
    };

    // Update report with workspace information
    report.setWorkspaceId(workspaceId);

    // Get department based on location
    String department = gisService.getDepartmentForLocation(
        report.getLatitude(), report.getLongitude());
    report.setAssignedDepartment(department);
  }
}
