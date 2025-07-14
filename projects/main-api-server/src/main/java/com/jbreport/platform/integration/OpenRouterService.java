package com.jbreport.platform.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class OpenRouterService {
    
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    
    @Value("${openrouter.api.key}")
    private String apiKey;
    
    @Value("${openrouter.api.url:https://openrouter.ai/api/v1}")
    private String apiUrl;
    
    @Value("${openrouter.model:mistralai/mistral-7b-instruct}")
    private String model;
    
    public TextAnalysisResult analyzeText(String text, String analysisType) {
        try {
            String prompt = buildPrompt(text, analysisType);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);
            headers.set("HTTP-Referer", "https://jbreport.com");
            headers.set("X-Title", "JB Report Platform");
            
            Map<String, Object> body = new HashMap<>();
            body.put("model", model);
            body.put("messages", Arrays.asList(
                Map.of("role", "system", "content", "You are a helpful assistant analyzing reports for a city reporting system."),
                Map.of("role", "user", "content", prompt)
            ));
            body.put("temperature", 0.7);
            body.put("max_tokens", 500);
            
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
            
            ResponseEntity<Map> response = restTemplate.exchange(
                apiUrl + "/chat/completions",
                HttpMethod.POST,
                request,
                Map.class
            );
            
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                return parseOpenRouterResponse(response.getBody(), analysisType);
            }
            
            throw new RuntimeException("Failed to analyze text with OpenRouter");
            
        } catch (Exception e) {
            log.error("Error analyzing text with OpenRouter", e);
            throw new RuntimeException("Failed to analyze text", e);
        }
    }
    
    private String buildPrompt(String text, String analysisType) {
        switch (analysisType) {
            case "CATEGORIZE":
                return String.format(
                    "Analyze the following report and categorize it into one of these categories: " +
                    "ROAD_DAMAGE, ILLEGAL_PARKING, GARBAGE, FACILITY_DAMAGE, OTHER. " +
                    "Also provide a confidence score (0-1) and brief explanation.\n\nReport: %s\n\n" +
                    "Response format: {\"category\": \"...\", \"confidence\": 0.X, \"explanation\": \"...\"}",
                    text
                );
                
            case "SUMMARIZE":
                return String.format(
                    "Summarize the following report in 2-3 sentences, highlighting the main issue and location if mentioned.\n\n" +
                    "Report: %s",
                    text
                );
                
            case "SENTIMENT":
                return String.format(
                    "Analyze the sentiment of this report. Determine if it's POSITIVE, NEGATIVE, or NEUTRAL. " +
                    "Also provide urgency level (LOW, MEDIUM, HIGH) based on the content.\n\n" +
                    "Report: %s\n\n" +
                    "Response format: {\"sentiment\": \"...\", \"urgency\": \"...\", \"explanation\": \"...\"}",
                    text
                );
                
            default:
                return String.format("Analyze this report and provide insights: %s", text);
        }
    }
    
    private TextAnalysisResult parseOpenRouterResponse(Map<String, Object> response, String analysisType) {
        TextAnalysisResult result = new TextAnalysisResult();
        result.setAnalysisType(analysisType);
        
        List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
        if (choices != null && !choices.isEmpty()) {
            Map<String, Object> firstChoice = choices.get(0);
            Map<String, Object> message = (Map<String, Object>) firstChoice.get("message");
            String content = (String) message.get("content");
            
            result.setRawResponse(content);
            
            // Try to parse structured response
            try {
                Map<String, Object> parsedContent = objectMapper.readValue(content, Map.class);
                result.setParsedData(parsedContent);
                
                if (analysisType.equals("CATEGORIZE") && parsedContent.containsKey("category")) {
                    result.setCategory((String) parsedContent.get("category"));
                    result.setConfidence(((Number) parsedContent.get("confidence")).doubleValue());
                }
            } catch (Exception e) {
                // If parsing fails, just use the raw response
                log.debug("Could not parse structured response, using raw text", e);
            }
        }
        
        result.setUsage((Map<String, Object>) response.get("usage"));
        return result;
    }
    
    public static class TextAnalysisResult {
        private String analysisType;
        private String rawResponse;
        private Map<String, Object> parsedData;
        private String category;
        private Double confidence;
        private Map<String, Object> usage;
        
        // Getters and setters
        public String getAnalysisType() { return analysisType; }
        public void setAnalysisType(String analysisType) { this.analysisType = analysisType; }
        
        public String getRawResponse() { return rawResponse; }
        public void setRawResponse(String rawResponse) { this.rawResponse = rawResponse; }
        
        public Map<String, Object> getParsedData() { return parsedData; }
        public void setParsedData(Map<String, Object> parsedData) { this.parsedData = parsedData; }
        
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        
        public Double getConfidence() { return confidence; }
        public void setConfidence(Double confidence) { this.confidence = confidence; }
        
        public Map<String, Object> getUsage() { return usage; }
        public void setUsage(Map<String, Object> usage) { this.usage = usage; }
    }
}
