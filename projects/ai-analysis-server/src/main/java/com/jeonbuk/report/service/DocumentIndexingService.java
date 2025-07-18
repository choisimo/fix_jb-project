package com.jeonbuk.report.service;

import com.jeonbuk.report.dto.DocumentChunk;
import com.jeonbuk.report.dto.DocumentVector;
import com.jeonbuk.report.domain.repository.DocumentVectorRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.embedding.EmbeddingClient;
import org.springframework.ai.embedding.EmbeddingOptions;
import org.springframework.ai.embedding.EmbeddingRequest;
import org.springframework.ai.embedding.EmbeddingResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.regex.Pattern;

/**
 * 문서 인덱싱 서비스
 * 텍스트 문서를 청킹하고 벡터화하여 저장
 */
@Slf4j
@Service
public class DocumentIndexingService {

    @Autowired
    private EmbeddingClient embeddingClient;

    @Autowired
    private DocumentVectorRepository vectorRepository;

    @Value("${rag.chunking.max-tokens:512}")
    private int maxTokensPerChunk;

    @Value("${rag.chunking.overlap-tokens:50}")
    private int overlapTokens;

    @Value("${rag.indexing.batch-size:10}")
    private int batchSize;

    // 문장 구분을 위한 정규표현식
    private static final Pattern SENTENCE_PATTERN = Pattern.compile("[.!?]\\s+");
    private static final Pattern PARAGRAPH_PATTERN = Pattern.compile("\\n\\s*\\n");

    /**
     * 단일 문서 인덱싱
     */
    @Transactional
    public CompletableFuture<Boolean> indexDocument(String documentId, String content, 
                                                  String contentType, Map<String, Object> metadata) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                log.info("Starting document indexing for: {}", documentId);
                
                // 1. 기존 벡터 삭제 (재인덱싱 시)
                vectorRepository.deleteByDocumentId(documentId);
                
                // 2. 텍스트 청킹
                List<DocumentChunk> chunks = chunkDocument(content, documentId, contentType, metadata);
                log.info("Document chunked into {} segments", chunks.size());
                
                // 3. 배치 임베딩 생성 및 저장
                List<List<DocumentChunk>> batches = createBatches(chunks, batchSize);
                
                for (int i = 0; i < batches.size(); i++) {
                    List<DocumentChunk> batch = batches.get(i);
                    processBatch(batch, i + 1, batches.size());
                }
                
