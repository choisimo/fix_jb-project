package com.jeonbuk.report.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/webhook/response")
@RequiredArgsConstructor
public class WebhookResponseController {

    // nginx 이미지 URL 베이스
    private static final String IMAGE_BASE_URL = "https://image.nodove.com/images/";
    private static final String NGINX_IMAGE_PATH = "/var/www/image.nodove.com/public/images/";

    /**
     * 이미지 처리 완료 후 결과를 받는 웹훅 엔드포인트
     * 외부 서비스(n8n, AI 처리 서비스 등)에서 결과를 POST로 전송
     */
    @PostMapping("/analysis-complete")
    public ResponseEntity<Map<String, String>> receiveAnalysisResult(
            @RequestBody Map<String, Object> payload,
            @RequestHeader(value = "X-Webhook-Source", required = false) String source) {
        
        try {
            log.info("Received webhook response from source: {}", source);
            log.info("Payload: {}", payload);

            // 필수 필드 검증
            String imageId = (String) payload.get("imageId");
            String status = (String) payload.get("status");
            String analysisResult = (String) payload.get("analysisResult");

            if (imageId == null || status == null) {
                log.warn("Missing required fields in webhook payload: imageId={}, status={}", imageId, status);
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Missing required fields: imageId, status"));
            }

            // 처리 상태에 따른 로직
            switch (status.toLowerCase()) {
                case "success":
                    handleSuccessfulAnalysis(imageId, analysisResult, payload);
                    break;
                case "failed":
                case "error":
                    handleFailedAnalysis(imageId, (String) payload.get("error"), payload);
                    break;
                default:
                    log.warn("Unknown status received: {}", status);
                    return ResponseEntity.badRequest()
                        .body(Map.of("error", "Unknown status: " + status));
            }

            return ResponseEntity.ok(Map.of("message", "Webhook processed successfully"));

        } catch (Exception e) {
            log.error("Error processing webhook response", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Internal server error"));
        }
    }

    /**
     * 성공적인 분석 결과 처리
     */
    private void handleSuccessfulAnalysis(String imageId, String analysisResult, Map<String, Object> payload) {
        log.info("Analysis completed successfully for image: {}", imageId);
        log.info("Analysis result: {}", analysisResult);
        
        // TODO: 분석 결과를 데이터베이스에 저장하거나 다른 서비스로 전달
        // 예: reportService.updateAnalysisResult(imageId, analysisResult);
        
        // 추가 메타데이터 처리
        if (payload.containsKey("confidence")) {
            log.info("Analysis confidence: {}", payload.get("confidence"));
        }
        if (payload.containsKey("categories")) {
            log.info("Detected categories: {}", payload.get("categories"));
        }
    }

    /**
     * 실패한 분석 결과 처리
     */
    private void handleFailedAnalysis(String imageId, String error, Map<String, Object> payload) {
        log.error("Analysis failed for image: {}, error: {}", imageId, error);
        
        // TODO: 실패 상태를 데이터베이스에 기록하거나 재시도 로직 구현
        // 예: reportService.markAnalysisFailed(imageId, error);
    }

    /**
     * 단순한 상태 확인 엔드포인트
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "healthy", "service", "webhook-response"));
    }

    /**
     * 진행 상황 업데이트를 받는 엔드포인트
     */
    @PostMapping("/progress")
    public ResponseEntity<Map<String, String>> receiveProgress(
            @RequestBody Map<String, Object> payload) {
        
        try {
            String imageId = (String) payload.get("imageId");
            String stage = (String) payload.get("stage");
            Integer progress = (Integer) payload.get("progress");

            log.info("Progress update for image {}: {} ({}%)", imageId, stage, progress);
            
            // TODO: 진행 상황을 실시간으로 클라이언트에게 전달 (WebSocket, SSE 등)
            
            return ResponseEntity.ok(Map.of("message", "Progress updated"));
            
        } catch (Exception e) {
            log.error("Error processing progress update", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Failed to process progress update"));
        }
    }

    /**
     * 이미지 다운로드 엔드포인트 - URL로 이미지 파일 제공
     * GET /api/v1/webhook/response/image/{imageId}
     */
    @GetMapping("/image/{imageId}")
    public ResponseEntity<Resource> downloadImage(@PathVariable String imageId) {
        try {
            // 이미지 파일 경로 설정 (실제 저장 경로에 맞게 수정 필요)
            String uploadDir = "/home/nodove/workspace/fix_jb-project/data/uploads/";
            Path imagePath = Paths.get(uploadDir + imageId);
            
            // 파일 존재 확인
            if (!Files.exists(imagePath)) {
                log.warn("Image not found: {}", imageId);
                return ResponseEntity.notFound().build();
            }

            // 파일 읽기
            byte[] imageData = Files.readAllBytes(imagePath);
            ByteArrayResource resource = new ByteArrayResource(imageData);

            // 파일 확장자로 Content-Type 결정
            String contentType = determineContentType(imagePath.toString());
            
            return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .contentLength(imageData.length)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + imageId + "\"")
                .body(resource);

        } catch (IOException e) {
            log.error("Error reading image file: {}", imageId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 이미지 정보 조회 엔드포인트 - nginx URL과 메타데이터 제공
     */
    @GetMapping("/image/{imageId}/info")
    public ResponseEntity<Map<String, Object>> getImageInfo(@PathVariable String imageId) {
        try {
            Path imagePath = Paths.get(NGINX_IMAGE_PATH + imageId);
            
            if (!Files.exists(imagePath)) {
                return ResponseEntity.notFound().build();
            }

            File imageFile = imagePath.toFile();
            String contentType = determineContentType(imagePath.toString());
            String nginxUrl = IMAGE_BASE_URL + imageId;
            
            // 이미지 정보 반환
            Map<String, Object> imageInfo = Map.of(
                "imageId", imageId,
                "fileName", imageFile.getName(),
                "size", imageFile.length(),
                "contentType", contentType,
                "nginxUrl", nginxUrl,
                "imageUrl", nginxUrl,
                "internalUrl", "/api/v1/webhook/response/image/" + imageId,
                "lastModified", imageFile.lastModified()
            );

            return ResponseEntity.ok(imageInfo);

        } catch (Exception e) {
            log.error("Error getting image info: {}", imageId, e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Failed to get image info"));
        }
    }

    /**
     * 웹훅 응답에 이미지 다운로드 URL 포함
     */
    @PostMapping("/analysis-complete-with-url")
    public ResponseEntity<Map<String, Object>> receiveAnalysisResultWithUrl(
            @RequestBody Map<String, Object> payload,
            @RequestHeader(value = "X-Webhook-Source", required = false) String source) {
        
        try {
            log.info("Received webhook response with URL from source: {}", source);
            
            String imageId = (String) payload.get("imageId");
            String status = (String) payload.get("status");
            
            if (imageId == null || status == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Missing required fields: imageId, status"));
            }

            // 기존 처리 로직
            switch (status.toLowerCase()) {
                case "success":
                    handleSuccessfulAnalysis(imageId, (String) payload.get("analysisResult"), payload);
                    break;
                case "failed":
                case "error":
                    handleFailedAnalysis(imageId, (String) payload.get("error"), payload);
                    break;
                default:
                    return ResponseEntity.badRequest()
                        .body(Map.of("error", "Unknown status: " + status));
            }

            // 응답에 nginx 이미지 URL 포함
            String nginxImageUrl = IMAGE_BASE_URL + imageId;
            Map<String, Object> response = Map.of(
                "message", "Webhook processed successfully",
                "imageId", imageId,
                "imageUrl", nginxImageUrl,
                "nginxUrl", nginxImageUrl,
                "internalUrl", "/api/v1/webhook/response/image/" + imageId
            );

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("Error processing webhook response", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Internal server error"));
        }
    }

    /**
     * 파일 확장자로 Content-Type 결정
     */
    private String determineContentType(String fileName) {
        String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
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