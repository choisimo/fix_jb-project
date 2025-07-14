package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.infrastructure.external.roboflow.RoboflowApiClient;
import com.jeonbuk.report.infrastructure.external.roboflow.RoboflowDto;
import com.jeonbuk.report.application.service.IntegratedAiAgentService.InputData;
import com.jeonbuk.report.application.service.IntegratedAiAgentService.AnalysisResult;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.atomic.AtomicLong;

@Slf4j
@Service
public class AiRoutingService {
  private final RoboflowApiClient roboflowApiClient;
  private final PriorityEscalationService priorityEscalationService;
  private final GisService gisService;
  private final KafkaTicketService kafkaTicketService;
  private final IntegratedAiAgentService integratedAiAgentService;

  // Statistics tracking
  private final AtomicLong totalRequests = new AtomicLong(0);
  private final AtomicLong successfulRequests = new AtomicLong(0);
  private final AtomicLong failedRequests = new AtomicLong(0);
  private final Map<String, AtomicLong> modelUsageStats = new HashMap<>();

  public AiRoutingService(RoboflowApiClient roboflowApiClient,
      PriorityEscalationService priorityEscalationService,
      GisService gisService,
      KafkaTicketService kafkaTicketService,
      IntegratedAiAgentService integratedAiAgentService) {
    this.roboflowApiClient = roboflowApiClient;
    this.priorityEscalationService = priorityEscalationService;
    this.gisService = gisService;
    this.kafkaTicketService = kafkaTicketService;
    this.integratedAiAgentService = integratedAiAgentService;
  }

  /**
   * Async processing of input data (full pipeline with validation)
   */
  public CompletableFuture<AiRoutingResult> processInputAsync(InputData inputData) {
    return CompletableFuture.supplyAsync(() -> {
      try {
        totalRequests.incrementAndGet();
        log.info("Processing AI routing request for: {}", inputData.getId());

        // Step 1: Analyze input data using integrated AI agent
        AnalysisResult analysisResult = integratedAiAgentService.analyzeInputAsync(inputData).join();

        if (!analysisResult.isSuccess()) {
          failedRequests.incrementAndGet();
          throw new RuntimeException("AI analysis failed: " + analysisResult.getErrorMessage());
        }

        // Step 2: Determine routing based on analysis
        String workspaceId = determineWorkspace(analysisResult);
        String department = determineDepartment(inputData, analysisResult);
        
        // Step 3: Check if critical escalation is needed
        boolean isCritical = isCriticalDetection(analysisResult);
        
        // Step 4: Update model usage statistics
        String selectedModel = analysisResult.getSelectedModel();
        modelUsageStats.computeIfAbsent(selectedModel, k -> new AtomicLong(0)).incrementAndGet();

        successfulRequests.incrementAndGet();

        return AiRoutingResult.builder()
            .inputId(inputData.getId())
            .workspaceId(workspaceId)
            .department(department)
            .isCritical(isCritical)
            .analysisResult(analysisResult)
            .selectedModel(selectedModel)
            .confidence(analysisResult.getAnalyzedData().getConfidence())
            .timestamp(System.currentTimeMillis())
            .build();

      } catch (Exception e) {
        failedRequests.incrementAndGet();
        log.error("Error processing input async: {}", e.getMessage(), e);
        throw new RuntimeException("AI routing failed", e);
      }
    });
  }

  /**
   * Simple async analysis (without full validation pipeline)
   */
  public CompletableFuture<AiRoutingResult> simpleAnalysisAsync(InputData inputData) {
    return CompletableFuture.supplyAsync(() -> {
      try {
        totalRequests.incrementAndGet();
        log.info("Processing simple AI analysis for: {}", inputData.getId());

        // Quick category determination based on keywords
        String category = determineSimpleCategory(inputData);
        String workspaceId = mapCategoryToWorkspace(category);
        
        successfulRequests.incrementAndGet();

        return AiRoutingResult.builder()
            .inputId(inputData.getId())
            .workspaceId(workspaceId)
            .department("AUTO_ASSIGNED")
            .isCritical(false)
            .analysisResult(null) // Simple analysis doesn't include full AI analysis
            .selectedModel("simple-routing")
            .confidence(0.7) // Default confidence for simple analysis
            .timestamp(System.currentTimeMillis())
            .build();

      } catch (Exception e) {
        failedRequests.incrementAndGet();
        log.error("Error in simple analysis: {}", e.getMessage(), e);
        throw new RuntimeException("Simple analysis failed", e);
      }
    });
  }

