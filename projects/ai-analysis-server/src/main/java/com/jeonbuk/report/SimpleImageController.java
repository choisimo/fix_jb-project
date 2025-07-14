package com.jeonbuk.report;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/simple")
public class SimpleImageController {

    @Value("${app.file.upload-dir:/home/nodove/images/}")
    private String uploadDir;
    
    @Value("${app.file.nginx-host:192.168.1.15}")
    private String nginxHost;
    
    @Value("${app.file.base-url:https://image.nodove.com/images/}")
    private String baseImageUrl;

    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadImage(
            @RequestPart("file") MultipartFile file,
            @RequestParam(value = "category", defaultValue = "reports") String category) {
        
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "No file provided"));
            }

            String originalFilename = file.getOriginalFilename();
            String fileExtension = getFileExtension(originalFilename);
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String fileName = String.format("%s_%s_%s%s", category, timestamp, uniqueId, fileExtension);

            Path targetPath = Paths.get(uploadDir + fileName);
            Files.createDirectories(targetPath.getParent());
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
            
            File savedFile = targetPath.toFile();
            savedFile.setReadable(true, false);

            String imageUrl = baseImageUrl + fileName;
            long fileSize = Files.size(targetPath);
            String contentType = file.getContentType();
            
            log.info("Image uploaded: {} -> {} (nginx: {})", originalFilename, imageUrl, nginxHost);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Image uploaded successfully");
            response.put("imageId", fileName);
            response.put("imageUrl", imageUrl);
            response.put("nginxUrl", imageUrl);
            response.put("originalName", originalFilename);
            response.put("size", fileSize);
            response.put("contentType", contentType);
            response.put("category", category);
            response.put("timestamp", timestamp);
            response.put("nginxHost", nginxHost);
            response.put("localPath", targetPath.toString());

            return ResponseEntity.ok(response);

        } catch (IOException e) {
            log.error("Error uploading image", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Failed to upload image: " + e.getMessage()));
        }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        try {
            Path localPath = Paths.get(uploadDir);
            boolean dirExists = Files.exists(localPath);
            boolean dirWritable = Files.isWritable(localPath);
            
            Map<String, Object> healthInfo = new HashMap<>();
            healthInfo.put("status", "healthy");
            healthInfo.put("service", "simple-image-upload");
            healthInfo.put("nginxHost", nginxHost);
            healthInfo.put("baseImageUrl", baseImageUrl);
            healthInfo.put("uploadDir", uploadDir);
            healthInfo.put("directoryExists", dirExists);
            healthInfo.put("directoryWritable", dirWritable);
            
            return ResponseEntity.ok(healthInfo);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("status", "error");
            error.put("message", e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }

    @GetMapping("/images/{fileName}")
    public ResponseEntity<Resource> serveImage(@PathVariable String fileName) {
        try {
            Path imagePath = Paths.get(uploadDir + fileName);
            
            if (!Files.exists(imagePath)) {
                return ResponseEntity.notFound().build();
            }

            byte[] imageData = Files.readAllBytes(imagePath);
            ByteArrayResource resource = new ByteArrayResource(imageData);
            String contentType = determineContentType(fileName);

            return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .contentLength(imageData.length)
                .header(HttpHeaders.CACHE_CONTROL, "max-age=86400")
                .header(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "*")
                .body(resource);

        } catch (IOException e) {
            log.error("Error serving image: {}", fileName, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf('.') == -1) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf('.'));
    }

    private String determineContentType(String fileName) {
        String extension = getFileExtension(fileName).toLowerCase();
        switch (extension) {
            case ".jpg":
            case ".jpeg":
                return "image/jpeg";
            case ".png":
                return "image/png";
            case ".gif":
                return "image/gif";
            case ".webp":
                return "image/webp";
            case ".bmp":
                return "image/bmp";
            default:
                return "application/octet-stream";
        }
    }
}