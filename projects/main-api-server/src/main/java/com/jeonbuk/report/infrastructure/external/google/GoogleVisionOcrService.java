package com.jeonbuk.report.infrastructure.external.google;

import com.google.cloud.vision.v1.*;
import com.google.protobuf.ByteString;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class GoogleVisionOcrService {

    private final WebClient webClient;

    @Value("${google.vision.api.key:}")
    private String googleApiKey;

    @Value("${file.server.base-url:http://localhost:8087}")
    private String fileServerBaseUrl;

    public String extractTextFromImageUrl(String imageUrl) {
        try {
            // 이미지 URL에서 바이트 데이터 다운로드
            byte[] imageBytes = downloadImageFromUrl(imageUrl);
            if (imageBytes == null || imageBytes.length == 0) {
                log.warn("Failed to download image from URL: {}", imageUrl);
                return "";
            }

            return extractTextFromImageBytes(imageBytes);
        } catch (Exception e) {
            log.error("Error extracting text from image URL: {}", imageUrl, e);
            return "";
        }
    }

    public String extractTextFromImageBytes(byte[] imageBytes) {
        try (ImageAnnotatorClient vision = ImageAnnotatorClient.create()) {
            ByteString imgBytes = ByteString.copyFrom(imageBytes);
            Image img = Image.newBuilder().setContent(imgBytes).build();
            Feature feat = Feature.newBuilder().setType(Feature.Type.TEXT_DETECTION).build();
            AnnotateImageRequest request = AnnotateImageRequest.newBuilder()
                    .addFeatures(feat)
                    .setImage(img)
                    .build();

            List<AnnotateImageRequest> requests = new ArrayList<>();
            requests.add(request);

            BatchAnnotateImagesResponse response = vision.batchAnnotateImages(requests);
            List<AnnotateImageResponse> responses = response.getResponsesList();

            if (responses.isEmpty()) {
                log.warn("No response from Google Vision API");
                return "";
            }

            AnnotateImageResponse res = responses.get(0);
            if (res.hasError()) {
                log.error("Google Vision API error: {}", res.getError().getMessage());
                return "";
            }

            // 전체 텍스트 추출
            String fullText = "";
            if (res.hasFullTextAnnotation()) {
                fullText = res.getFullTextAnnotation().getText();
            } else if (!res.getTextAnnotationsList().isEmpty()) {
                // fallback: 개별 텍스트 어노테이션 결합
                fullText = res.getTextAnnotationsList().stream()
                        .map(EntityAnnotation::getDescription)
                        .collect(Collectors.joining(" "));
            }

            log.info("Extracted text length: {} characters", fullText.length());
            return fullText.trim();

        } catch (IOException e) {
            log.error("Error creating Google Vision client", e);
            return "";
        } catch (Exception e) {
            log.error("Error extracting text from image", e);
            return "";
        }
    }

    private byte[] downloadImageFromUrl(String imageUrl) {
        try {
            return webClient.get()
                    .uri(imageUrl)
                    .retrieve()
                    .bodyToMono(byte[].class)
                    .block();
        } catch (Exception e) {
            log.error("Error downloading image from URL: {}", imageUrl, e);
            return null;
        }
    }

    public boolean isConfigured() {
        return googleApiKey != null && !googleApiKey.trim().isEmpty();
    }
}