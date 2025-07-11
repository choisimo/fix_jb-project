package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.entity.ReportFile;
import com.jeonbuk.report.domain.repository.ReportRepository;
import com.jeonbuk.report.domain.repository.ReportFileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigInteger;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class FileService {

    private final ReportRepository reportRepository;
    private final ReportFileRepository reportFileRepository;
    private final String uploadDir = System.getProperty("user.home") + "/jeonbuk-uploads";

    public List<ReportFile> uploadFiles(UUID reportId, MultipartFile[] files) throws IOException {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found with id: " + reportId));

        createUploadDirectoryIfNotExists();

        List<ReportFile> uploadedFiles = new ArrayList<>();

        for (int i = 0; i < files.length; i++) {
            MultipartFile file = files[i];
            if (!file.isEmpty()) {
                ReportFile reportFile = saveFile(report, file, i);
                reportFileRepository.save(reportFile);
                uploadedFiles.add(reportFile);
            }
        }

        report.getFiles().addAll(uploadedFiles);
        reportRepository.save(report);

        return uploadedFiles;
    }

    private ReportFile saveFile(Report report, MultipartFile file, int order) throws IOException {
        String originalFilename = StringUtils.cleanPath(file.getOriginalFilename());
        String fileExtension = getFileExtension(originalFilename);
        String savedFilename = UUID.randomUUID().toString() + "." + fileExtension;
        
        Path uploadPath = Paths.get(uploadDir);
        Path filePath = uploadPath.resolve(savedFilename);

        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        String fileHash = calculateFileHash(file.getBytes());

        ReportFile reportFile = ReportFile.builder()
                .report(report)
                .originalFilename(originalFilename)
                .filePath(filePath.toString())
                .fileUrl("/api/v1/files/download/" + savedFilename)
                .fileSize(file.getSize())
                .fileType(file.getContentType())
                .fileHash(fileHash)
                .fileOrder(order)
                .isPrimary(order == 0) // First file is primary by default
                .uploadedAt(LocalDateTime.now())
                .build();

        if (isImageFile(file.getContentType())) {
            generateThumbnail(reportFile, filePath);
        }

        return reportFile;
    }

    public Resource downloadFile(String filename) throws IOException {
        Path filePath = Paths.get(uploadDir).resolve(filename);
        Resource resource = new UrlResource(filePath.toUri());

        if (resource.exists() && resource.isReadable()) {
            return resource;
        } else {
            throw new RuntimeException("File not found: " + filename);
        }
    }

    public void deleteFile(UUID fileId) throws IOException {
        ReportFile reportFile = reportFileRepository.findById(fileId)
                .orElseThrow(() -> new RuntimeException("File not found with id: " + fileId));
        
        // Soft delete the entity
        reportFile.softDelete();
        reportFileRepository.save(reportFile);
        
        // Optionally delete physical file
        try {
            Path filePath = Paths.get(reportFile.getFilePath());
            Files.deleteIfExists(filePath);
            
            if (reportFile.getThumbnailPath() != null) {
                Path thumbnailPath = Paths.get(reportFile.getThumbnailPath());
                Files.deleteIfExists(thumbnailPath);
            }
        } catch (IOException e) {
            log.warn("Failed to delete physical file for ID {}: {}", fileId, e.getMessage());
        }
        
        log.info("File {} has been deleted", fileId);
    }

    private void createUploadDirectoryIfNotExists() throws IOException {
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
    }

    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf(".") + 1);
    }

    private String calculateFileHash(byte[] fileBytes) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(fileBytes);
            return new BigInteger(1, hash).toString(16);
        } catch (NoSuchAlgorithmException e) {
            log.error("Error calculating file hash", e);
            return null;
        }
    }

    private boolean isImageFile(String contentType) {
        return contentType != null && contentType.startsWith("image/");
    }

    private void generateThumbnail(ReportFile reportFile, Path originalPath) {
        // Placeholder for thumbnail generation
        // In a real implementation, you'd use libraries like ImageIO or external tools
        String thumbnailFilename = "thumb_" + originalPath.getFileName().toString();
        Path thumbnailPath = originalPath.getParent().resolve(thumbnailFilename);
        
        reportFile.setThumbnailPath(thumbnailPath.toString());
        reportFile.setThumbnailUrl("/api/v1/files/thumbnail/" + thumbnailFilename);
        
        log.info("Thumbnail generation placeholder for: {}", originalPath);
    }
}