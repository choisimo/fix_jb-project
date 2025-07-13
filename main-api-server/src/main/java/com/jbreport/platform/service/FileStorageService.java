package com.jbreport.platform.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.PosixFilePermission;
import java.nio.file.attribute.PosixFilePermissions;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class FileStorageService {
    
    @Value("${file.upload.storage-path:/var/jbreport/uploads}")
    private String storagePath;
    
    @Value("${file.upload.max-size:10485760}") // 10MB default
    private long maxFileSize;
    
    @Value("${file.upload.allowed-extensions:jpg,jpeg,png,gif,webp}")
    private String allowedExtensions;
    
    @Value("${file.local.permissions:755}")
    private String filePermissions;
    
    @Value("${file.security.enable-content-validation:true}")
    private boolean enableContentValidation;
    
    private Path rootLocation;
    
    @PostConstruct
    public void init() {
        this.rootLocation = Paths.get(storagePath);
        try {
            Files.createDirectories(rootLocation);
            
            // Set directory permissions for Unix-like systems
            if (FileSystems.getDefault().supportedFileAttributeViews().contains("posix")) {
                Set<PosixFilePermission> perms = PosixFilePermissions.fromString("rwxr-xr-x");
                Files.setPosixFilePermissions(rootLocation, perms);
            }
            
            log.info("File storage initialized at: {}", rootLocation.toAbsolutePath());
        } catch (IOException e) {
            throw new RuntimeException("Could not initialize file storage", e);
        }
    }
    
    public String storeFile(MultipartFile file, Long reportId) {
        validateFile(file);
        
        if (enableContentValidation) {
            validateFileContent(file);
        }
        
        String originalFilename = StringUtils.cleanPath(file.getOriginalFilename());
        String fileExtension = getFileExtension(originalFilename);
        String uniqueFilename = generateUniqueFilename(reportId, fileExtension);
        
        try {
            // Create report-specific directory with year/month structure
            String yearMonth = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy/MM"));
            Path reportDir = rootLocation.resolve(yearMonth).resolve(String.valueOf(reportId));
            Files.createDirectories(reportDir);
            
            // Save file with proper permissions
            Path targetLocation = reportDir.resolve(uniqueFilename);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
            
            // Set file permissions
            if (FileSystems.getDefault().supportedFileAttributeViews().contains("posix")) {
                Set<PosixFilePermission> perms = PosixFilePermissions.fromString("rw-r--r--");
                Files.setPosixFilePermissions(targetLocation, perms);
            }
            
            // Generate file hash for integrity check
            String fileHash = generateFileHash(targetLocation);
            log.info("File stored successfully: {} (hash: {})", targetLocation, fileHash);
            
            // Return relative path
            return String.format("/%s/%d/%s", yearMonth, reportId, uniqueFilename);
            
        } catch (IOException e) {
            log.error("Failed to store file: {}", originalFilename, e);
            throw new RuntimeException("Failed to store file", e);
        }
    }
    
    public Path getFilePath(Long reportId, String filename) {
        // Extract year/month from the stored path pattern
        String[] parts = filename.split("/");
        if (parts.length >= 3) {
            return rootLocation.resolve(parts[0]).resolve(parts[1]).resolve(parts[2]);
        }
        
        // Fallback for backward compatibility
        return rootLocation.resolve(String.valueOf(reportId)).resolve(filename);
    }
    
    private void validateFileContent(MultipartFile file) {
        try {
            // Check file signature (magic numbers)
            byte[] fileSignature = new byte[4];
            file.getInputStream().read(fileSignature);
            file.getInputStream().reset();
            
            String contentType = file.getContentType();
            if (contentType != null && contentType.startsWith("image/")) {
                // Validate image file signatures
                if (!isValidImageSignature(fileSignature, contentType)) {
                    throw new IllegalArgumentException("Invalid file content for declared type");
                }
            }
        } catch (IOException e) {
            log.error("Error validating file content", e);
        }
    }
    
    private boolean isValidImageSignature(byte[] signature, String contentType) {
        // JPEG
        if (contentType.contains("jpeg") || contentType.contains("jpg")) {
            return signature[0] == (byte) 0xFF && signature[1] == (byte) 0xD8;
        }
        // PNG
        if (contentType.contains("png")) {
            return signature[0] == (byte) 0x89 && signature[1] == (byte) 0x50;
        }
        // GIF
        if (contentType.contains("gif")) {
            return signature[0] == (byte) 0x47 && signature[1] == (byte) 0x49;
        }
        return true; // Allow other types
    }
    
    private String generateFileHash(Path filePath) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] fileBytes = Files.readAllBytes(filePath);
            byte[] hashBytes = md.digest(fileBytes);
            
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException | IOException e) {
            log.error("Error generating file hash", e);
            return "unknown";
        }
    }
    
    private void validateFile(MultipartFile file) {
        // Check if file is empty
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }
        
        // Check file size
        if (file.getSize() > maxFileSize) {
            throw new IllegalArgumentException("File size exceeds maximum allowed size");
        }
        
        // Check file extension
        String filename = file.getOriginalFilename();
        if (filename == null || !hasAllowedExtension(filename)) {
            throw new IllegalArgumentException("File type not allowed");
        }
    }
    
    private boolean hasAllowedExtension(String filename) {
        String extension = getFileExtension(filename).toLowerCase();
        String[] allowed = allowedExtensions.split(",");
        for (String ext : allowed) {
            if (ext.trim().equals(extension)) {
                return true;
            }
        }
        return false;
    }
    
    private String getFileExtension(String filename) {
        int dotIndex = filename.lastIndexOf('.');
        return (dotIndex == -1) ? "" : filename.substring(dotIndex + 1);
    }
    
    private String generateUniqueFilename(Long reportId, String extension) {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        return String.format("report_%d_%s_%s.%s", reportId, timestamp, uuid, extension);
    }
}
