package com.jeonbuk.report.service;

import com.jeonbuk.report.dto.DocumentChunk;
import com.jeonbuk.report.dto.DocumentVector;
import com.jeonbuk.report.dto.SimilaritySearchResult;
import com.jeonbuk.report.domain.repository.DocumentVectorRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.embedding.EmbeddingClient;
import org.springframework.ai.embedding.EmbeddingOptions;
import org.springframework.ai.embedding.EmbeddingRequest;
import org.springframework.ai.embedding.EmbeddingResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

/**
 * 벡터 검색 서비스
 * 의미론적 유사도 기반 문서 검색
 */
@Slf4j
@Service
public class VectorSearchService {

    @Autowired
    private EmbeddingClient embeddingClient;

    @Autowired
    private DocumentVectorRepository vectorRepository;

    @Value("${rag.search.similarity-threshold:0.7}")
    private double similarityThreshold;

    @Value("${rag.search.max-results:10}")
    private int maxResults;

    @Value("${rag.search.rerank-enabled:true}")
    private boolean rerankEnabled;

    /**
     * 의미론적 유사도 검색
     */
    public CompletableFuture<List<DocumentChunk>> findSimilarDocuments(String query, int limitResults) {
        return findSimilarDocuments(query, limitResults, null);
    }

    public CompletableFuture<List<DocumentChunk>> findSimilarDocuments(String query, 
                                                                     int limitResults, 
                                                                     String contentTypeFilter) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("Performing similarity search for query: '{}' (limit: {})", 
                        query.substring(0, Math.min(50, query.length())), limitResults);
                
                // 1. 쿼리 임베딩 생성
                List<Float> queryEmbedding = createQueryEmbedding(query);
                
                // 2. 벡터 유사도 검색
                List<SimilaritySearchResult> searchResults = performVectorSearch(
                    queryEmbedding, limitResults * 2, contentTypeFilter); // 2배로 검색 후 필터링
                
                // 3. 결과 후처리 및 리랭킹
                List<DocumentChunk> finalResults = postProcessResults(searchResults, query, limitResults);
                
