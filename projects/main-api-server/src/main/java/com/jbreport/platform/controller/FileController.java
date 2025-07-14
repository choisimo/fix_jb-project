package com.jbreport.platform.controller;

import com.jbreport.platform.service.FileStorageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/files")
@RequiredArgsConstructor
@Tag(name = "File Management", description = "File download operations")
@Slf4j
public class FileController {
    
    private final FileStorageService fileStorageService;
    
    @GetMapping("/{reportId}/{filename:.+}")
    @Operation(summary = "Download file", description = "Download a file by report ID and filename")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Resource> downloadFile(
            @PathVariable Long reportId,
            @PathVariable String filename,
            HttpServletRequest request) {
        
        try {
            Path filePath = fileStorageService.getFilePath(reportId, filename);
            Resource resource = new UrlResource(filePath.toUri());
            
            if (!resource.exists() || !resource.isReadable()) {
                throw new RuntimeException("File not found or not readable");
            }
            
            // Try to determine file's content type
            String contentType = null;
            try {
                contentType = request.getServletContext().getMimeType(resource.getFile().getAbsolutePath());
            } catch (IOException ex) {
                log.info("Could not determine file type.");
            }
            
            // Fallback to the default content type if type could not be determined
            if (contentType == null) {
                contentType = "application/octet-stream";
            }
            
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, 
                           "inline; filename=\"" + resource.getFilename() + "\"")
                    .body(resource);
                    
        } catch (MalformedURLException e) {
            throw new RuntimeException("File path error", e);
        }
    }
    
    @GetMapping("/info/{reportId}/{filename:.+}")
    @Operation(summary = "Get file info", description = "Get file metadata")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<FileInfo> getFileInfo(
            @PathVariable Long reportId,
            @PathVariable String filename) {
        
        try {
            Path filePath = fileStorageService.getFilePath(reportId, filename);
            
            if (!Files.exists(filePath)) {
                return ResponseEntity.notFound().build();
            }
            
            FileInfo fileInfo = FileInfo.builder()
                    .filename(filename)
                    .size(Files.size(filePath))
                    .contentType(Files.probeContentType(filePath))
                    .lastModified(Files.getLastModifiedTime(filePath).toMillis())
                    .build();
                    
            return ResponseEntity.ok(fileInfo);
            
        } catch (IOException e) {
            throw new RuntimeException("Error getting file info", e);
        }
    }
    
    @lombok.Data
    @lombok.Builder
    public static class FileInfo {
        private String filename;
        private long size;
        private String contentType;
        private long lastModified;
    }
}
