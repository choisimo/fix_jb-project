package com.jeonbuk.report.application.service;

import com.jeonbuk.report.infrastructure.external.google.GoogleVisionOcrService;
import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterApiClient;
import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
@RequiredArgsConstructor
public class EnhancedAiAnalysisService {

    private final GoogleVisionOcrService googleVisionOcrService;
    private final OpenRouterApiClient openRouterApiClient;

    /**
     * Google Vision OCR + Gemini 2.5 Pro 통합 분석
     */
    public CompletableFuture<String> analyzeImageWithOcrAndAi(String imageUrl, String analysisPrompt) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("🔍 통합 이미지 분석 시작 - URL: {}", imageUrl);

                // 1단계: Google Vision OCR로 텍스트 추출
                String extractedText = "";
                try {
                    extractedText = googleVisionOcrService.extractTextFromImageUrl(imageUrl);
                    log.info("📝 OCR 텍스트 추출 완료 - 길이: {} 문자", extractedText.length());
                } catch (Exception e) {
                    log.warn("❌ OCR 텍스트 추출 실패, 이미지 분석만 진행: {}", e.getMessage());
                }

                // 2단계: Gemini 2.5 Pro로 통합 분석
                String combinedPrompt = createCombinedPrompt(analysisPrompt, extractedText);
                
                // 비전 모델로 이미지 + 텍스트 통합 분석
                String aiAnalysis = openRouterApiClient.analyzeImageWithUrlSync(imageUrl, combinedPrompt);
                
