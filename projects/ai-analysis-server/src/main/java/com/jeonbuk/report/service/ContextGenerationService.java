package com.jeonbuk.report.service;

import com.jeonbuk.report.dto.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * RAG 시스템용 컨텍스트 생성 서비스
 */
@Slf4j
@Service
public class ContextGenerationService {

    @Value("${rag.context.max-tokens:2000}")
    private int maxContextTokens;

    @Value("${rag.context.chunk-separator:---}")
    private String chunkSeparator;

    @Value("${rag.context.include-metadata:true}")
    private boolean includeMetadata;

    /**
     * AI 분석 결과와 관련 문서를 기반으로 향상된 컨텍스트 생성
     */
    public String buildEnrichedContext(AIAnalysisResponse aiResult, 
                                     List<DocumentChunk> relevantDocs, 
                                     int maxTokens) {
        
        StringBuilder contextBuilder = new StringBuilder();
        int currentTokens = 0;
        
        // 1. AI 분석 결과 요약
        String aiSummary = createAISummary(aiResult);
        currentTokens += estimateTokenCount(aiSummary);
        contextBuilder.append("=== 현재 분석 요약 ===\n");
        contextBuilder.append(aiSummary).append("\n\n");
        
        // 2. 관련 문서 컨텍스트 추가
        contextBuilder.append("=== 관련 지식 및 유사 사례 ===\n");
        
        for (int i = 0; i < relevantDocs.size() && currentTokens < maxTokens; i++) {
            DocumentChunk chunk = relevantDocs.get(i);
            
            String chunkContext = buildChunkContext(chunk, i + 1);
            int chunkTokens = estimateTokenCount(chunkContext);
            
            // 토큰 제한 확인
            if (currentTokens + chunkTokens > maxTokens) {
                // 남은 공간에 맞게 청크 텍스트 줄이기
                int remainingTokens = maxTokens - currentTokens - 100; // 마진 확보
                if (remainingTokens > 50) {
                    String truncatedChunk = truncateToTokenLimit(chunk.getChunkText(), remainingTokens);
                    contextBuilder.append(String.format("[문서 %d] %s\n", i + 1, truncatedChunk));
                }
                break;
            }
            
            contextBuilder.append(chunkContext);
            currentTokens += chunkTokens;
        }
        
        // 3. 컨텍스트 품질 향상
        return enhanceContextQuality(contextBuilder.toString(), aiResult);
    }

    /**
     * 질의응답용 컨텍스트 생성
     */
    public String buildQAContext(String question, String additionalContext, List<DocumentChunk> relevantDocs) {
        StringBuilder contextBuilder = new StringBuilder();
        
        // 질문 컨텍스트
        if (additionalContext != null && !additionalContext.trim().isEmpty()) {
            contextBuilder.append("=== 추가 컨텍스트 ===\n");
            contextBuilder.append(additionalContext).append("\n\n");
        }
        
        // 관련 문서 정보
        if (!relevantDocs.isEmpty()) {
            contextBuilder.append("=== 관련 정보 ===\n");
            
            for (int i = 0; i < Math.min(5, relevantDocs.size()); i++) {
                DocumentChunk chunk = relevantDocs.get(i);
                
                contextBuilder.append(String.format("[참고자료 %d]\n", i + 1));
                if (includeMetadata && chunk.getSimilarityScore() != null) {
                    contextBuilder.append(String.format("(관련도: %s)\n", chunk.getSimilarityPercentage()));
                }
                contextBuilder.append(chunk.getChunkText()).append("\n\n");
            }
        }
        
        return contextBuilder.toString();
    }

    /**
     * 도메인별 특화 컨텍스트 생성
     */
    public String buildDomainSpecificContext(String domain, List<DocumentChunk> relevantDocs) {
        StringBuilder contextBuilder = new StringBuilder();
        
        // 도메인별 소개
        contextBuilder.append(getDomainIntroduction(domain)).append("\n\n");
        
        // 도메인 관련 문서만 필터링
        List<DocumentChunk> domainDocs = relevantDocs.stream()
            .filter(chunk -> isDomainRelevant(chunk, domain))
            .collect(Collectors.toList());
        
        // 도메인 특화 컨텍스트 구성
        for (int i = 0; i < domainDocs.size(); i++) {
            DocumentChunk chunk = domainDocs.get(i);
            contextBuilder.append(String.format("[%s 관련 정보 %d]\n", 
                getDomainKoreanName(domain), i + 1));
            contextBuilder.append(chunk.getChunkText()).append("\n\n");
        }
        
        return contextBuilder.toString();
    }

