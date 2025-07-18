package com.jeonbuk.report.application.service;

import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterApiClient;
import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterDto;
import com.jeonbuk.report.application.service.IntegratedAiAgentService.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * 검증 AI 에이전트 서비스
 * 
 * 기능:
 * - 파싱된 데이터 검증
 * - Roboflow 모델 라우팅 결정 검증
 * - OpenRouter AI를 이용한 교차 검증
 * - 멀티스레딩으로 UI 스레드 블로킹 방지
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ValidationAiAgentService {

    private final OpenRouterApiClient openRouterClient;
    private final ObjectMapper objectMapper;

    /**
     * 비동기 데이터 검증
     * UI 스레드를 블로킹하지 않습니다.
     */
    public CompletableFuture<ValidationResult> validateDataAsync(AnalyzedData analyzedData) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("Starting data validation for: {}", analyzedData.getId());
                return validateData(analyzedData);
            } catch (Exception e) {
                log.error("Error in async data validation: {}", e.getMessage(), e);
                return new ValidationResult(
                        analyzedData.getId(),
                        false,
                        "Validation failed: " + e.getMessage(),
                        List.of(e.getMessage()),
                        0.0,
                        System.currentTimeMillis());
            }
        });
    }

    /**
     * 비동기 라우팅 결정 검증
     */
    public CompletableFuture<ValidationResult> validateRoutingDecisionAsync(
            AnalyzedData analyzedData, String selectedModelId) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("Starting routing validation for model: {} with data: {}",
                        selectedModelId, analyzedData.getId());
                return validateRoutingDecision(analyzedData, selectedModelId);
            } catch (Exception e) {
                log.error("Error in async routing validation: {}", e.getMessage(), e);
                return new ValidationResult(
                        analyzedData.getId(),
                        false,
                        "Routing validation failed: " + e.getMessage(),
                        List.of(e.getMessage()),
                        0.0,
                        System.currentTimeMillis());
            }
        });
    }

    /**
     * 통합 검증 (데이터 + 라우팅 결정)
     */
    public CompletableFuture<ValidationResult> validateCompleteAsync(
            AnalyzedData analyzedData, String selectedModelId) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("Starting complete validation for: {}", analyzedData.getId());

                // 데이터 검증
                ValidationResult dataValidation = validateData(analyzedData);
                if (!dataValidation.isValid()) {
                    return dataValidation;
                }

                // 라우팅 결정 검증
                ValidationResult routingValidation = validateRoutingDecision(analyzedData, selectedModelId);

                // 종합 결과
                boolean overallValid = dataValidation.isValid() && routingValidation.isValid();
                double combinedScore = (dataValidation.getValidationScore() + routingValidation.getValidationScore())
                        / 2.0;

                List<String> allIssues = new java.util.ArrayList<>(dataValidation.getValidationIssues());
                allIssues.addAll(routingValidation.getValidationIssues());

                return new ValidationResult(
                        analyzedData.getId(),
                        overallValid,
                        overallValid ? "Complete validation passed" : "Complete validation failed",
                        allIssues,
                        combinedScore,
                        System.currentTimeMillis());

            } catch (Exception e) {
                log.error("Error in complete validation: {}", e.getMessage(), e);
                return new ValidationResult(
                        analyzedData.getId(),
                        false,
                        "Complete validation failed: " + e.getMessage(),
                        List.of(e.getMessage()),
                        0.0,
                        System.currentTimeMillis());
            }
        });
    }

    /**
     * 데이터 검증 (내부 메서드)
     */
    private ValidationResult validateData(AnalyzedData analyzedData) {
        log.info("🤖 OpenRouter API 검증 요청 시작 - 데이터 ID: {}", analyzedData.getId());
        
        try {
            String validationPrompt = buildDataValidationPrompt(analyzedData);
            
            List<OpenRouterDto.Message> messages = List.of(
                    new OpenRouterDto.Message("system",
                            "You are an expert data validation AI. Your job is to validate parsed data " +
                                    "for consistency, accuracy, and logical coherence. Return validation results in JSON format."),
                    new OpenRouterDto.Message("user", validationPrompt));

            String responseText;
            try {
                responseText = openRouterClient.chatCompletionAsync(messages).get();
                log.info("✅ OpenRouter API 검증 응답 성공");
            } catch (Exception openRouterException) {
                log.warn("⚠️ OpenRouter API 실패, 개선된 fallback 사용: {}", openRouterException.getMessage());
                // OpenRouter API 실패 시 개선된 fallback 사용
                responseText = generateIntelligentValidationResponse(analyzedData);
            }
            
            return parseValidationResponse(responseText, analyzedData.getId(), "data");

        } catch (Exception e) {
            log.error("Error in data validation, using intelligent fallback: {}", e.getMessage());
            // 모든 에러에 대해 개선된 fallback 응답 사용
            String intelligentResponse = generateIntelligentValidationResponse(analyzedData);
            return parseValidationResponse(intelligentResponse, analyzedData.getId(), "data");
        }
    }

    /**
     * 라우팅 결정 검증 (내부 메서드)
     */
    private ValidationResult validateRoutingDecision(AnalyzedData analyzedData, String selectedModelId) {
        log.info("🤖 OpenRouter API 라우팅 검증 요청 시작 - 모델: {}", selectedModelId);
        
        try {
            String routingPrompt = buildRoutingValidationPrompt(analyzedData, selectedModelId);
            
            List<OpenRouterDto.Message> messages = List.of(
                    new OpenRouterDto.Message("system",
                            "You are an expert AI model routing validator. Your job is to validate " +
                                    "whether the selected AI model is appropriate for the given data context. " +
                                    "Return validation results in JSON format."),
                    new OpenRouterDto.Message("user", routingPrompt));

            String responseText;
            try {
                responseText = openRouterClient.chatCompletionAsync(messages).get();
                log.info("✅ OpenRouter API 라우팅 검증 응답 성공");
            } catch (Exception openRouterException) {
                log.warn("⚠️ OpenRouter API 실패, 개선된 라우팅 fallback 사용: {}", openRouterException.getMessage());
                // OpenRouter API 실패 시 개선된 fallback 사용
                responseText = generateIntelligentRoutingValidationResponse(analyzedData, selectedModelId);
            }
            
            return parseValidationResponse(responseText, analyzedData.getId(), "routing");

        } catch (Exception e) {
            log.error("Error in routing validation, using intelligent fallback: {}", e.getMessage());
            // 모든 에러에 대해 개선된 fallback 응답 사용
            String intelligentResponse = generateIntelligentRoutingValidationResponse(analyzedData, selectedModelId);
            return parseValidationResponse(intelligentResponse, analyzedData.getId(), "routing");
        }
    }

    /**
     * 데이터 검증 프롬프트 구성
     */
    private String buildDataValidationPrompt(AnalyzedData analyzedData) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Please validate the following analyzed data for consistency and accuracy:\n\n");
        prompt.append("Original Input:\n");

        InputData originalInput = analyzedData.getOriginalInput();
        if (originalInput != null) {
            if (originalInput.getTitle() != null) {
                prompt.append("- Title: ").append(originalInput.getTitle()).append("\n");
            }
            if (originalInput.getDescription() != null) {
                prompt.append("- Description: ").append(originalInput.getDescription()).append("\n");
            }
            if (originalInput.getLocation() != null) {
                prompt.append("- Location: ").append(originalInput.getLocation()).append("\n");
            }
        }

        prompt.append("\nAnalyzed Data:\n");
        prompt.append("- Object Type: ").append(analyzedData.getObjectType()).append("\n");
        prompt.append("- Damage Type: ").append(analyzedData.getDamageType()).append("\n");
        prompt.append("- Environment: ").append(analyzedData.getEnvironment()).append("\n");
        prompt.append("- Priority: ").append(analyzedData.getPriority()).append("\n");
        prompt.append("- Category: ").append(analyzedData.getCategory()).append("\n");
        prompt.append("- Keywords: ").append(analyzedData.getKeywords()).append("\n");
        prompt.append("- Confidence: ").append(analyzedData.getConfidence()).append("\n");

        prompt.append("\nPlease validate and return results in JSON format:\n");
        prompt.append("{\n");
        prompt.append("  \"isValid\": true/false,\n");
        prompt.append("  \"validationScore\": 0.0-1.0,\n");
        prompt.append("  \"issues\": [\"list of issues found\"],\n");
        prompt.append("  \"reasoning\": \"explanation of validation decision\"\n");
        prompt.append("}\n");

        return prompt.toString();
    }

    /**
     * 라우팅 검증 프롬프트 구성
     */
    private String buildRoutingValidationPrompt(AnalyzedData analyzedData, String selectedModelId) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Please validate whether the selected AI model is appropriate for the analyzed data:\n\n");

        prompt.append("Analyzed Data:\n");
        prompt.append("- Object Type: ").append(analyzedData.getObjectType()).append("\n");
        prompt.append("- Damage Type: ").append(analyzedData.getDamageType()).append("\n");
        prompt.append("- Environment: ").append(analyzedData.getEnvironment()).append("\n");
        prompt.append("- Priority: ").append(analyzedData.getPriority()).append("\n");
        prompt.append("- Category: ").append(analyzedData.getCategory()).append("\n");

        prompt.append("\nSelected Model: ").append(selectedModelId).append("\n");

        prompt.append("\nAvailable Model Types:\n");
        prompt.append("- pothole-detection-v1: For pothole and road surface issues\n");
        prompt.append("- traffic-sign-detection: For traffic sign related problems\n");
        prompt.append("- road-damage-assessment: For general road damage assessment\n");
        prompt.append("- infrastructure-monitoring: For infrastructure monitoring\n");
        prompt.append("- general-object-detection: For general purpose detection\n");

        prompt.append("\nPlease validate the model selection and return results in JSON format:\n");
        prompt.append("{\n");
        prompt.append("  \"isValid\": true/false,\n");
        prompt.append("  \"validationScore\": 0.0-1.0,\n");
        prompt.append("  \"issues\": [\"list of issues found\"],\n");
        prompt.append("  \"reasoning\": \"explanation of routing validation decision\",\n");
        prompt.append("  \"suggestedModel\": \"alternative model if current is inappropriate\"\n");
        prompt.append("}\n");

        return prompt.toString();
    }

    /**
     * 검증 응답 파싱
     */
    private ValidationResult parseValidationResponse(String responseText, String id, String type) {
        try {
            String jsonContent = extractJsonFromContent(responseText);

            @SuppressWarnings("unchecked")
            Map<String, Object> validationData = objectMapper.readValue(jsonContent, Map.class);

            boolean isValid = (Boolean) validationData.getOrDefault("isValid", false);
            double score = ((Number) validationData.getOrDefault("validationScore", 0.0)).doubleValue();

            @SuppressWarnings("unchecked")
            List<String> issues = (List<String>) validationData.getOrDefault("issues", List.of());
            String reasoning = (String) validationData.getOrDefault("reasoning", "No reasoning provided");

            return new ValidationResult(
                    id,
                    isValid,
                    reasoning,
                    issues,
                    score,
                    System.currentTimeMillis());

        } catch (Exception e) {
            log.error("Error parsing validation response for {}: {}", type, e.getMessage(), e);

            // 기본 실패 결과 반환
            return new ValidationResult(
                    id,
                    false,
                    "Failed to parse validation response",
                    List.of("Response parsing error: " + e.getMessage()),
                    0.0,
                    System.currentTimeMillis());
        }
    }

    /**
     * 텍스트에서 JSON 부분 추출
     */
    private String extractJsonFromContent(String content) {
        int startIndex = content.indexOf("{");
        int endIndex = content.lastIndexOf("}");

        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            return content.substring(startIndex, endIndex + 1);
        }

        // JSON을 찾을 수 없으면 기본 JSON 반환
        return "{\"isValid\":false,\"validationScore\":0.0,\"issues\":[\"Could not parse validation response\"],\"reasoning\":\"Response format error\"}";
    }

    /**
     * 지능적 데이터 검증 응답 생성 (OpenRouter API 실패 시 사용)
     * 실제 분석 데이터를 기반으로 한 개선된 검증 로직
     */
    private String generateIntelligentValidationResponse(AnalyzedData analyzedData) {
        log.info("🧠 Generating intelligent validation response for: {}", analyzedData.getId());
        
        // 분석 결과의 일관성 검증
        boolean isValid = true;
        double score = 0.8; // 기본 점수
        List<String> issues = new ArrayList<>();
        String reasoning = "";
        
        // 카테고리와 손상 유형의 일치성 검증
        String category = analyzedData.getCategory();
        String damageType = analyzedData.getDamageType();
        
        // 카테고리별 일치성 검증
        if ("pothole".equals(category)) {
            if ("pothole".equals(damageType) || "crack".equals(damageType)) {
                score = Math.max(score, 0.9);
                reasoning = "포트홀 카테고리와 손상 유형이 일치합니다.";
            } else {
                issues.add("포트홀 카테고리와 손상 유형이 불일치");
                score *= 0.7;
            }
        } else if ("traffic_sign".equals(category)) {
            if ("broken".equals(damageType) || "missing".equals(damageType)) {
                score = Math.max(score, 0.85);
                reasoning = "교통표지판 카테고리와 손상 유형이 적절합니다.";
            } else {
                issues.add("교통표지판 카테고리와 손상 유형이 불일치");
                score *= 0.8;
            }
        } else if ("streetlight".equals(category)) {
            if ("broken".equals(damageType) || "off".equals(damageType)) {
                score = Math.max(score, 0.85);
                reasoning = "가로등 카테고리와 손상 유형이 적절합니다.";
            } else {
                issues.add("가로등 카테고리와 손상 유형이 불일치");
                score *= 0.8;
            }
        }
        
        // 우선순위 검증
        String priority = analyzedData.getPriority();
        if ("high".equals(priority)) {
            if ("pothole".equals(category) || "broken".equals(damageType)) {
                reasoning += " 높은 우선순위가 적절합니다.";
            } else {
                issues.add("높은 우선순위에 대한 근거 부족");
                score *= 0.9;
            }
        }
        
        // 신뢰도 검증
        Double confidence = analyzedData.getConfidence();
        if (confidence != null) {
            if (confidence < 0.5) {
                issues.add("분석 신뢰도가 낮음 (" + confidence + ")");
                score *= 0.8;
            } else if (confidence > 0.9) {
                reasoning += " 높은 분석 신뢰도를 보입니다.";
                score = Math.max(score, 0.9);
            }
        }
        
        // 키워드 일관성 검증
        List<String> keywords = analyzedData.getKeywords();
        if (keywords != null && !keywords.isEmpty()) {
            boolean hasRelevantKeywords = keywords.stream()
                .anyMatch(keyword -> 
                    keyword.contains(category) || 
                    keyword.contains(damageType) ||
                    keyword.contains("도로") ||
                    keyword.contains("손상")
                );
            if (!hasRelevantKeywords) {
                issues.add("키워드와 분석 결과의 관련성 부족");
                score *= 0.9;
            }
        }
        
        // 최종 유효성 결정
        if (score < 0.6) {
            isValid = false;
        }
        
        // JSON 응답 생성
        StringBuilder response = new StringBuilder();
        response.append("{\n");
        response.append("  \"isValid\": ").append(isValid).append(",\n");
        response.append("  \"validationScore\": ").append(String.format("%.2f", score)).append(",\n");
        response.append("  \"issues\": [");
        for (int i = 0; i < issues.size(); i++) {
            response.append("\"").append(issues.get(i)).append("\"");
            if (i < issues.size() - 1) response.append(", ");
        }
        response.append("],\n");
        response.append("  \"reasoning\": \"").append(reasoning.isEmpty() ? "분석 결과 검증 완료" : reasoning).append(" (intelligent fallback)\",\n");
        response.append("  \"recommendations\": [");
        
        // 개선 권장사항 생성
        List<String> recommendations = new ArrayList<>();
        if (confidence != null && confidence < 0.7) {
            recommendations.add("추가 이미지나 상세 설명 필요");
        }
        if (issues.size() > 2) {
            recommendations.add("신고 내용 재검토 권장");
        }
        if ("general".equals(category)) {
            recommendations.add("구체적인 문제 유형 명시 필요");
        }
        
        for (int i = 0; i < recommendations.size(); i++) {
            response.append("\"").append(recommendations.get(i)).append("\"");
            if (i < recommendations.size() - 1) response.append(", ");
        }
        
        response.append("]\n");
        response.append("}");
        
        return response.toString();
    }

    /**
     * 지능적 라우팅 검증 응답 생성 (OpenRouter API 실패 시 사용)
     */
    private String generateIntelligentRoutingValidationResponse(AnalyzedData analyzedData, String selectedModelId) {
        log.info("🎯 Generating intelligent routing validation for model: {}", selectedModelId);
        
        boolean isValid = true;
        double score = 0.8;
        List<String> issues = new ArrayList<>();
        String reasoning = "";
        
        String category = analyzedData.getCategory();
        
        // 모델 선택의 적절성 검증
        if ("pothole-detection-v1".equals(selectedModelId)) {
            if ("pothole".equals(category) || "road_damage".equals(analyzedData.getDamageType())) {
                score = 0.95;
                reasoning = "포트홀 검출 모델이 도로 손상 분석에 적합합니다.";
            } else {
                issues.add("포트홀 모델이 현재 카테고리에 부적절");
                score = 0.6;
            }
        } else if ("traffic-sign-detection".equals(selectedModelId)) {
            if ("traffic_sign".equals(category)) {
                score = 0.9;
                reasoning = "교통표지판 검출 모델이 적절합니다.";
            } else {
                issues.add("교통표지판 모델이 현재 카테고리에 부적절");
                score = 0.6;
            }
        } else if ("general-object-detection".equals(selectedModelId)) {
            score = 0.7;
            reasoning = "범용 객체 검출 모델 사용 - 기본적인 분석 가능";
            if (!"general".equals(category)) {
                issues.add("특화 모델 사용 권장");
            }
        }
        
        // 환경과 모델의 적합성
        String environment = analyzedData.getEnvironment();
        if ("urban".equals(environment) && selectedModelId.contains("highway")) {
            issues.add("도시 환경에 고속도로 모델 사용 부적절");
            score *= 0.8;
        }
        
        if (score < 0.6) {
            isValid = false;
        }
        
        // JSON 응답 생성
        StringBuilder response = new StringBuilder();
        response.append("{\n");
        response.append("  \"isValid\": ").append(isValid).append(",\n");
        response.append("  \"validationScore\": ").append(String.format("%.2f", score)).append(",\n");
        response.append("  \"selectedModel\": \"").append(selectedModelId).append("\",\n");
        response.append("  \"issues\": [");
        for (int i = 0; i < issues.size(); i++) {
            response.append("\"").append(issues.get(i)).append("\"");
            if (i < issues.size() - 1) response.append(", ");
        }
        response.append("],\n");
        response.append("  \"reasoning\": \"").append(reasoning.isEmpty() ? "모델 라우팅 검증 완료" : reasoning).append(" (intelligent fallback)\"\n");
        response.append("}");
        
        return response.toString();
    }

    /**
     * 지능적 일치성 검증 (입력 텍스트와 분석 결과 간)
     */
    private String generateIntelligentConsistencyValidation(AnalyzedData analyzedData) {
        log.info("🔍 Generating intelligent consistency validation for: {}", analyzedData.getId());
        
        boolean isValid = true;
        double score = 0.75; // 기본 점수
        List<String> issues = new ArrayList<>();
        String reasoning = "";
        
        // 입력 텍스트와 분석 결과 간의 일관성 검사
        InputData originalInput = analyzedData.getOriginalInput();
        String inputText = "";
        
        if (originalInput != null) {
            if (originalInput.getTitle() != null) {
                inputText += originalInput.getTitle() + " ";
            }
            if (originalInput.getDescription() != null) {
                inputText += originalInput.getDescription() + " ";
            }
        }
        
        inputText = inputText.toLowerCase();
        
        boolean hasRoadKeywords = inputText.contains("도로") || 
                                 inputText.contains("포트홀") || 
                                 inputText.contains("아스팔트") ||
                                 inputText.contains("인프라") ||
                                 inputText.contains("보도");
        
        boolean hasDamageKeywords = inputText.contains("손상") || 
                                   inputText.contains("파손") || 
                                   inputText.contains("균열") ||
                                   inputText.contains("훼손") ||
                                   inputText.contains("파괴");
        
        // 키워드 일치성 검증
        if (hasRoadKeywords && hasDamageKeywords) {
            score = 0.9;
            reasoning = "입력 설명과 분석된 결과가 일치합니다.";
        } else if (hasRoadKeywords && !hasDamageKeywords) {
            score = 0.7;
            reasoning = "도로/인프라는 언급되었지만 손상 관련 내용이 부족합니다.";
            issues.add("손상 관련 정보 부족");
        } else if (!hasRoadKeywords && hasDamageKeywords) {
            score = 0.6;
            reasoning = "손상이 언급되었지만 인프라 유형이 불분명합니다.";
            issues.add("객체 유형과 내용 불일치 가능성");
            isValid = false;
        } else {
            score = 0.5;
            reasoning = "입력 내용과 분석 결과 간 일치성이 낮습니다.";
            issues.add("입력 내용 불충분");
            issues.add("분석 신뢰도 낮음");
            isValid = false;
        }
        
        // 분석된 데이터와의 일치성 확인
        if (analyzedData.getObjectType() != null && analyzedData.getObjectType().equals("infrastructure") && hasRoadKeywords) {
            score += 0.05; // 보너스 점수
        }
        
        if (analyzedData.getConfidence() < 0.7) {
            score = Math.min(score, 0.7);
            issues.add("낮은 신뢰도 점수: " + analyzedData.getConfidence());
        }
        
        // 최종 유효성 결정
        isValid = score >= 0.75 && issues.size() <= 1;
        
        StringBuilder response = new StringBuilder();
        response.append("{\n");
        response.append("  \"isValid\": ").append(isValid).append(",\n");
        response.append("  \"validationScore\": ").append(String.format("%.3f", Math.min(score, 1.0))).append(",\n");
        response.append("  \"issues\": [");
        
        for (int i = 0; i < issues.size(); i++) {
            if (i > 0) response.append(", ");
            response.append("\"").append(issues.get(i)).append("\"");
        }
        
        response.append("],\n");
        response.append("  \"reasoning\": \"").append(reasoning);
        response.append(" (AI 분석 기반 검증 완료)\"\n");
        response.append("}");
        
        return response.toString();
    }

    /**
     * Mock 라우팅 검증 응답 생성 (OpenRouter API 실패 시 사용)
     */
    private String generateMockRoutingValidationResponse(AnalyzedData analyzedData, String selectedModelId) {
        // 간단한 라우팅 로직
        boolean isValidRouting = true;
        String damageType = analyzedData.getDamageType() != null ? analyzedData.getDamageType().toLowerCase() : "";
        
        if (damageType.contains("pothole") && !selectedModelId.contains("pothole")) {
            isValidRouting = false;
        }
        
        StringBuilder response = new StringBuilder();
        response.append("{\n");
        response.append("  \"isValid\": ").append(isValidRouting).append(",\n");
        response.append("  \"validationScore\": ").append(isValidRouting ? 0.9 : 0.3).append(",\n");
        response.append("  \"issues\": [");
        
        if (!isValidRouting) {
            response.append("\"Model mismatch: ").append(selectedModelId).append(" may not be optimal for ").append(damageType).append("\"");
        }
        response.append("],\n");
        response.append("  \"reasoning\": \"");
        if (isValidRouting) {
            response.append("Selected model ").append(selectedModelId).append(" is appropriate for ").append(damageType);
        } else {
            response.append("Selected model may not be optimal for the damage type");
        }
        response.append(" (mock response)\",\n");
        response.append("  \"suggestedModel\": \"").append(isValidRouting ? selectedModelId : "pothole-detection-v1").append("\"\n");
        response.append("}");
        
        return response.toString();
    }

    /**
     * 검증 결과 DTO
     */
    public static class ValidationResult {
        private String id;
        private boolean valid;
        private String validationMessage;
        private List<String> validationIssues;
        private double validationScore;
        private long timestamp;

        public ValidationResult() {
        }

        public ValidationResult(String id, boolean valid, String validationMessage,
                List<String> validationIssues, double validationScore, long timestamp) {
            this.id = id;
            this.valid = valid;
            this.validationMessage = validationMessage;
            this.validationIssues = validationIssues;
            this.validationScore = validationScore;
            this.timestamp = timestamp;
        }

        // getters and setters
        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public boolean isValid() {
            return valid;
        }

        public void setValid(boolean valid) {
            this.valid = valid;
        }

        public String getValidationMessage() {
            return validationMessage;
        }

        public void setValidationMessage(String validationMessage) {
            this.validationMessage = validationMessage;
        }

        public List<String> getValidationIssues() {
            return validationIssues;
        }

        public void setValidationIssues(List<String> validationIssues) {
            this.validationIssues = validationIssues;
        }

        public double getValidationScore() {
            return validationScore;
        }

        public void setValidationScore(double validationScore) {
            this.validationScore = validationScore;
        }

        public long getTimestamp() {
            return timestamp;
        }

        public void setTimestamp(long timestamp) {
            this.timestamp = timestamp;
        }
    }
}
