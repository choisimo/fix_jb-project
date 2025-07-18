package com.jeonbuk.report.service;

import com.jeonbuk.report.dto.*;
import com.jeonbuk.report.infrastructure.external.openrouter.OpenRouterApiClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

/**
 * RAG (Retrieval-Augmented Generation) 오케스트레이션 서비스
 * AI 분석 결과와 지식 기반을 결합하여 향상된 분석 제공
 */
@Slf4j
@Service
public class RagOrchestrationService {

    @Autowired
    private VectorSearchService vectorSearchService;

    @Autowired
    private DocumentIndexingService documentIndexingService;

    @Autowired
    private ContextGenerationService contextGenerationService;

    @Autowired
    private OpenRouterApiClient openRouterApiClient;

    @Value("${rag.context.max-chunks:5}")
    private int maxContextChunks;

    @Value("${rag.context.max-tokens:2000}")
    private int maxContextTokens;

    @Value("${rag.analysis.include-sources:true}")
    private boolean includeSources;

    /**
     * RAG 기반 AI 분석 수행
     */
    public CompletableFuture<RagAnalysisResult> analyzeWithContext(String query, 
                                                                 AIAnalysisResponse aiResult) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("Starting RAG analysis for query: '{}'", 
                        query.substring(0, Math.min(50, query.length())));
                
                long startTime = System.currentTimeMillis();
                
                // 1. 관련 문서 검색
                List<DocumentChunk> relevantDocs = findRelevantDocuments(query, aiResult).get();
                
                // 2. 컨텍스트 구성
                String enrichedContext = contextGenerationService
                    .buildEnrichedContext(aiResult, relevantDocs, maxContextTokens);
                
                // 3. RAG 프롬프트 생성
                RagPrompt ragPrompt = createRagPrompt(query, aiResult, enrichedContext, relevantDocs);
                
                // 4. LLM 호출하여 향상된 분석 생성
                String enhancedAnalysis = generateEnhancedAnalysis(ragPrompt).get();
                
                // 5. 결과 구성
                long processingTime = System.currentTimeMillis() - startTime;
                RagAnalysisResult result = buildAnalysisResult(
                    query, aiResult, enhancedAnalysis, relevantDocs, processingTime);
                
                log.info("RAG analysis completed in {}ms with {} context documents", 
                        processingTime, relevantDocs.size());
                