                log.info("Similarity search completed. Found {} relevant documents", finalResults.size());
                return finalResults;
                
            } catch (Exception e) {
                log.error("Similarity search failed for query: {}", query, e);
                return List.of();
            }
        });
    }

    /**
     * 하이브리드 검색: 키워드 + 의미론적 검색 결합
     */
    public CompletableFuture<List<DocumentChunk>> hybridSearch(String query, int limitResults) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                // 1. 의미론적 검색
                List<DocumentChunk> semanticResults = findSimilarDocuments(query, limitResults).get();
                
                // 2. 키워드 검색
                List<DocumentChunk> keywordResults = performKeywordSearch(query, limitResults);
                
                // 3. 결과 결합 및 중복 제거
                Map<String, DocumentChunk> combinedResults = new LinkedHashMap<>();
                
                // 의미론적 검색 결과 우선 추가 (가중치 높음)
                for (DocumentChunk chunk : semanticResults) {
                    String key = chunk.getDocumentId() + "_" + chunk.getChunkIndex();
                    combinedResults.put(key, chunk);
                }
                
                // 키워드 검색 결과 추가
                for (DocumentChunk chunk : keywordResults) {
                    String key = chunk.getDocumentId() + "_" + chunk.getChunkIndex();
                    if (!combinedResults.containsKey(key)) {
                        combinedResults.put(key, chunk);
                    }
                }
                
                List<DocumentChunk> finalResults = combinedResults.values().stream()
                    .limit(limitResults)
                    .collect(Collectors.toList());
                
                log.info("Hybrid search completed. Semantic: {}, Keyword: {}, Combined: {}", 
                        semanticResults.size(), keywordResults.size(), finalResults.size());
                
                return finalResults;
                
            } catch (Exception e) {
                log.error("Hybrid search failed for query: {}", query, e);
                return List.of();
            }
        });
    }

    /**
     * 컨텍스트 기반 검색 (AI 분석 결과에 기반한 관련 문서 검색)
     */
    public CompletableFuture<List<DocumentChunk>> findContextualDocuments(String aiAnalysisResult, 
                                                                        String category, 
                                                                        int limitResults) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                // AI 분석 결과에서 핵심 키워드 추출
                String enhancedQuery = extractKeywords(aiAnalysisResult) + " " + category;
                
                // 카테고리별 필터링하여 검색
                List<DocumentChunk> results = findSimilarDocuments(enhancedQuery, limitResults, "AI_ANALYSIS").get();
                
                // 분석 결과와 유사한 패턴의 문서 우선 선별
                results = results.stream()
                    .filter(chunk -> isRelevantToAnalysis(chunk, aiAnalysisResult, category))
                    .limit(limitResults)
                    .collect(Collectors.toList());
                
                log.info("Contextual search found {} relevant documents for category: {}", 
                        results.size(), category);
                
                return results;
                
            } catch (Exception e) {
                log.error("Contextual search failed", e);
                return List.of();
            }
        });
    }

    /**
     * 쿼리 임베딩 생성
     */
    private List<Float> createQueryEmbedding(String query) {
        try {
            EmbeddingRequest request = new EmbeddingRequest(List.of(query), EmbeddingOptions.EMPTY);
            EmbeddingResponse response = embeddingClient.call(request);
            
            return response.getResults().get(0).getOutput()
                .stream()
                .map(Double::floatValue)
                .collect(Collectors.toList());
                
        } catch (Exception e) {
            log.error("Failed to create query embedding", e);
            throw new RuntimeException("Query embedding failed", e);
        }
    }

    /**
     * 벡터 유사도 검색 수행
     */
    private List<SimilaritySearchResult> performVectorSearch(List<Float> queryEmbedding, 
                                                           int limit, 
                                                           String contentTypeFilter) {
        
        try {
            // TODO: 벡터 유사도 검색 기능 구현 필요
            // 현재는 기본적인 메타데이터 기반 검색으로 대체
            List<DocumentVector> vectors;
            if (contentTypeFilter != null) {
                vectors = vectorRepository.findByContentType(contentTypeFilter);
            } else {
                vectors = vectorRepository.findTop10ByOrderByCreatedAtDesc();
            }
            
            // 임시로 고정 유사도로 결과 반환
            return vectors.stream()
                .limit(limit)
                .map(vector -> SimilaritySearchResult.builder()
                    .documentVector(vector)
                    .similarityScore(0.8) // 임시 고정값
                    .searchMethod("METADATA_BASED")
                    .build())
                .collect(Collectors.toList());
            
        } catch (Exception e) {
            log.error("Vector search failed", e);
            return List.of();
        }
    }

    /**
     * 키워드 기반 전문 검색
     */
    private List<DocumentChunk> performKeywordSearch(String query, int limit) {
        try {
            // TODO: 키워드 검색 기능 구현 필요
            // 현재는 최신 문서들을 반환
            return vectorRepository.findTop10ByOrderByCreatedAtDesc()
                .stream()
                .limit(limit)
                .map(this::convertToDocumentChunk)
                .collect(Collectors.toList());
                
        } catch (Exception e) {
            log.error("Keyword search failed", e);
            return List.of();
        }
    }

    /**
     * 검색 결과 후처리 및 리랭킹
     */
    private List<DocumentChunk> postProcessResults(List<SimilaritySearchResult> searchResults, 
                                                 String originalQuery, 
                                                 int limitResults) {
        
        List<DocumentChunk> chunks = searchResults.stream()
            .filter(result -> result.getSimilarityScore() >= similarityThreshold)
            .map(result -> {
                DocumentChunk chunk = convertToDocumentChunk(result.getDocumentVector());
                chunk.setSimilarityScore(result.getSimilarityScore());
                return chunk;
            })
            .collect(Collectors.toList());
        
        if (rerankEnabled && chunks.size() > limitResults) {
            chunks = performReranking(chunks, originalQuery);
        }
        
        return chunks.stream()
            .limit(limitResults)
            .collect(Collectors.toList());
    }

    /**
     * 리랭킹 수행 (다양한 요소 고려)
     */
    private List<DocumentChunk> performReranking(List<DocumentChunk> chunks, String query) {
        // 1. 기본 유사도 점수
        // 2. 문서 길이 (너무 짧거나 긴 문서 패널티)
        // 3. 최신성 (최근 문서 우선)
        // 4. 키워드 매칭 점수
        
        return chunks.stream()
            .map(chunk -> {
                double rerankScore = calculateRerankScore(chunk, query);
                chunk.setRerankScore(rerankScore);
                return chunk;
            })
            .sorted(Comparator.comparingDouble(DocumentChunk::getRerankScore).reversed())
            .collect(Collectors.toList());
    }

    /**
     * 리랭킹 점수 계산
     */
    private double calculateRerankScore(DocumentChunk chunk, String query) {
        double baseScore = chunk.getSimilarityScore();
        
        // 문서 길이 점수 (적절한 길이 선호)
        double lengthScore = calculateLengthScore(chunk.getChunkText().length());
        
        // 키워드 매칭 점수
        double keywordScore = calculateKeywordMatchScore(chunk.getChunkText(), query);
        
        // 최신성 점수 (if available)
        double recencyScore = 1.0; // TODO: 문서 날짜 기반 계산
        
        // 가중 평균
        return (baseScore * 0.6) + (lengthScore * 0.2) + (keywordScore * 0.15) + (recencyScore * 0.05);
    }

    /**
     * 문서 길이 기반 점수 계산
     */
    private double calculateLengthScore(int length) {
        // 적절한 길이(200-1000자)에 높은 점수
        if (length < 50) return 0.3;
        if (length < 200) return 0.7;
        if (length <= 1000) return 1.0;
        if (length <= 2000) return 0.8;
        return 0.5;
    }

    /**
     * 키워드 매칭 점수 계산
     */
    private double calculateKeywordMatchScore(String text, String query) {
        List<String> queryKeywords = extractKeywords(query);
        String lowerText = text.toLowerCase();
        
        long matchCount = queryKeywords.stream()
            .mapToLong(keyword -> {
                String lowerKeyword = keyword.toLowerCase();
                return (lowerText.length() - lowerText.replace(lowerKeyword, "").length()) 
                       / lowerKeyword.length();
            })
            .sum();
        
        return Math.min(1.0, matchCount / (double) queryKeywords.size());
    }

    /**
     * 텍스트에서 핵심 키워드 추출
     */
    private List<String> extractKeywords(String text) {
        if (text == null || text.trim().isEmpty()) {
            return List.of();
        }
        
        // 간단한 키워드 추출 (실제로는 더 정교한 NLP 처리 필요)
        return Arrays.stream(text.split("[\\s\\p{Punct}]+"))
            .filter(word -> word.length() > 1)
            .filter(word -> !isStopWord(word))
            .distinct()
            .limit(20)
            .collect(Collectors.toList());
    }

    /**
     * 불용어 체크
     */
    private boolean isStopWord(String word) {
        Set<String> stopWords = Set.of(
            "은", "는", "이", "가", "을", "를", "에", "에서", "와", "과", "의", "도", "만", "으로", "로",
            "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by"
        );
        return stopWords.contains(word.toLowerCase());
    }

    /**
     * 분석 결과와의 관련성 체크
     */
    private boolean isRelevantToAnalysis(DocumentChunk chunk, String aiAnalysisResult, String category) {
        String chunkText = chunk.getChunkText().toLowerCase();
        String analysisLower = aiAnalysisResult.toLowerCase();
        String categoryLower = category.toLowerCase();
        
        // 카테고리 매칭
        if (chunkText.contains(categoryLower)) {
            return true;
        }
        
        // 핵심 키워드 매칭
        List<String> analysisKeywords = extractKeywords(aiAnalysisResult);
        return analysisKeywords.stream()
            .anyMatch(keyword -> chunkText.contains(keyword.toLowerCase()));
    }

    /**
     * DocumentVector를 DocumentChunk로 변환
     */
    private DocumentChunk convertToDocumentChunk(DocumentVector vector) {
        return DocumentChunk.builder()
            .documentId(vector.getDocumentId())
            .contentType(vector.getContentType())
            .chunkText(vector.getChunkText())
            .chunkIndex(vector.getChunkIndex())
            .metadata(vector.getMetadata())
            .createdAt(vector.getCreatedAt())
            .build();
    }

    /**
     * 검색 통계 정보
     */
    public CompletableFuture<Map<String, Object>> getSearchStatistics() {
        return CompletableFuture.supplyAsync(() -> {
            try {
                Map<String, Object> stats = new HashMap<>();
                
                stats.put("total_documents", vectorRepository.countDistinctDocuments());
                stats.put("total_chunks", vectorRepository.count());
                stats.put("similarity_threshold", similarityThreshold);
                stats.put("max_results", maxResults);
                stats.put("rerank_enabled", rerankEnabled);
                
                return stats;
                
            } catch (Exception e) {
                log.error("Failed to get search statistics", e);
                return Map.of("error", e.getMessage());
            }
        });
    }
}