    /**
     * AI 분석 결과 요약 생성
     */
    private String createAISummary(AIAnalysisResponse aiResult) {
        StringBuilder summary = new StringBuilder();
        
        // OCR 결과 요약
        if (aiResult.getOcrText() != null && !aiResult.getOcrText().trim().isEmpty()) {
            summary.append("추출된 텍스트: ")
                   .append(summarizeText(aiResult.getOcrText(), 100))
                   .append("\n");
        }
        
        // 탐지된 객체
        if (!aiResult.getDetectedObjects().isEmpty()) {
            summary.append("탐지된 객체: ")
                   .append(String.join(", ", aiResult.getDetectedObjects()))
                   .append("\n");
        }
        
        // 분석 결과 요약
        summary.append("기본 분석: ")
               .append(summarizeText(aiResult.getAnalysisResult(), 200))
               .append("\n");
        
        // 신뢰도 정보
        summary.append(String.format("분석 신뢰도: %.1f%%", aiResult.getConfidence() * 100));
        
        return summary.toString();
    }

    /**
     * 개별 청크 컨텍스트 생성
     */
    private String buildChunkContext(DocumentChunk chunk, int index) {
        StringBuilder chunkContext = new StringBuilder();
        
        chunkContext.append(String.format("[문서 %d", index));
        
        // 메타데이터 포함 (선택적)
        if (includeMetadata) {
            if (chunk.getSimilarityScore() != null) {
                chunkContext.append(String.format(" - 관련도: %s", chunk.getSimilarityPercentage()));
            }
            if (chunk.getContentType() != null) {
                chunkContext.append(String.format(" - 유형: %s", chunk.getKoreanContentType()));
            }
        }
        
        chunkContext.append("]\n");
        chunkContext.append(chunk.getChunkText()).append("\n");
        chunkContext.append(chunkSeparator).append("\n");
        
        return chunkContext.toString();
    }

    /**
     * 컨텍스트 품질 향상
     */
    private String enhanceContextQuality(String rawContext, AIAnalysisResponse aiResult) {
        StringBuilder enhancedContext = new StringBuilder();
        
        // 컨텍스트 우선순위 재정렬
        String[] sections = rawContext.split("===");
        List<String> prioritizedSections = prioritizeSections(Arrays.asList(sections), aiResult);
        
        for (String section : prioritizedSections) {
            if (!section.trim().isEmpty()) {
                enhancedContext.append("===").append(section);
            }
        }
        
        // 중복 정보 제거
        return removeDuplicateInformation(enhancedContext.toString());
    }

    /**
     * 섹션 우선순위 정렬
     */
    private List<String> prioritizeSections(List<String> sections, AIAnalysisResponse aiResult) {
        List<String> prioritized = new ArrayList<>(sections);
        
        // 현재 분석과 관련성이 높은 섹션을 앞으로 이동
        prioritized.sort((a, b) -> {
            int scoreA = calculateSectionRelevance(a, aiResult);
            int scoreB = calculateSectionRelevance(b, aiResult);
            return Integer.compare(scoreB, scoreA); // 내림차순
        });
        
        return prioritized;
    }

    /**
     * 섹션 관련성 점수 계산
     */
    private int calculateSectionRelevance(String section, AIAnalysisResponse aiResult) {
        int score = 0;
        String lowerSection = section.toLowerCase();
        
        // 탐지된 객체와의 매칭
        for (String object : aiResult.getDetectedObjects()) {
            if (lowerSection.contains(object.toLowerCase())) {
                score += 10;
            }
        }
        
        // OCR 텍스트와의 키워드 매칭
        if (aiResult.getOcrText() != null) {
            String[] ocrWords = aiResult.getOcrText().toLowerCase().split("\\s+");
            for (String word : ocrWords) {
                if (word.length() > 2 && lowerSection.contains(word)) {
                    score += 2;
                }
            }
        }
        
        return score;
    }

    /**
     * 중복 정보 제거
     */
    private String removeDuplicateInformation(String context) {
        // 간단한 중복 문장 제거 (실제로는 더 정교한 알고리즘 필요)
        String[] sentences = context.split("\\.");
        Set<String> uniqueSentences = new LinkedHashSet<>();
        
        for (String sentence : sentences) {
            String normalized = sentence.trim().toLowerCase();
            if (!normalized.isEmpty() && normalized.length() > 10) {
                // 유사한 문장이 이미 있는지 확인
                boolean isDuplicate = uniqueSentences.stream()
                    .anyMatch(existing -> calculateSimilarity(existing.toLowerCase(), normalized) > 0.8);
                
                if (!isDuplicate) {
                    uniqueSentences.add(sentence.trim());
                }
            }
        }
        
        return String.join(". ", uniqueSentences);
    }

