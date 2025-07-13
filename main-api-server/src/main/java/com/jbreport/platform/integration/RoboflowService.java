package com.jbreport.platform.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class RoboflowService {
    
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    
    @Value("${roboflow.api.key}")
    private String apiKey;
    
    @Value("${roboflow.api.url:https://detect.roboflow.com}")
    private String apiUrl;
    
    @Value("${roboflow.model.id}")
    private String modelId;
    
    @Value("${roboflow.model.version:1}")
    private String modelVersion;
    
    public RoboflowAnalysisResult analyzeImage(MultipartFile imageFile) {
        try {
            String endpoint = String.format("%s/%s/%s", apiUrl, modelId, modelVersion);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);
            
            // Convert MultipartFile to Base64
            String base64Image = Base64.getEncoder().encodeToString(imageFile.getBytes());
            
            Map<String, Object> body = new HashMap<>();
            body.put("api_key", apiKey);
            body.put("image", base64Image);
            
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
            
            ResponseEntity<Map> response = restTemplate.exchange(
                endpoint,
                HttpMethod.POST,
                request,
                Map.class
            );
            
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                return parseRoboflowResponse(response.getBody());
            }
            
            throw new RuntimeException("Failed to analyze image with Roboflow");
            
        } catch (IOException e) {
            log.error("Error processing image for Roboflow analysis", e);
            throw new RuntimeException("Failed to process image", e);
        }
    }
    
    private RoboflowAnalysisResult parseRoboflowResponse(Map<String, Object> response) {
        RoboflowAnalysisResult result = new RoboflowAnalysisResult();
        
        if (response.containsKey("predictions")) {
            List<Map<String, Object>> predictions = (List<Map<String, Object>>) response.get("predictions");
            
            if (!predictions.isEmpty()) {
                // Get the prediction with highest confidence
                Map<String, Object> topPrediction = predictions.stream()
                    .max(Comparator.comparing(p -> (Double) p.get("confidence")))
                    .orElse(predictions.get(0));
                
                result.setDetectedClass((String) topPrediction.get("class"));
                result.setConfidence((Double) topPrediction.get("confidence"));
                result.setBoundingBox(parseBoundingBox(topPrediction));
                result.setAllPredictions(predictions);
            }
        }
        
        result.setImageMetadata((Map<String, Object>) response.get("image"));
        return result;
    }
    
    private BoundingBox parseBoundingBox(Map<String, Object> prediction) {
        BoundingBox bbox = new BoundingBox();
        bbox.setX((Integer) prediction.get("x"));
        bbox.setY((Integer) prediction.get("y"));
        bbox.setWidth((Integer) prediction.get("width"));
        bbox.setHeight((Integer) prediction.get("height"));
        return bbox;
    }
    
    public static class RoboflowAnalysisResult {
        private String detectedClass;
        private Double confidence;
        private BoundingBox boundingBox;
        private List<Map<String, Object>> allPredictions;
        private Map<String, Object> imageMetadata;
        
        // Getters and setters
        public String getDetectedClass() { return detectedClass; }
        public void setDetectedClass(String detectedClass) { this.detectedClass = detectedClass; }
        
        public Double getConfidence() { return confidence; }
        public void setConfidence(Double confidence) { this.confidence = confidence; }
        
        public BoundingBox getBoundingBox() { return boundingBox; }
        public void setBoundingBox(BoundingBox boundingBox) { this.boundingBox = boundingBox; }
        
        public List<Map<String, Object>> getAllPredictions() { return allPredictions; }
        public void setAllPredictions(List<Map<String, Object>> allPredictions) { this.allPredictions = allPredictions; }
        
        public Map<String, Object> getImageMetadata() { return imageMetadata; }
        public void setImageMetadata(Map<String, Object> imageMetadata) { this.imageMetadata = imageMetadata; }
    }
    
    public static class BoundingBox {
        private Integer x;
        private Integer y;
        private Integer width;
        private Integer height;
        
        // Getters and setters
        public Integer getX() { return x; }
        public void setX(Integer x) { this.x = x; }
        
        public Integer getY() { return y; }
        public void setY(Integer y) { this.y = y; }
        
        public Integer getWidth() { return width; }
        public void setWidth(Integer width) { this.width = width; }
        
        public Integer getHeight() { return height; }
        public void setHeight(Integer height) { this.height = height; }
    }
}