  /**
   * Batch processing of multiple inputs
   */
  public CompletableFuture<List<AiRoutingResult>> processBatchAsync(List<InputData> inputDataList) {
    return CompletableFuture.supplyAsync(() -> {
      log.info("Processing batch of {} items", inputDataList.size());

      List<CompletableFuture<AiRoutingResult>> futures = inputDataList.stream()
          .map(this::processInputAsync)
          .toList();

      return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
          .thenApply(v -> futures.stream()
              .map(future -> {
                try {
                  return future.join();
                } catch (Exception e) {
                  log.error("Error in batch processing item: {}", e.getMessage());
                  // Return error result for failed item
                  return AiRoutingResult.builder()
                      .inputId("unknown")
                      .workspaceId("error")
                      .department("ERROR")
                      .isCritical(false)
                      .analysisResult(null)
                      .selectedModel("error")
                      .confidence(0.0)
                      .timestamp(System.currentTimeMillis())
                      .build();
                }
              })
              .toList())
          .join();
    });
  }

  /**
   * Get processing statistics
   */
  public Map<String, Object> getProcessingStats() {
    Map<String, Object> stats = new HashMap<>();
    
    long total = totalRequests.get();
    long successful = successfulRequests.get();
    long failed = failedRequests.get();
    
    stats.put("totalRequests", total);
    stats.put("successfulRequests", successful);
    stats.put("failedRequests", failed);
    stats.put("successRate", total > 0 ? (double) successful / total : 0.0);
    
    // Model usage statistics
    Map<String, Long> modelStats = new HashMap<>();
    modelUsageStats.forEach((model, count) -> modelStats.put(model, count.get()));
    stats.put("modelUsageStats", modelStats);
    
    return stats;
  }

  private String determineWorkspace(AnalysisResult analysisResult) {
    if (analysisResult.getAnalyzedData() == null) {
      return "integrated-detection";
    }
    
    String objectType = analysisResult.getAnalyzedData().getObjectType();
    return switch (objectType.toLowerCase()) {
      case "pothole", "road_damage" -> "jeonbuk-road";
      case "traffic_sign", "infrastructure" -> "jeonbuk-facility";
      case "environment", "trash" -> "jeonbuk-env";
      default -> "integrated-detection";
    };
  }

  private String determineDepartment(InputData inputData, AnalysisResult analysisResult) {
    // Use GIS service to determine department based on location
    if (inputData.getLocation() != null) {
      try {
        // Simple coordinate extraction (assumes "lat,lng" format)
        String[] coords = inputData.getLocation().split(",");
        if (coords.length >= 2) {
          double lat = Double.parseDouble(coords[0].trim());
          double lng = Double.parseDouble(coords[1].trim());
          return gisService.determineWorkspace(lat, lng);
        }
      } catch (Exception e) {
        log.warn("Could not parse location: {}", inputData.getLocation());
      }
    }
    
    // Fallback to category-based department assignment
    if (analysisResult.getAnalyzedData() != null) {
      return mapCategoryToDepartment(analysisResult.getAnalyzedData().getObjectType());
    }
    
    return "GENERAL_AFFAIRS";
  }

  private String determineSimpleCategory(InputData inputData) {
    String title = inputData.getTitle() != null ? inputData.getTitle().toLowerCase() : "";
    String description = inputData.getDescription() != null ? inputData.getDescription().toLowerCase() : "";
    String combined = title + " " + description;

    if (combined.contains("도로") || combined.contains("포트홀") || combined.contains("road")) {
      return "ROAD";
    } else if (combined.contains("환경") || combined.contains("쓰레기") || combined.contains("environment")) {
      return "ENVIRONMENT";
    } else if (combined.contains("시설") || combined.contains("facility") || combined.contains("infrastructure")) {
      return "FACILITY";
    }
    
    return "GENERAL";
  }