                log.info("Document indexing completed for: {}", documentId);
                return true;
                
            } catch (Exception e) {
                log.error("Failed to index document: {}", documentId, e);
                return false;
            }
        });
    }

    /**
     * 대량 문서 인덱싱
     */
    public CompletableFuture<Map<String, Boolean>> indexDocuments(Map<String, String> documents, 
                                                                String contentType) {
        
        return CompletableFuture.supplyAsync(() -> {
            Map<String, Boolean> results = new HashMap<>();
            
            List<CompletableFuture<Void>> futures = documents.entrySet().stream()
                .map(entry -> {
                    String docId = entry.getKey();
                    String content = entry.getValue();
                    
                    return indexDocument(docId, content, contentType, Map.of())
                        .thenAccept(success -> results.put(docId, success));
                })
                .toList();
            
            // 모든 인덱싱 완료 대기
            CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();
            
            log.info("Bulk indexing completed. Success: {}, Failed: {}", 
                    results.values().stream().mapToInt(success -> success ? 1 : 0).sum(),
                    results.values().stream().mapToInt(success -> success ? 0 : 1).sum());
            
            return results;
        });
    }

    /**
     * AI 분석 결과 인덱싱 (신고서 분석 결과를 RAG에 활용)
     */
    @Transactional
    public CompletableFuture<Boolean> indexAIAnalysisResult(String reportId, 
                                                          String ocrText, 
                                                          String analysisResult) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                String documentId = "ai_analysis_" + reportId;
                
                // OCR 텍스트와 분석 결과를 결합
                StringBuilder combinedContent = new StringBuilder();
                combinedContent.append("=== 신고서 OCR 텍스트 ===\n");
                combinedContent.append(ocrText).append("\n\n");
                combinedContent.append("=== AI 분석 결과 ===\n");
                combinedContent.append(analysisResult);
                
                Map<String, Object> metadata = Map.of(
                    "report_id", reportId,
                    "source_type", "ai_analysis",
                    "has_ocr", !ocrText.isEmpty(),
                    "has_analysis", !analysisResult.isEmpty()
                );
                
                return indexDocument(documentId, combinedContent.toString(), 
                                   "AI_ANALYSIS", metadata).get();
                
            } catch (Exception e) {
                log.error("Failed to index AI analysis result for report: {}", reportId, e);
                return false;
            }
        });
    }

    /**
     * 텍스트를 의미 단위로 청킹
     */
    private List<DocumentChunk> chunkDocument(String content, String documentId, 
                                            String contentType, Map<String, Object> metadata) {
        
        List<DocumentChunk> chunks = new ArrayList<>();
        
        // 1. 단락 기준으로 1차 분할
        String[] paragraphs = PARAGRAPH_PATTERN.split(content);
        
        StringBuilder currentChunk = new StringBuilder();
        int chunkIndex = 0;
        
        for (String paragraph : paragraphs) {
            paragraph = paragraph.trim();
            if (paragraph.isEmpty()) continue;
            
            // 2. 문장 기준으로 2차 분할
            String[] sentences = SENTENCE_PATTERN.split(paragraph);
            
            for (String sentence : sentences) {
                sentence = sentence.trim();
                if (sentence.isEmpty()) continue;
                
                // 토큰 수 추정 (대략 한글 1글자 = 1토큰)
                int estimatedTokens = estimateTokenCount(currentChunk.toString() + " " + sentence);
                
                if (estimatedTokens > maxTokensPerChunk && currentChunk.length() > 0) {
                    // 현재 청크 저장
                    chunks.add(createDocumentChunk(currentChunk.toString(), documentId, 
                                                 contentType, chunkIndex++, metadata));
                    
                    // 새 청크 시작 (오버랩 고려)
                    currentChunk = new StringBuilder();
                    if (overlapTokens > 0) {
                        String overlap = getLastTokens(currentChunk.toString(), overlapTokens);
                        currentChunk.append(overlap);
                    }
                }
                
                currentChunk.append(sentence).append(" ");
            }
        }
        
        // 마지막 청크 저장
        if (currentChunk.length() > 0) {
            chunks.add(createDocumentChunk(currentChunk.toString(), documentId, 
                                         contentType, chunkIndex, metadata));
        }
        
        return chunks;
    }

    /**
     * 문서 청크 객체 생성
     */
    private DocumentChunk createDocumentChunk(String text, String documentId, 
                                            String contentType, int chunkIndex, 
                                            Map<String, Object> metadata) {
        
        Map<String, Object> chunkMetadata = new HashMap<>(metadata);
        chunkMetadata.put("chunk_index", chunkIndex);
        chunkMetadata.put("chunk_length", text.length());
        chunkMetadata.put("token_count", estimateTokenCount(text));
        
        return DocumentChunk.builder()
            .documentId(documentId)
            .contentType(contentType)
            .chunkText(text.trim())
            .chunkIndex(chunkIndex)
            .metadata(chunkMetadata)
            .createdAt(LocalDateTime.now())
            .build();
    }

    /**
     * 배치 처리
     */
    private void processBatch(List<DocumentChunk> chunks, int batchNum, int totalBatches) {
        try {
            log.info("Processing batch {}/{} with {} chunks", batchNum, totalBatches, chunks.size());
            
            // 배치로 임베딩 생성
            List<String> texts = chunks.stream()
                .map(DocumentChunk::getChunkText)
                .toList();
            
            EmbeddingRequest request = new EmbeddingRequest(texts, EmbeddingOptions.EMPTY);
            EmbeddingResponse response = embeddingClient.call(request);
            
            // 임베딩과 청크를 매핑하여 저장
            for (int i = 0; i < chunks.size(); i++) {
                DocumentChunk chunk = chunks.get(i);
                List<Double> embedding = response.getResults().get(i).getOutput();
                
                DocumentVector vector = DocumentVector.builder()
                    .documentId(chunk.getDocumentId())
                    .contentType(chunk.getContentType())
                    .chunkText(chunk.getChunkText())
                    .chunkIndex(chunk.getChunkIndex())
                    .embedding(embedding.stream().map(Double::floatValue).toList())
                    .metadata(chunk.getMetadata())
                    .createdAt(LocalDateTime.now())
                    .build();
                
                vectorRepository.save(vector);
            }
            
            log.info("Batch {}/{} processed successfully", batchNum, totalBatches);
            
        } catch (Exception e) {
            log.error("Failed to process batch {}/{}", batchNum, totalBatches, e);
            throw new RuntimeException("Batch processing failed", e);
        }
    }

    /**
     * 리스트를 배치로 분할
     */
    private <T> List<List<T>> createBatches(List<T> items, int batchSize) {
        List<List<T>> batches = new ArrayList<>();
        for (int i = 0; i < items.size(); i += batchSize) {
            int endIndex = Math.min(i + batchSize, items.size());
            batches.add(items.subList(i, endIndex));
        }
        return batches;
    }

    /**
     * 토큰 수 추정 (간단한 휴리스틱)
     */
    private int estimateTokenCount(String text) {
        if (text == null || text.isEmpty()) {
            return 0;
        }
        
        // 한글: 1글자 ≈ 1토큰, 영어: 4글자 ≈ 1토큰, 공백/기호 고려
        int koreanChars = text.replaceAll("[^\\p{IsHangul}]", "").length();
        int englishChars = text.replaceAll("[^a-zA-Z]", "").length();
        int otherChars = text.length() - koreanChars - englishChars;
        
        return koreanChars + (englishChars / 4) + (otherChars / 2);
    }

    /**
     * 텍스트의 마지막 N개 토큰 추출 (오버랩용)
     */
    private String getLastTokens(String text, int tokenCount) {
        if (text == null || text.isEmpty()) {
            return "";
        }
        
        String[] words = text.split("\\s+");
        int startIndex = Math.max(0, words.length - tokenCount);
        
        return String.join(" ", Arrays.copyOfRange(words, startIndex, words.length));
    }

    /**
     * 인덱싱 상태 확인
     */
    public CompletableFuture<Map<String, Object>> getIndexingStatus() {
        return CompletableFuture.supplyAsync(() -> {
            try {
                long totalVectors = vectorRepository.count();
                long totalDocuments = vectorRepository.countDistinctDocuments();
                
                // 컨텐츠 타입별 통계를 수동으로 계산
                List<Object[]> statistics = vectorRepository.getContentTypeStatistics();
                Map<String, Long> contentTypeCounts = new HashMap<>();
                for (Object[] stat : statistics) {
                    contentTypeCounts.put((String) stat[0], ((Number) stat[1]).longValue());
                }
                
                return Map.of(
                    "total_vectors", totalVectors,
                    "total_documents", totalDocuments,
                    "content_type_distribution", contentTypeCounts,
                    "last_updated", LocalDateTime.now()
                );
                
            } catch (Exception e) {
                log.error("Failed to get indexing status", e);
                return Map.of("error", e.getMessage());
            }
        });
    }

    /**
     * 문서 재인덱싱
     */
    @Transactional
    public CompletableFuture<Boolean> reindexDocument(String documentId) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                // 기존 벡터 삭제 (void 반환이므로 카운트 없이 진행)
                vectorRepository.deleteByDocumentId(documentId);
                log.info("Deleted existing vectors for document: {}", documentId);
                
                // TODO: 원본 문서를 다시 가져와서 재인덱싱
                // 실제 구현에서는 문서 저장소에서 원본을 조회해야 함
                
                return true;
                
            } catch (Exception e) {
                log.error("Failed to reindex document: {}", documentId, e);
                return false;
            }
        });
    }
}