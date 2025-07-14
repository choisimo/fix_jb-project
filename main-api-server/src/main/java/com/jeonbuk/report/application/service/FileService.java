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

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
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
        try {
            log.info("Generating thumbnail for: {}", originalPath);
            
            // Read the original image
            BufferedImage originalImage = ImageIO.read(originalPath.toFile());
            if (originalImage == null) {
                log.warn("Unable to read image file: {}", originalPath);
                return;
            }
            
            // Calculate thumbnail dimensions (maintain aspect ratio)
            int thumbnailWidth = 200; // Configurable thumbnail width
            int thumbnailHeight = 200; // Configurable thumbnail height
            
            Dimension thumbnailSize = calculateThumbnailSize(
                originalImage.getWidth(), 
                originalImage.getHeight(), 
                thumbnailWidth, 
                thumbnailHeight
            );
            
            // Create thumbnail image with better quality
            BufferedImage thumbnailImage = new BufferedImage(
                thumbnailSize.width, 
                thumbnailSize.height, 
                BufferedImage.TYPE_INT_RGB
            );
            
            Graphics2D g2d = thumbnailImage.createGraphics();
            try {
                // Enable high-quality rendering
                g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
                g2d.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
                g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
                
                // Draw the scaled image
                g2d.drawImage(originalImage, 0, 0, thumbnailSize.width, thumbnailSize.height, null);
            } finally {
                g2d.dispose();
            }
            
            // Save thumbnail to file
            String originalFilename = originalPath.getFileName().toString();
            String baseFilename = getFilenameWithoutExtension(originalFilename);
            String extension = getFileExtension(originalFilename);
            String thumbnailFilename = "thumb_" + baseFilename + "." + extension;
            Path thumbnailPath = originalPath.getParent().resolve(thumbnailFilename);
            
            // Determine image format (default to JPEG for thumbnails)
            String formatName = "JPEG";
            if ("png".equalsIgnoreCase(extension)) {
                formatName = "PNG";
            }
            
            boolean success = ImageIO.write(thumbnailImage, formatName, thumbnailPath.toFile());
            
            if (success) {
                reportFile.setThumbnailPath(thumbnailPath.toString());
                reportFile.setThumbnailUrl("/api/v1/files/thumbnail/" + thumbnailFilename);
                log.info("Thumbnail generated successfully: {}", thumbnailPath);
            } else {
                log.error("Failed to write thumbnail image: {}", thumbnailPath);
            }
            
        } catch (IOException e) {
            log.error("Error generating thumbnail for {}: {}", originalPath, e.getMessage(), e);
        } catch (Exception e) {
            log.error("Unexpected error generating thumbnail for {}: {}", originalPath, e.getMessage(), e);
        }
    }
    
    /**
     * Calculate optimal thumbnail size maintaining aspect ratio
     */
    private Dimension calculateThumbnailSize(int originalWidth, int originalHeight, int maxWidth, int maxHeight) {
        double widthRatio = (double) maxWidth / originalWidth;
        double heightRatio = (double) maxHeight / originalHeight;
        double scaleFactor = Math.min(widthRatio, heightRatio);
        
        int thumbnailWidth = (int) (originalWidth * scaleFactor);
        int thumbnailHeight = (int) (originalHeight * scaleFactor);
        
        return new Dimension(thumbnailWidth, thumbnailHeight);
    }
    
    /**
     * Get filename without extension
     */
    private String getFilenameWithoutExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return filename;
        }
        return filename.substring(0, filename.lastIndexOf("."));
    }
    
    /**
     * Download thumbnail file
     */
    public Resource downloadThumbnail(String filename) throws IOException {
        Path thumbnailPath = Paths.get(uploadDir).resolve(filename);
        Resource resource = new UrlResource(thumbnailPath.toUri());
        
        if (resource.exists() && resource.isReadable()) {
            return resource;
        } else {
            throw new RuntimeException("Thumbnail not found: " + filename);
        }
    }
}