    /**
     * 텍스트 요약 (토큰 제한)
     */
    private String summarizeText(String text, int maxTokens) {
        if (text == null || text.trim().isEmpty()) {
            return "";
        }
        
        int estimatedTokens = estimateTokenCount(text);
        if (estimatedTokens <= maxTokens) {
            return text;
        }
        
        // 문장 단위로 자르기
        String[] sentences = text.split("[.!?]");
        StringBuilder summary = new StringBuilder();
        int currentTokens = 0;
        
        for (String sentence : sentences) {
            int sentenceTokens = estimateTokenCount(sentence);
            if (currentTokens + sentenceTokens > maxTokens) {
                break;
            }
            summary.append(sentence.trim()).append(". ");
            currentTokens += sentenceTokens;
        }
        
        return summary.toString().trim();
    }

    /**
     * 토큰 제한에 맞게 텍스트 절단
     */
    private String truncateToTokenLimit(String text, int maxTokens) {
        if (estimateTokenCount(text) <= maxTokens) {
            return text;
        }
        
        // 단어 단위로 절단
        String[] words = text.split("\\s+");
        StringBuilder truncated = new StringBuilder();
        int currentTokens = 0;
        
        for (String word : words) {
            int wordTokens = estimateTokenCount(word);
            if (currentTokens + wordTokens > maxTokens - 10) { // 마진 확보
                truncated.append("...");
                break;
            }
            truncated.append(word).append(" ");
            currentTokens += wordTokens;
        }
        
        return truncated.toString().trim();
    }

    /**
     * 토큰 수 추정 (간단한 휴리스틱)
     */
    private int estimateTokenCount(String text) {
        if (text == null || text.isEmpty()) {
            return 0;
        }
        
        // 한글: 1글자 ≈ 1토큰, 영어: 4글자 ≈ 1토큰
        int koreanChars = text.replaceAll("[^\\p{IsHangul}]", "").length();
        int englishChars = text.replaceAll("[^a-zA-Z]", "").length();
        int otherChars = text.length() - koreanChars - englishChars;
        
        return koreanChars + (englishChars / 4) + (otherChars / 2);
    }

    /**
     * 도메인 소개 텍스트 반환
     */
    private String getDomainIntroduction(String domain) {
        return switch (domain.toUpperCase()) {
            case "ROAD_DAMAGE" -> "도로 손상 관련 신고 분석을 위한 전문 지식:";
            case "WASTE_MANAGEMENT" -> "폐기물 및 환경 관리 관련 신고 분석을 위한 전문 지식:";
            case "VANDALISM" -> "기물 파손 및 낙서 관련 신고 분석을 위한 전문 지식:";
            case "STREET_LIGHTING" -> "가로등 및 조명 시설 관련 신고 분석을 위한 전문 지식:";
            default -> "일반 시설 관리 관련 신고 분석을 위한 전문 지식:";
        };
    }

    /**
     * 도메인 한국어 이름 반환
     */
    private String getDomainKoreanName(String domain) {
        return switch (domain.toUpperCase()) {
            case "ROAD_DAMAGE" -> "도로 손상";
            case "WASTE_MANAGEMENT" -> "폐기물 관리";
            case "VANDALISM" -> "기물 파손";
            case "STREET_LIGHTING" -> "가로등 시설";
            default -> "일반 시설";
        };
    }

    /**
     * 도메인 관련성 확인
     */
    private boolean isDomainRelevant(DocumentChunk chunk, String domain) {
        String chunkText = chunk.getChunkText().toLowerCase();
        String domainLower = domain.toLowerCase();
        
        // 메타데이터 확인
        if (chunk.getMetadata() != null) {
            Object category = chunk.getMetadata().get("category");
            if (category != null && category.toString().toLowerCase().contains(domainLower)) {
                return true;
            }
        }
        
        // 텍스트 내용 확인
        return switch (domain.toUpperCase()) {
            case "ROAD_DAMAGE" -> chunkText.contains("도로") || chunkText.contains("포트홀") || 
                                chunkText.contains("균열") || chunkText.contains("포장");
            case "WASTE_MANAGEMENT" -> chunkText.contains("쓰레기") || chunkText.contains("폐기물") || 
                                     chunkText.contains("청소");
            case "VANDALISM" -> chunkText.contains("낙서") || chunkText.contains("파손") || 
                              chunkText.contains("기물");
            case "STREET_LIGHTING" -> chunkText.contains("가로등") || chunkText.contains("조명") || 
                                    chunkText.contains("전등");
            default -> true;
        };
    }

    /**
     * 문자열 유사도 계산 (간단한 Jaccard 유사도)
     */
    private double calculateSimilarity(String text1, String text2) {
        Set<String> words1 = new HashSet<>(Arrays.asList(text1.split("\\s+")));
        Set<String> words2 = new HashSet<>(Arrays.asList(text2.split("\\s+")));
        
        Set<String> intersection = new HashSet<>(words1);
        intersection.retainAll(words2);
        
        Set<String> union = new HashSet<>(words1);
        union.addAll(words2);
        
        return union.isEmpty() ? 0.0 : (double) intersection.size() / union.size();
    }
}