                return result;
                
            } catch (Exception e) {
                log.error("RAG analysis failed for query: {}", query, e);
                return createFallbackResult(query, aiResult, e);
            }
        });
    }

    /**
     * 배치 RAG 분석 (여러 신고서 동시 처리)
     */
    public CompletableFuture<Map<String, RagAnalysisResult>> batchAnalyzeWithContext(
            Map<String, AIAnalysisResponse> analysisRequests) {
        
        return CompletableFuture.supplyAsync(() -> {
            Map<String, RagAnalysisResult> results = new HashMap<>();
            
            List<CompletableFuture<Void>> futures = analysisRequests.entrySet().stream()
                .map(entry -> {
                    String reportId = entry.getKey();
                    AIAnalysisResponse aiResult = entry.getValue();
                    String query = extractQueryFromAnalysis(aiResult);
                    
                    return analyzeWithContext(query, aiResult)
                        .thenAccept(result -> results.put(reportId, result));
                })
                .toList();
            
            // 모든 분석 완료 대기
            CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();
            
            log.info("Batch RAG analysis completed for {} reports", results.size());
            return results;
        });
    }

    /**
     * 실시간 컨텍스트 기반 질의응답
     */
    public CompletableFuture<RagQAResult> answerQuestion(String question, String context) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("Processing Q&A request: '{}'", 
                        question.substring(0, Math.min(30, question.length())));
                
                // 1. 관련 문서 검색
                List<DocumentChunk> relevantDocs = vectorSearchService
                    .hybridSearch(question, maxContextChunks).get();
                
                // 2. 질문에 대한 컨텍스트 구성
                String qaContext = contextGenerationService
                    .buildQAContext(question, context, relevantDocs);
                
                // 3. 질의응답 프롬프트 생성
                RagPrompt qaPrompt = createQAPrompt(question, qaContext, relevantDocs);
                
                // 4. 답변 생성
                String answer = generateAnswer(qaPrompt).get();
                
                // 5. 결과 구성
                return RagQAResult.builder()
                    .question(question)
                    .answer(answer)
                    .contextSources(relevantDocs)
                    .confidence(calculateAnswerConfidence(relevantDocs))
                    .timestamp(LocalDateTime.now())
                    .build();
                
            } catch (Exception e) {
                log.error("Q&A processing failed for question: {}", question, e);
                return RagQAResult.builder()
                    .question(question)
                    .answer("죄송합니다. 현재 답변을 생성할 수 없습니다.")
                    .confidence(0.0f)
                    .timestamp(LocalDateTime.now())
                    .build();
            }
        });
    }

    /**
     * 관련 문서 검색 (하이브리드 전략)
     */
    private CompletableFuture<List<DocumentChunk>> findRelevantDocuments(String query, 
                                                                       AIAnalysisResponse aiResult) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                // 1. AI 분석 결과에서 카테고리 추출
                String category = extractCategoryFromAnalysis(aiResult);
                
                // 2. 컨텍스트 기반 검색 (우선순위 1)
                CompletableFuture<List<DocumentChunk>> contextualSearch = 
                    vectorSearchService.findContextualDocuments(
                        aiResult.getAnalysisResult(), category, maxContextChunks);
                
                // 3. 하이브리드 검색 (우선순위 2)
                CompletableFuture<List<DocumentChunk>> hybridSearch = 
                    vectorSearchService.hybridSearch(query, maxContextChunks);
                
                // 4. 결과 통합 및 중복 제거
                List<DocumentChunk> contextualResults = contextualSearch.get();
                List<DocumentChunk> hybridResults = hybridSearch.get();
                
                return mergeAndDeduplicate(contextualResults, hybridResults, maxContextChunks);
                
            } catch (Exception e) {
                log.error("Failed to find relevant documents", e);
                return List.of();
            }
        });
    }

    /**
     * RAG 프롬프트 생성
     */
    private RagPrompt createRagPrompt(String query, 
                                    AIAnalysisResponse aiResult, 
                                    String enrichedContext, 
                                    List<DocumentChunk> sources) {
        
        StringBuilder promptBuilder = new StringBuilder();
        
        // 시스템 프롬프트
        promptBuilder.append("당신은 전북 신고 플랫폼의 AI 분석 전문가입니다.\n");
        promptBuilder.append("주어진 AI 분석 결과와 관련 지식을 바탕으로 종합적인 분석을 제공해주세요.\n\n");
        
        // 원본 AI 분석 결과
        promptBuilder.append("=== 원본 AI 분석 결과 ===\n");
        promptBuilder.append("OCR 텍스트: ").append(aiResult.getOcrText()).append("\n");
        promptBuilder.append("객체 탐지: ").append(aiResult.getDetectedObjects()).append("\n");
        promptBuilder.append("분석 결과: ").append(aiResult.getAnalysisResult()).append("\n\n");
        
        // 관련 지식 컨텍스트
        promptBuilder.append("=== 관련 지식 및 유사 사례 ===\n");
        promptBuilder.append(enrichedContext).append("\n\n");
        
        // 분석 요청
        promptBuilder.append("=== 분석 요청 ===\n");
        promptBuilder.append(query).append("\n\n");
        
        // 출력 지침
        promptBuilder.append("=== 출력 지침 ===\n");
        promptBuilder.append("1. 원본 AI 분석을 바탕으로 더 상세하고 정확한 분석을 제공\n");
        promptBuilder.append("2. 관련 지식과 유사 사례를 참조하여 컨텍스트 풍부한 설명\n");
        promptBuilder.append("3. 신고 유형, 심각도, 대응 방안을 구체적으로 제시\n");
        promptBuilder.append("4. 근거와 출처를 명확히 표시\n");
        
        return RagPrompt.builder()
            .systemPrompt(promptBuilder.toString())
            .originalQuery(query)
            .aiAnalysisResult(aiResult)
            .enrichedContext(enrichedContext)
            .contextSources(sources)
            .build();
    }

    /**
     * 질의응답용 프롬프트 생성
     */
    private RagPrompt createQAPrompt(String question, String context, List<DocumentChunk> sources) {
        StringBuilder promptBuilder = new StringBuilder();
        
        promptBuilder.append("주어진 컨텍스트를 바탕으로 질문에 정확하고 도움이 되는 답변을 제공해주세요.\n\n");
        promptBuilder.append("질문: ").append(question).append("\n\n");
        promptBuilder.append("관련 정보:\n").append(context).append("\n\n");
        promptBuilder.append("답변은 한국어로, 정확하고 이해하기 쉽게 작성해주세요.");
        
        return RagPrompt.builder()
            .systemPrompt(promptBuilder.toString())
            .originalQuery(question)
            .enrichedContext(context)
            .contextSources(sources)
            .build();
    }

    /**
     * 향상된 분석 생성 (LLM 호출)
     */
    private CompletableFuture<String> generateEnhancedAnalysis(RagPrompt ragPrompt) {
        try {
            // OpenRouter API를 통해 고급 LLM 모델 호출
            return openRouterApiClient.generateWithContext(ragPrompt.getSystemPrompt());
            
        } catch (Exception e) {
            log.error("Failed to generate enhanced analysis", e);
            return CompletableFuture.completedFuture("분석 생성 중 오류가 발생했습니다.");
        }
    }

    /**
     * 답변 생성
     */
    private CompletableFuture<String> generateAnswer(RagPrompt qaPrompt) {
        return generateEnhancedAnalysis(qaPrompt);
    }

    /**
     * 최종 분석 결과 구성
     */
    private RagAnalysisResult buildAnalysisResult(String query, 
                                                AIAnalysisResponse originalResult, 
                                                String enhancedAnalysis, 
                                                List<DocumentChunk> sources, 
                                                long processingTime) {
        
        return RagAnalysisResult.builder()
            .originalQuery(query)
            .originalAnalysis(originalResult)
            .enhancedAnalysis(enhancedAnalysis)
            .contextSources(includeSources ? sources : List.of())
            .confidence(calculateAnalysisConfidence(originalResult, sources))
            .processingTime(processingTime)
            .timestamp(LocalDateTime.now())
            .metadata(createResultMetadata(sources))
            .build();
    }

    /**
     * 폴백 결과 생성 (오류 시)
     */
    private RagAnalysisResult createFallbackResult(String query, 
                                                 AIAnalysisResponse originalResult, 
                                                 Exception error) {
        
        return RagAnalysisResult.builder()
            .originalQuery(query)
            .originalAnalysis(originalResult)
            .enhancedAnalysis(originalResult.getAnalysisResult() + "\n\n[참고: 추가 컨텍스트 분석을 수행할 수 없었습니다.]")
            .contextSources(List.of())
            .confidence(0.5f)
            .processingTime(0L)
            .timestamp(LocalDateTime.now())
            .error(error.getMessage())
            .build();
    }

    /**
     * 결과 병합 및 중복 제거
     */
    private List<DocumentChunk> mergeAndDeduplicate(List<DocumentChunk> list1, 
                                                   List<DocumentChunk> list2, 
                                                   int maxResults) {
        
        Map<String, DocumentChunk> uniqueChunks = new LinkedHashMap<>();
        
        // 첫 번째 리스트 우선 추가
        for (DocumentChunk chunk : list1) {
            String key = chunk.getDocumentId() + "_" + chunk.getChunkIndex();
            uniqueChunks.put(key, chunk);
        }
        
        // 두 번째 리스트 추가 (중복 제외)
        for (DocumentChunk chunk : list2) {
            String key = chunk.getDocumentId() + "_" + chunk.getChunkIndex();
            if (!uniqueChunks.containsKey(key)) {
                uniqueChunks.put(key, chunk);
            }
        }
        
        return uniqueChunks.values().stream()
            .limit(maxResults)
            .collect(Collectors.toList());
    }

    /**
     * AI 분석에서 카테고리 추출
     */
    private String extractCategoryFromAnalysis(AIAnalysisResponse aiResult) {
        String analysisText = aiResult.getAnalysisResult().toLowerCase();
        
        if (analysisText.contains("포트홀") || analysisText.contains("도로") || analysisText.contains("균열")) {
            return "ROAD_DAMAGE";
        } else if (analysisText.contains("쓰레기") || analysisText.contains("폐기물")) {
            return "WASTE_MANAGEMENT";
        } else if (analysisText.contains("낙서") || analysisText.contains("파손")) {
            return "VANDALISM";
        } else if (analysisText.contains("가로등") || analysisText.contains("조명")) {
            return "STREET_LIGHTING";
        } else {
            return "GENERAL_INFRASTRUCTURE";
        }
    }

    /**
     * AI 분석에서 쿼리 추출
     */
    private String extractQueryFromAnalysis(AIAnalysisResponse aiResult) {
        return aiResult.getAnalysisResult() + " " + 
               String.join(" ", aiResult.getDetectedObjects());
    }

    /**
     * 분석 신뢰도 계산
     */
    private float calculateAnalysisConfidence(AIAnalysisResponse originalResult, 
                                            List<DocumentChunk> sources) {
        
        float baseConfidence = originalResult.getConfidence();
        float contextBonus = Math.min(0.2f, sources.size() * 0.05f);
        
        return Math.min(1.0f, baseConfidence + contextBonus);
    }

    /**
     * 답변 신뢰도 계산
     */
    private float calculateAnswerConfidence(List<DocumentChunk> sources) {
        if (sources.isEmpty()) {
            return 0.3f;
        }
        
        float avgSimilarity = (float) sources.stream()
            .mapToDouble(chunk -> chunk.getSimilarityScore() != null ? chunk.getSimilarityScore() : 0.7)
            .average()
            .orElse(0.7);
        
        return Math.min(1.0f, avgSimilarity + (sources.size() * 0.05f));
    }

    /**
     * 결과 메타데이터 생성
     */
    private Map<String, Object> createResultMetadata(List<DocumentChunk> sources) {
        Map<String, Object> metadata = new HashMap<>();
        
        metadata.put("total_sources", sources.size());
        metadata.put("source_types", sources.stream()
            .map(DocumentChunk::getContentType)
            .distinct()
            .collect(Collectors.toList()));
        metadata.put("avg_similarity", sources.stream()
            .mapToDouble(chunk -> chunk.getSimilarityScore() != null ? chunk.getSimilarityScore() : 0.0)
            .average()
            .orElse(0.0));
        
        return metadata;
    }

    /**
     * RAG 시스템 상태 확인
     */
    public CompletableFuture<Map<String, Object>> getSystemStatus() {
        return CompletableFuture.supplyAsync(() -> {
            Map<String, Object> status = new HashMap<>();
            
            try {
                // 인덱싱 상태
                Map<String, Object> indexingStatus = documentIndexingService.getIndexingStatus().get();
                status.put("indexing", indexingStatus);
                
                // 검색 통계
                Map<String, Object> searchStats = vectorSearchService.getSearchStatistics().get();
                status.put("search", searchStats);
                
                // 설정 정보
                status.put("configuration", Map.of(
                    "max_context_chunks", maxContextChunks,
                    "max_context_tokens", maxContextTokens,
                    "include_sources", includeSources
                ));
                
                status.put("status", "healthy");
                status.put("timestamp", LocalDateTime.now());
                
            } catch (Exception e) {
                log.error("Failed to get RAG system status", e);
                status.put("status", "error");
                status.put("error", e.getMessage());
            }
            
            return status;
        });
    }
}