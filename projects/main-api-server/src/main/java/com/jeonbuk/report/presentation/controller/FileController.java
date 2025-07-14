package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.FileService;
import com.jeonbuk.report.domain.entity.ReportFile;
import com.jeonbuk.report.presentation.dto.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/files")
@RequiredArgsConstructor
@Slf4j
public class FileController {

    private final FileService fileService;

    @PostMapping("/upload/{reportId}")
    public ResponseEntity<ApiResponse<List<ReportFile>>> uploadFiles(
            @PathVariable UUID reportId,
            @RequestParam("files") MultipartFile[] files) {
        
        try {
            if (files == null || files.length == 0) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("No files provided"));
            }

            List<ReportFile> uploadedFiles = fileService.uploadFiles(reportId, files);
            
            return ResponseEntity.ok(
                    ApiResponse.success("Files uploaded successfully", uploadedFiles)
            );
            
        } catch (IOException e) {
            log.error("Error uploading files for report {}: {}", reportId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload files: " + e.getMessage()));
        } catch (RuntimeException e) {
            log.error("Runtime error uploading files for report {}: {}", reportId, e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/download/{filename}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String filename) {
        try {
            Resource resource = fileService.downloadFile(filename);
            
            String contentType = "application/octet-stream";
            String headerValue = "attachment; filename=\"" + filename + "\"";

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, headerValue)
                    .body(resource);
                    
        } catch (IOException e) {
            log.error("Error downloading file {}: {}", filename, e.getMessage());
            return ResponseEntity.notFound().build();
        } catch (RuntimeException e) {
            log.error("Runtime error downloading file {}: {}", filename, e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/thumbnail/{filename}")
    public ResponseEntity<Resource> getThumbnail(@PathVariable String filename) {
        try {
            Resource resource = fileService.downloadFile(filename);
            
            return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_JPEG)
                    .body(resource);
                    
        } catch (IOException e) {
            log.error("Error getting thumbnail {}: {}", filename, e.getMessage());
            return ResponseEntity.notFound().build();
        } catch (RuntimeException e) {
            log.error("Runtime error getting thumbnail {}: {}", filename, e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{fileId}")
    public ResponseEntity<ApiResponse<Void>> deleteFile(@PathVariable UUID fileId) {
        try {
            fileService.deleteFile(fileId);
            return ResponseEntity.ok(ApiResponse.success("File deleted successfully", null));
            
        } catch (IOException e) {
            log.error("Error deleting file {}: {}", fileId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to delete file: " + e.getMessage()));
        } catch (RuntimeException e) {
            log.error("Runtime error deleting file {}: {}", fileId, e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}