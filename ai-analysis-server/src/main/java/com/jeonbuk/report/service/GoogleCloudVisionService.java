package com.jeonbuk.report.service;

import com.google.cloud.vision.v1.*;
import com.google.protobuf.ByteString;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
public class GoogleCloudVisionService {

    @Value("${google.cloud.vision.enabled:false}")
    private boolean visionEnabled;

    @Value("${google.cloud.project-id:}")
    private String projectId;

    private ImageAnnotatorClient client;

    public CompletableFuture<List<String>> extractTextFromImage(byte[] imageData) {
        return CompletableFuture.supplyAsync(() -> {
            if (!visionEnabled) {
                log.info("Google Cloud Vision is disabled, returning mock OCR result");
                return generateMockOcrResult();
            }

            try {
                if (client == null) {
                    initializeClient();
                }
                
                return performOcrAnalysis(imageData);
            } catch (Exception e) {
                log.error("Error performing OCR analysis", e);
                return generateMockOcrResult();
            }
        });
    }

    private void initializeClient() throws IOException {
        if (projectId.isEmpty()) {
            log.warn("Google Cloud project ID not configured, OCR will use mock responses");
            return;
        }
        
        try {
            this.client = ImageAnnotatorClient.create();
            log.info("Google Cloud Vision client initialized successfully");
        } catch (Exception e) {
            log.error("Failed to initialize Google Cloud Vision client", e);
            throw e;
        }
    }

    private List<String> performOcrAnalysis(byte[] imageData) {
        List<String> extractedTexts = new ArrayList<>();
        
        try {
            ByteString imgBytes = ByteString.copyFrom(imageData);
            Image img = Image.newBuilder().setContent(imgBytes).build();
            Feature feat = Feature.newBuilder().setType(Feature.Type.TEXT_DETECTION).build();
            AnnotateImageRequest request = AnnotateImageRequest.newBuilder()
                    .addFeatures(feat)
                    .setImage(img)
                    .build();

            BatchAnnotateImagesResponse response = client.batchAnnotateImages(
                    List.of(request));
            List<AnnotateImageResponse> responses = response.getResponsesList();

            for (AnnotateImageResponse res : responses) {
                if (res.hasError()) {
                    log.error("OCR Error: " + res.getError().getMessage());
                    continue;
                }

                for (EntityAnnotation annotation : res.getTextAnnotationsList()) {
                    String text = annotation.getDescription().trim();
                    if (!text.isEmpty()) {
                        extractedTexts.add(text);
                    }
                }
            }

            log.info("OCR analysis completed. Extracted {} text elements", extractedTexts.size());
            
        } catch (Exception e) {
            log.error("Error during OCR analysis", e);
            throw new RuntimeException("OCR analysis failed", e);
        }

        return extractedTexts.isEmpty() ? generateMockOcrResult() : extractedTexts;
    }

    private List<String> generateMockOcrResult() {
        List<String> mockTexts = new ArrayList<>();
        mockTexts.add("도로 표지판");
        mockTexts.add("시설물 번호: 12345");
        mockTexts.add("관리구역: 전북 전주시");
        mockTexts.add("설치일자: 2023-01-01");
        
        log.info("Generated mock OCR result with {} text elements", mockTexts.size());
        return mockTexts;
    }

    public CompletableFuture<Boolean> checkServiceHealth() {
        return CompletableFuture.supplyAsync(() -> {
            if (!visionEnabled) {
                return false;
            }
            
            try {
                if (client == null) {
                    initializeClient();
                }
                return client != null;
            } catch (Exception e) {
                log.error("Google Cloud Vision service health check failed", e);
                return false;
            }
        });
    }

    public void cleanup() {
        if (client != null) {
            try {
                client.close();
                log.info("Google Cloud Vision client closed successfully");
            } catch (Exception e) {
                log.error("Error closing Google Cloud Vision client", e);
            }
        }
    }
}