                log.info("✅ 통합 분석 완료");
                return combineOcrAndAiResults(extractedText, aiAnalysis);

            } catch (Exception e) {
                log.error("❌ 통합 분석 실패", e);
                
                // 실패시 기본 분석 제공
                return generateFallbackAnalysis(imageUrl, analysisPrompt);
            }
        });
    }

    /**
     * 텍스트만 있는 경우의 고급 분석
     */
    public CompletableFuture<String> analyzeTextWithGemini(String text, String analysisType) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                String systemPrompt = createTextAnalysisPrompt(analysisType);
                
                return openRouterApiClient.chatCompletionSync(Arrays.asList(
                    OpenRouterDto.Message.system(systemPrompt),
                    OpenRouterDto.Message.user("분석할 텍스트: " + text)
                ));
                
            } catch (Exception e) {
                log.error("❌ 텍스트 분석 실패", e);
                return generateFallbackTextAnalysis(text, analysisType);
            }
        });
    }

    /**
     * OCR + AI 분석을 위한 통합 프롬프트 생성
     */
    private String createCombinedPrompt(String originalPrompt, String ocrText) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("당신은 이미지와 텍스트 분석 전문가입니다.\n");
        prompt.append("다음 정보를 종합적으로 분석해주세요:\n\n");
        
        prompt.append("=== 원본 분석 요청 ===\n");
        prompt.append(originalPrompt).append("\n\n");
        
        if (ocrText != null && !ocrText.trim().isEmpty()) {
            prompt.append("=== 이미지에서 추출된 텍스트 (OCR) ===\n");
            prompt.append(ocrText).append("\n\n");
            
            prompt.append("=== 분석 지침 ===\n");
            prompt.append("1. 이미지의 시각적 내용과 추출된 텍스트를 모두 고려하여 분석\n");
            prompt.append("2. OCR 텍스트가 이미지 내용과 일치하는지 검증\n");
            prompt.append("3. 텍스트와 이미지 정보를 연관지어 종합적인 결론 도출\n");
        } else {
            prompt.append("=== 분석 지침 ===\n");
            prompt.append("1. 이미지의 시각적 내용을 중심으로 분석\n");
            prompt.append("2. 이미지에서 텍스트나 문자가 보이는 경우 그 내용도 포함하여 분석\n");
        }
        
        prompt.append("\n다음 형식으로 응답해주세요:\n");
        prompt.append("{\n");
        prompt.append("  \"visual_analysis\": \"이미지 시각적 분석 내용\",\n");
        prompt.append("  \"text_analysis\": \"추출된 텍스트 분석 내용\",\n");
        prompt.append("  \"integrated_conclusion\": \"통합 분석 결론\",\n");
        prompt.append("  \"confidence_score\": 0.95,\n");
        prompt.append("  \"recommendations\": [\"권장사항1\", \"권장사항2\"]\n");
        prompt.append("}");
        
        return prompt.toString();
    }

    /**
     * 텍스트 분석을 위한 프롬프트 생성
     */
    private String createTextAnalysisPrompt(String analysisType) {
        return switch (analysisType.toLowerCase()) {
            case "sentiment" -> """
                당신은 감정 분석 전문가입니다.
                주어진 텍스트의 감정을 분석하여 다음 JSON 형태로 응답해주세요:
                {
                  "sentiment": "positive|negative|neutral",
                  "confidence": 0.95,
                  "emotions": ["기쁨", "분노", "슬픔", "두려움", "놀라움"],
                  "key_phrases": ["핵심 구문들"],
                  "summary": "감정 분석 요약"
                }
                """;
            case "category" -> """
                당신은 텍스트 분류 전문가입니다.
                주어진 텍스트를 분석하여 적절한 카테고리로 분류해주세요:
                {
                  "primary_category": "주요 카테고리",
                  "secondary_categories": ["보조 카테고리들"],
                  "confidence": 0.95,
                  "keywords": ["핵심 키워드들"],
                  "summary": "분류 근거 설명"
                }
                """;
            case "risk_assessment" -> """
                당신은 위험도 평가 전문가입니다.
                주어진 텍스트의 위험도를 평가해주세요:
                {
                  "risk_level": "high|medium|low",
                  "risk_factors": ["위험 요소들"],
                  "urgency": "immediate|soon|routine",
                  "recommended_actions": ["권장 조치사항들"],
                  "confidence": 0.95
                }
                """;
            default -> """
                당신은 종합 텍스트 분석 전문가입니다.
                주어진 텍스트를 종합적으로 분석해주세요:
                {
                  "main_topics": ["주요 주제들"],
                  "sentiment": "positive|negative|neutral",
                  "key_information": ["핵심 정보들"],
                  "summary": "분석 요약",
                  "confidence": 0.95
                }
                """;
        };
    }

    /**
     * OCR과 AI 분석 결과 통합
     */
    private String combineOcrAndAiResults(String ocrText, String aiAnalysis) {
        StringBuilder result = new StringBuilder();
        
        result.append("=== 통합 이미지 분석 결과 ===\n\n");
        
        if (ocrText != null && !ocrText.trim().isEmpty()) {
            result.append("📝 추출된 텍스트 (OCR):\n");
            result.append(ocrText).append("\n\n");
        }
        
        result.append("🤖 AI 분석 결과:\n");
        result.append(aiAnalysis).append("\n\n");
        
        result.append("✅ 분석 완료 시각: ").append(java.time.LocalDateTime.now());
        
        return result.toString();
    }

    /**
     * 실패시 기본 분석 제공
     */
    private String generateFallbackAnalysis(String imageUrl, String analysisPrompt) {
        return String.format("""
            {
              "status": "fallback_analysis",
              "message": "고급 AI 분석이 일시적으로 사용할 수 없어 기본 분석을 제공합니다.",
              "image_url": "%s",
              "analysis_request": "%s",
              "basic_analysis": "이미지가 제공되었으나 상세 분석을 위해서는 AI 서비스가 필요합니다.",
              "recommendations": [
                "나중에 다시 시도해보시기 바랍니다.",
                "API 키 설정을 확인해주세요.",
                "네트워크 연결 상태를 확인해주세요."
              ],
              "timestamp": "%s"
            }
            """, imageUrl, analysisPrompt, java.time.LocalDateTime.now());
    }

    /**
     * 텍스트 분석 실패시 기본 분석 제공
     */
    private String generateFallbackTextAnalysis(String text, String analysisType) {
        return String.format("""
            {
              "status": "fallback_analysis",
              "analysis_type": "%s",
              "message": "고급 AI 분석이 일시적으로 사용할 수 없어 기본 분석을 제공합니다.",
              "text_length": %d,
              "basic_analysis": "텍스트가 제공되었으나 상세 분석을 위해서는 AI 서비스가 필요합니다.",
              "timestamp": "%s"
            }
            """, analysisType, text.length(), java.time.LocalDateTime.now());
    }

    /**
     * 서비스 상태 확인
     */
    public boolean isServiceAvailable() {
        boolean ocrAvailable = googleVisionOcrService.isConfigured();
        boolean aiAvailable = openRouterApiClient.isApiAvailable();
        
        log.info("서비스 상태 - OCR: {}, AI: {}", ocrAvailable, aiAvailable);
        
        return ocrAvailable || aiAvailable; // 둘 중 하나라도 사용 가능하면 OK
    }
}