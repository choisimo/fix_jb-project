package com.jbreport.platform.service;

import com.jbreport.platform.dto.ReportCreateDTO;
import com.jbreport.platform.dto.ReportDTO;
import com.jbreport.platform.entity.Report;
import com.jbreport.platform.entity.ReportFile;
import com.jbreport.platform.entity.User;
import com.jbreport.platform.entity.Alert;
import com.jbreport.platform.exception.ResourceNotFoundException;
import com.jbreport.platform.integration.OpenRouterService;
import com.jbreport.platform.integration.RoboflowService;
import com.jbreport.platform.kafka.KafkaProducerService;
import com.jbreport.platform.repository.ReportRepository;
import com.jbreport.platform.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ReportService {
    
    private final ReportRepository reportRepository;
    private final UserRepository userRepository;
    private final FileStorageService fileStorageService;
    private final RoboflowService roboflowService;
    private final OpenRouterService openRouterService;
    private final KafkaProducerService kafkaProducerService;
    private final AlertService alertService;
    
    public ReportDTO createReport(ReportCreateDTO createDTO, List<MultipartFile> files, String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        Report report = new Report();
        report.setTitle(createDTO.getTitle());
        report.setDescription(createDTO.getDescription());
        report.setCategory(createDTO.getCategory());
        report.setLatitude(createDTO.getLatitude());
        report.setLongitude(createDTO.getLongitude());
        report.setAddress(createDTO.getAddress());
        report.setUser(user);
        report.setStatus("PENDING");
        report.setPriority("MEDIUM");
        report.setCreatedAt(LocalDateTime.now());
        report.setUpdatedAt(LocalDateTime.now());
        
        // Save report first
        Report savedReport = reportRepository.save(report);
        
        // Process files and run AI analysis asynchronously
        if (files != null && !files.isEmpty()) {
            processFilesAsync(savedReport, files);
        }
        
        // Run text analysis asynchronously
        if (createDTO.getDescription() != null && !createDTO.getDescription().isEmpty()) {
            analyzeTextAsync(savedReport);
        }
        
        // Send Kafka event for new report
        kafkaProducerService.sendReportEvent("report.created", savedReport.getId(), Map.of(
            "reportId", savedReport.getId(),
            "userId", user.getId(),
            "category", savedReport.getCategory(),
            "timestamp", LocalDateTime.now().toString()
        ));
        
        // Create alert for admin users
        createAdminAlert(savedReport);
        
        return convertToDTO(savedReport);
    }
    
    private void processFilesAsync(Report report, List<MultipartFile> files) {
        CompletableFuture.runAsync(() -> {
            try {
                List<ReportFile> reportFiles = new ArrayList<>();
                
                for (MultipartFile file : files) {
                    // Store file
                    String filePath = fileStorageService.storeFile(file, report.getId());
                    
                    ReportFile reportFile = new ReportFile();
                    reportFile.setReport(report);
                    reportFile.setFileName(file.getOriginalFilename());
                    reportFile.setFilePath(filePath);
                    reportFile.setFileSize(file.getSize());
                    reportFile.setContentType(file.getContentType());
                    reportFile.setUploadedAt(LocalDateTime.now());
                    reportFiles.add(reportFile);
                    
                    // Run Roboflow analysis on image
                    if (file.getContentType() != null && file.getContentType().startsWith("image/")) {
                        try {
                            RoboflowService.RoboflowAnalysisResult result = roboflowService.analyzeImage(file);
                            
                            // Update report category based on AI detection
                            if (result.getConfidence() > 0.7 && result.getDetectedClass() != null) {
                                String aiCategory = mapRoboflowClassToCategory(result.getDetectedClass());
                                if (!aiCategory.equals("OTHER")) {
                                    report.setCategory(aiCategory);
                                    report.setAiAnalyzed(true);
                                    reportRepository.save(report);
                                }
                            }
                            
                            // Send AI analysis result to Kafka
                            kafkaProducerService.sendAiAnalysisResult("image.analysis.completed", 
                                report.getId(), Map.of(
                                    "reportId", report.getId(),
                                    "analysisType", "IMAGE",
                                    "detectedClass", result.getDetectedClass(),
                                    "confidence", result.getConfidence(),
                                    "timestamp", LocalDateTime.now().toString()
                                ));
                            
                        } catch (Exception e) {
                            log.error("Failed to analyze image with Roboflow", e);
                        }
                    }
                }
                
                report.setFiles(reportFiles);
                reportRepository.save(report);
                
            } catch (Exception e) {
                log.error("Failed to process files for report {}", report.getId(), e);
            }
        });
    }
    
    private void analyzeTextAsync(Report report) {
        CompletableFuture.runAsync(() -> {
            try {
                // Categorization analysis
                OpenRouterService.TextAnalysisResult categoryResult = 
                    openRouterService.analyzeText(report.getDescription(), "CATEGORIZE");
                
                if (categoryResult.getConfidence() != null && categoryResult.getConfidence() > 0.7) {
                    report.setCategory(categoryResult.getCategory());
                    report.setAiAnalyzed(true);
                }
                
                // Sentiment and urgency analysis
                OpenRouterService.TextAnalysisResult sentimentResult = 
                    openRouterService.analyzeText(report.getDescription(), "SENTIMENT");
                
                Map<String, Object> parsedData = sentimentResult.getParsedData();
                if (parsedData != null && parsedData.containsKey("urgency")) {
                    String urgency = (String) parsedData.get("urgency");
                    report.setPriority(urgency);
                }
                
                reportRepository.save(report);
                
                // Send AI analysis result to Kafka
                kafkaProducerService.sendAiAnalysisResult("text.analysis.completed", 
                    report.getId(), Map.of(
                        "reportId", report.getId(),
                        "analysisType", "TEXT",
                        "category", categoryResult.getCategory(),
                        "confidence", categoryResult.getConfidence(),
                        "urgency", parsedData.get("urgency"),
                        "timestamp", LocalDateTime.now().toString()
                    ));
                
            } catch (Exception e) {
                log.error("Failed to analyze text with OpenRouter", e);
            }
        });
    }
    
    private String mapRoboflowClassToCategory(String roboflowClass) {
        // Map Roboflow detection classes to report categories
        Map<String, String> classMapping = Map.of(
            "pothole", "ROAD_DAMAGE",
            "crack", "ROAD_DAMAGE",
            "illegal_parking", "ILLEGAL_PARKING",
            "garbage", "GARBAGE",
            "trash", "GARBAGE",
            "broken_facility", "FACILITY_DAMAGE",
            "damage", "FACILITY_DAMAGE"
        );
        
        return classMapping.getOrDefault(roboflowClass.toLowerCase(), "OTHER");
    }
    
    private void createAdminAlert(Report report) {
        // Create alerts for admin users
        List<User> admins = userRepository.findByRole("ADMIN");
        for (User admin : admins) {
            alertService.createAlert(
                Alert.AlertType.STATUS_CHANGE,
                Alert.AlertSeverity.MEDIUM,
                "New Report Submitted",
                String.format("A new report '%s' has been submitted in category %s", 
                    report.getTitle(), report.getCategory()),
                admin.getId(),
                report.getId()
            );
        }
    }
    
    public Page<ReportDTO> getReports(String category, String status, String priority, Pageable pageable) {
        // Implementation with proper filtering
        Page<Report> reports;
        
        if (category != null || status != null || priority != null) {
            reports = reportRepository.findWithFilters(category, status, priority, pageable);
        } else {
            reports = reportRepository.findAll(pageable);
        }
        
        return reports.map(this::convertToDTO);
    }
    
    public ReportDTO getReportById(Long id) {
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found"));
        return convertToDTO(report);
    }
    
    public ReportDTO updateReportStatus(Long id, String status, String userEmail) {
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found"));
        
        String oldStatus = report.getStatus();
        report.setStatus(status);
        report.setUpdatedAt(LocalDateTime.now());
        
        Report updatedReport = reportRepository.save(report);
        
        // Send status change event
        kafkaProducerService.sendReportEvent("report.status.changed", report.getId(), Map.of(
            "reportId", report.getId(),
            "oldStatus", oldStatus,
            "newStatus", status,
            "updatedBy", userEmail,
            "timestamp", LocalDateTime.now().toString()
        ));
        
        // Create alert for report owner
        alertService.createAlert(
            Alert.AlertType.STATUS_CHANGE,
            Alert.AlertSeverity.MEDIUM,
            "Report Status Updated",
            String.format("Your report '%s' status has been changed from %s to %s", 
                report.getTitle(), oldStatus, status),
            report.getUser().getId(),
            report.getId()
        );
        
        return convertToDTO(updatedReport);
    }
    
    private ReportDTO convertToDTO(Report report) {
        ReportDTO dto = new ReportDTO();
        dto.setId(report.getId());
        dto.setTitle(report.getTitle());
        dto.setDescription(report.getDescription());
        dto.setCategory(report.getCategory());
        dto.setStatus(report.getStatus());
        dto.setPriority(report.getPriority());
        dto.setLatitude(report.getLatitude());
        dto.setLongitude(report.getLongitude());
        dto.setAddress(report.getAddress());
        dto.setAiAnalyzed(report.isAiAnalyzed());
        dto.setCreatedAt(report.getCreatedAt());
        dto.setUpdatedAt(report.getUpdatedAt());
        
        if (report.getUser() != null) {
            dto.setUserId(report.getUser().getId());
            dto.setUserName(report.getUser().getName());
        }
        
        if (report.getFiles() != null) {
            dto.setFileUrls(report.getFiles().stream()
                    .map(ReportFile::getFilePath)
                    .collect(Collectors.toList()));
        }
        
        return dto;
    }
}
