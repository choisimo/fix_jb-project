package com.jeonbuk.report.controller;

import lombok.RequiredArgsConstructor;
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
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class ImageStorageController {

    @Value("${app.file.upload-dir:/var/www/image.nodove.com/public/images/}")
    private String uploadDir;
    
    @Value("${app.file.nginx-host:192.168.1.15}")
    private String nginxHost;
    
    @Value("${app.file.base-url:https://image.nodove.com/images/}")
    private String baseImageUrl;

    /**
     * 이미지 업로드 - 로컬 저장 후 192.168.1.15 nginx URL 반환
     */
    @PostMapping("/webhook/upload-image")
    public ResponseEntity<Map<String, Object>> uploadImage(
            @RequestPart("file") MultipartFile file,
            @RequestParam(value = "category", defaultValue = "reports") String category) {
        
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "No file provided"));
            }

            // 파일명 생성 (중복 방지)
            String originalFilename = file.getOriginalFilename();
            String fileExtension = getFileExtension(originalFilename);
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String fileName = String.format("%s_%s_%s%s", category, timestamp, uniqueId, fileExtension);

            // 로컬 디렉토리에 저장 (192.168.1.15의 nginx가 서빙할 수 있는 위치)
            Path targetPath = Paths.get(uploadDir + fileName);
            
            // 디렉토리 존재 확인 및 생성
            Files.createDirectories(targetPath.getParent());
            
            // 파일 저장
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
            
            // 파일 권한 설정 (nginx가 읽을 수 있도록)
            File savedFile = targetPath.toFile();
            savedFile.setReadable(true, false);

            // 192.168.1.15 nginx를 통한 URL 생성
            String imageUrl = baseImageUrl + fileName;
            
            // 파일 정보
            long fileSize = Files.size(targetPath);
            String contentType = file.getContentType();
            
            log.info("Image uploaded successfully: {} -> {} (served by nginx at {})", 
                     originalFilename, imageUrl, nginxHost);

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

    /**
     * 이미지 정보 조회
     */
    @GetMapping("/webhook/image/{fileName}/info")
    public ResponseEntity<Map<String, Object>> getImageInfo(@PathVariable String fileName) {
        try {
            Path imagePath = Paths.get(uploadDir + fileName);
            
            if (!Files.exists(imagePath)) {
                return ResponseEntity.notFound().build();
            }

            File imageFile = imagePath.toFile();
            String contentType = determineContentType(fileName);
            
            Map<String, Object> imageInfo = new HashMap<>();
            imageInfo.put("imageId", fileName);
            imageInfo.put("imageUrl", baseImageUrl + fileName);
            imageInfo.put("nginxUrl", baseImageUrl + fileName);
            imageInfo.put("fileName", fileName);
            imageInfo.put("size", imageFile.length());
            imageInfo.put("contentType", contentType);
            imageInfo.put("lastModified", imageFile.lastModified());
            imageInfo.put("exists", true);
            imageInfo.put("nginxHost", nginxHost);
            imageInfo.put("localPath", imagePath.toString());

            return ResponseEntity.ok(imageInfo);

        } catch (Exception e) {
            log.error("Error getting image info: {}", fileName, e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Failed to get image info"));
        }
    }

    /**
     * 이미지 직접 서빙 (Spring Boot에서 - fallback용)
     */
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
                .header(HttpHeaders.CACHE_CONTROL, "max-age=86400") // 1일 캐시
                .header(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "*")
                .body(resource);

        } catch (IOException e) {
            log.error("Error serving image: {}", fileName, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 이미지 삭제
     */
    @DeleteMapping("/webhook/image/{fileName}")
    public ResponseEntity<Map<String, String>> deleteImage(@PathVariable String fileName) {
        try {
            Path imagePath = Paths.get(uploadDir + fileName);
            
            if (!Files.exists(imagePath)) {
                return ResponseEntity.notFound().build();
            }

            Files.delete(imagePath);
            log.info("Image deleted: {}", fileName);

            return ResponseEntity.ok(Map.of("message", "Image deleted successfully"));

        } catch (IOException e) {
            log.error("Error deleting image: {}", fileName, e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Failed to delete image"));
        }
    }

    /**
     * 이미지 URL 생성 (기존 이미지 파일용)
     */
    @PostMapping("/webhook/generate-url")
    public ResponseEntity<Map<String, Object>> generateImageUrl(@RequestBody Map<String, String> request) {
        String fileName = request.get("fileName");
        
        if (fileName == null || fileName.trim().isEmpty()) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "fileName is required"));
        }

        try {
            Path imagePath = Paths.get(uploadDir + fileName);
            
            if (!Files.exists(imagePath)) {
                return ResponseEntity.notFound().build();
            }

            String imageUrl = baseImageUrl + fileName;
            
            Map<String, Object> response = new HashMap<>();
            response.put("fileName", fileName);
            response.put("imageUrl", imageUrl);
            response.put("nginxUrl", imageUrl);
            response.put("exists", true);
            response.put("nginxHost", nginxHost);
            response.put("localPath", imagePath.toString());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("Error generating URL for image: {}", fileName, e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Failed to generate image URL"));
        }
    }

    /**
     * 상태 확인 엔드포인트
     */
    @GetMapping("/webhook/health")
    public ResponseEntity<Map<String, Object>> health() {
        try {
            Path localPath = Paths.get(uploadDir);
            boolean dirExists = Files.exists(localPath);
            boolean dirWritable = Files.isWritable(localPath);
            
            Map<String, Object> healthInfo = new HashMap<>();
            healthInfo.put("status", "healthy");
            healthInfo.put("service", "image-storage");
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

    /**
     * 파일 확장자 추출
     */
    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf('.') == -1) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf('.') + 1);
    }

    /**
     * 파일 확장자로 Content-Type 결정
     */
    public String determineContentType(String fileName) {
        String extension = getFileExtension(fileName).toLowerCase();
        switch (extension) {
            case "jpg":
            case "jpeg":
                return "image/jpeg";
            case "png":
                return "image/png";
            case "gif":
                return "image/gif";
            case "webp":
                return "image/webp";
            case "bmp":
                return "image/bmp";
            default:
                return "application/octet-stream";
        }
    }
}