  private String mapCategoryToWorkspace(String category) {
    return switch (category) {
      case "ROAD" -> "jeonbuk-road";
      case "ENVIRONMENT" -> "jeonbuk-env";
      case "FACILITY" -> "jeonbuk-facility";
      default -> "integrated-detection";
    };
  }

  private String mapCategoryToDepartment(String category) {
    return switch (category.toLowerCase()) {
      case "road", "pothole", "road_damage" -> "ROAD_MANAGEMENT";
      case "environment", "trash" -> "ENVIRONMENT_DEPARTMENT";
      case "facility", "infrastructure", "traffic_sign" -> "FACILITY_MANAGEMENT";
      default -> "GENERAL_AFFAIRS";
    };
  }

  public AiRoutingResult processReport(Report report, MultipartFile image) {
    // Step 1: Initial analysis with Qwen2.5 VL model
    RoboflowDto.AnalysisResult analysisResult = roboflowApiClient.analyzeWithQwen(image);

    // Step 2: Apply routing logic
    if (isCriticalDetection(analysisResult)) {
      priorityEscalationService.escalateIfNeeded(report);
    } else {
      routeToWorkspace(report, analysisResult);
    }

    // Step 3: Generate and send ticket
    kafkaTicketService.sendToWorkspace(report, report.getWorkspaceId());
    
    return AiRoutingResult.builder()
        .reportId(report.getId())
        .workspaceId(report.getWorkspaceId())
        .department(report.getAssignedDepartment())
        .isCritical(isCriticalDetection(analysisResult))
        .roboflowAnalysisResult(analysisResult)
        .build();
  }

  private boolean isCriticalDetection(RoboflowDto.AnalysisResult analysisResult) {
    if (analysisResult == null) return false;
    
    // Check if confidence is high and severity indicates critical issue
    return analysisResult.getConfidence() > 0.8 && 
           (analysisResult.getDetectedClass().toLowerCase().contains("severe") ||
            analysisResult.getDetectedClass().toLowerCase().contains("critical"));
  }

  private boolean isCriticalDetection(AnalysisResult analysisResult) {
    if (analysisResult == null || analysisResult.getAnalyzedData() == null) {
      return false;
    }
    
    String priority = analysisResult.getAnalyzedData().getPriority();
    String damageType = analysisResult.getAnalyzedData().getDamageType();
    
    return "critical".equalsIgnoreCase(priority) || 
           "severe".equalsIgnoreCase(damageType) ||
           analysisResult.getAnalyzedData().getConfidence() > 0.9;
  }

  private void routeToWorkspace(Report report, RoboflowDto.AnalysisResult analysisResult) {
    String dominantCategory = extractDominantCategory(analysisResult);
    String workspaceId = switch (dominantCategory) {
      case "ROAD" -> "jeonbuk-road";
      case "ENVIRONMENT" -> "jeonbuk-env";
      case "FACILITY" -> "jeonbuk-facility";
      default -> "integrated-detection";
    };

    // Update report with workspace information
    report.setWorkspaceId(workspaceId);

    // Get department based on location
    String department = gisService.determineWorkspace(
        report.getLatitude().doubleValue(), report.getLongitude().doubleValue());
    report.setAssignedDepartment(department);
  }

  private String extractDominantCategory(RoboflowDto.AnalysisResult analysisResult) {
    if (analysisResult == null || analysisResult.getDetectedClass() == null) {
      return "GENERAL";
    }
    
    String detectedClass = analysisResult.getDetectedClass().toLowerCase();
    
    if (detectedClass.contains("road") || detectedClass.contains("pothole")) {
      return "ROAD";
    } else if (detectedClass.contains("environment") || detectedClass.contains("trash")) {
      return "ENVIRONMENT";
    } else if (detectedClass.contains("facility") || detectedClass.contains("infrastructure")) {
      return "FACILITY";
    }
    
    return "GENERAL";
  }
  
  @Data
  @lombok.Builder
  public static class AiRoutingResult {
    private String inputId;
    private java.util.UUID reportId;
    private String workspaceId;
    private String department;
    private boolean isCritical;
    private AnalysisResult analysisResult;
    private RoboflowDto.AnalysisResult roboflowAnalysisResult;
    private String selectedModel;
    private Double confidence;
    private long timestamp;
  }
}
