package com.jeonbuk.report.infrastructure.external;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.vision.v1.*;
import com.google.protobuf.ByteString;
import com.jeonbuk.report.domain.model.OcrResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

/**
 * Google Cloud Vision API 클라이언트
 * 서버 사이드에서 고정밀 OCR 처리를 담당
 */
@Slf4j
@Component
public class GoogleCloudVisionClient {

    @Value("${google.cloud.vision.enabled:false}")
    private boolean visionEnabled;
    
    @Value("${google.cloud.vision.project-id:}")
    private String projectId;
    
    @Value("${google.cloud.vision.credentials-path:}")
    private String credentialsPath;

    private ImageAnnotatorClient visionClient;
    private final Executor ocrExecutor = Executors.newFixedThreadPool(3);
    private boolean isInitialized = false;

    @PostConstruct
    public void initialize() {
        if (!visionEnabled) {
            log.info("📋 Google Cloud Vision API가 비활성화되어 있습니다");
            return;
        }

        try {
            // Google Cloud 인증 설정
            GoogleCredentials credentials;
            if (!credentialsPath.isEmpty()) {
                credentials = GoogleCredentials.fromStream(
                    getClass().getResourceAsStream(credentialsPath)
                );
            } else {
                // 기본 환경변수 또는 메타데이터 서버에서 자격증명 획득
                credentials = GoogleCredentials.getApplicationDefault();
            }

            // Vision API 클라이언트 초기화
            ImageAnnotatorSettings settings = ImageAnnotatorSettings.newBuilder()
                .setCredentialsProvider(() -> credentials)
                .build();
            
            this.visionClient = ImageAnnotatorClient.create(settings);
            this.isInitialized = true;
            
            log.info("✅ Google Cloud Vision API 클라이언트 초기화 완료");
        } catch (IOException e) {
            log.error("❌ Google Cloud Vision API 초기화 실패: {}", e.getMessage());
            this.isInitialized = false;
        }
    }

    /**
     * 이미지에서 텍스트 추출 (비동기)
     */
    public CompletableFuture<OcrResult> extractTextAsync(byte[] imageData, String filename) {
        return CompletableFuture.supplyAsync(() -> extractText(imageData, filename), ocrExecutor);
    }

    /**
     * 이미지에서 텍스트 추출 (동기)
     */
    public OcrResult extractText(byte[] imageData, String filename) {
        if (!isInitialized || !visionEnabled) {
            return OcrResult.builder()
                .id(UUID.randomUUID().toString())
                .engine(OcrResult.OcrEngine.GOOGLE_VISION)
                .status(OcrResult.OcrStatus.FAILED)
                .extractedText("")
                .confidence(0.0)
                .errorMessage("Google Cloud Vision API가 초기화되지 않았습니다")
                .processedAt(LocalDateTime.now())
                .build();
        }

        long startTime = System.currentTimeMillis();
        String resultId = UUID.randomUUID().toString();
        
        log.info("🔍 Google Vision OCR 시작 - 파일: {}, 크기: {} bytes", filename, imageData.length);

        try {
            // 이미지 데이터를 ByteString으로 변환
            ByteString imgBytes = ByteString.copyFrom(imageData);
            Image image = Image.newBuilder().setContent(imgBytes).build();
            
            // 텍스트 감지 기능 설정
            Feature textDetectionFeature = Feature.newBuilder()
                .setType(Feature.Type.TEXT_DETECTION)
                .build();
                
            Feature documentTextDetectionFeature = Feature.newBuilder()
                .setType(Feature.Type.DOCUMENT_TEXT_DETECTION)
                .build();

            // 이미지 컨텍스트 설정 (한국어 우선)
            ImageContext imageContext = ImageContext.newBuilder()
                .addLanguageHints("ko")
                .addLanguageHints("en")
                .build();

            // 요청 생성
            AnnotateImageRequest request = AnnotateImageRequest.newBuilder()
                .addFeatures(documentTextDetectionFeature) // 문서 텍스트 감지 우선 사용
                .addFeatures(textDetectionFeature)
                .setImage(image)
                .setImageContext(imageContext)
                .build();

            // Vision API 호출
            BatchAnnotateImagesResponse response = visionClient.batchAnnotateImages(
                Arrays.asList(request)
            );

            AnnotateImageResponse imageResponse = response.getResponsesList().get(0);
            
            if (imageResponse.hasError()) {
                throw new RuntimeException("Vision API 오류: " + imageResponse.getError().getMessage());
            }

            // 결과 처리
            return processVisionResponse(imageResponse, resultId, startTime, filename);

        } catch (Exception e) {
            long processingTime = System.currentTimeMillis() - startTime;
            log.error("❌ Google Vision OCR 실패 - 파일: {}, 오류: {}", filename, e.getMessage());
            
            return OcrResult.builder()
                .id(resultId)
                .engine(OcrResult.OcrEngine.GOOGLE_VISION)
                .status(OcrResult.OcrStatus.FAILED)
                .extractedText("")
                .confidence(0.0)
                .errorMessage(e.getMessage())
                .processedAt(LocalDateTime.now())
                .processingTimeMs((int) processingTime)
                .build();
        }
    }

    /**
     * Vision API 응답 처리
     */
    private OcrResult processVisionResponse(
        AnnotateImageResponse response, 
        String resultId, 
        long startTime, 
        String filename
    ) {
        long processingTime = System.currentTimeMillis() - startTime;
        
        // 문서 텍스트 감지 결과 우선 처리
        TextAnnotation documentText = response.getFullTextAnnotation();
        List<EntityAnnotation> textAnnotations = response.getTextAnnotationsList();
        
        if (documentText != null && !documentText.getText().isEmpty()) {
            return processDocumentTextAnnotation(documentText, resultId, processingTime, filename);
        } else if (!textAnnotations.isEmpty()) {
            return processTextAnnotations(textAnnotations, resultId, processingTime, filename);
        } else {
            return OcrResult.builder()
                .id(resultId)
                .engine(OcrResult.OcrEngine.GOOGLE_VISION)
                .status(OcrResult.OcrStatus.SUCCESS)
                .extractedText("")
                .confidence(0.0)
                .textBlocks(Collections.emptyList())
                .metadata(Map.of(
                    "filename", filename,
                    "message", "이미지에서 텍스트를 찾을 수 없습니다"
                ))
                .processedAt(LocalDateTime.now())
                .processingTimeMs((int) processingTime)
                .build();
        }
    }

    /**
     * 문서 텍스트 주석 처리 (높은 정확도)
     */
    private OcrResult processDocumentTextAnnotation(
        TextAnnotation documentText, 
        String resultId, 
        long processingTime, 
        String filename
    ) {
        List<OcrResult.TextBlock> textBlocks = new ArrayList<>();
        double totalConfidence = 0.0;
        int blockCount = 0;

        // 페이지별 처리
        for (Page page : documentText.getPagesList()) {
            for (Block block : page.getBlocksList()) {
                StringBuilder blockText = new StringBuilder();
                double blockConfidence = 0.0;
                int paragraphCount = 0;

                // 단락별 처리
                for (Paragraph paragraph : block.getParagraphsList()) {
                    for (Word word : paragraph.getWordsList()) {
                        for (Symbol symbol : word.getSymbolsList()) {
                            blockText.append(symbol.getText());
                            blockConfidence += symbol.getConfidence();
                        }
                        blockText.append(" ");
                    }
                    paragraphCount++;
                }

                if (blockText.length() > 0) {
                    blockConfidence /= Math.max(1, paragraphCount);
                    
                    // 경계 상자 생성
                    List<OcrResult.Point> boundingBox = createBoundingBox(block.getBoundingBox());
                    
                    textBlocks.add(OcrResult.TextBlock.builder()
                        .text(blockText.toString().trim())
                        .confidence(blockConfidence)
                        .boundingBox(boundingBox)
                        .language(detectLanguage(blockText.toString()))
                        .metadata(Map.of(
                            "blockType", "document_block",
                            "paragraphCount", paragraphCount
                        ))
                        .build());
                    
                    totalConfidence += blockConfidence;
                    blockCount++;
                }
            }
        }

        double averageConfidence = blockCount > 0 ? totalConfidence / blockCount : 0.0;
        
        log.info("✅ Google Vision OCR 완료 - 파일: {}, 블록: {}, 신뢰도: {:.2f}, 처리시간: {}ms", 
                filename, blockCount, averageConfidence, processingTime);

        return OcrResult.builder()
            .id(resultId)
            .engine(OcrResult.OcrEngine.GOOGLE_VISION)
            .status(averageConfidence > 0.5 ? OcrResult.OcrStatus.SUCCESS : OcrResult.OcrStatus.PARTIAL)
            .extractedText(documentText.getText())
            .confidence(averageConfidence)
            .textBlocks(textBlocks)
            .language(detectLanguage(documentText.getText()))
            .metadata(Map.of(
                "filename", filename,
                "processingType", "document_text_detection",
                "blockCount", blockCount,
                "totalCharacters", documentText.getText().length()
            ))
            .processedAt(LocalDateTime.now())
            .processingTimeMs((int) processingTime)
            .build();
    }

    /**
     * 일반 텍스트 주석 처리 (폴백)
     */
    private OcrResult processTextAnnotations(
        List<EntityAnnotation> textAnnotations, 
        String resultId, 
        long processingTime, 
        String filename
    ) {
        if (textAnnotations.isEmpty()) {
            return OcrResult.builder()
                .id(resultId)
                .engine(OcrResult.OcrEngine.GOOGLE_VISION)
                .status(OcrResult.OcrStatus.SUCCESS)
                .extractedText("")
                .confidence(0.0)
                .build();
        }

        // 첫 번째 주석이 전체 텍스트
        EntityAnnotation fullTextAnnotation = textAnnotations.get(0);
        List<OcrResult.TextBlock> textBlocks = new ArrayList<>();

        // 개별 단어들을 텍스트 블록으로 변환
        for (int i = 1; i < textAnnotations.size(); i++) {
            EntityAnnotation annotation = textAnnotations.get(i);
            List<OcrResult.Point> boundingBox = createBoundingBox(annotation.getBoundingPoly());
            
            textBlocks.add(OcrResult.TextBlock.builder()
                .text(annotation.getDescription())
                .confidence((double) annotation.getScore())
                .boundingBox(boundingBox)
                .language(detectLanguage(annotation.getDescription()))
                .metadata(Map.of("blockType", "text_annotation"))
                .build());
        }

        double averageConfidence = textBlocks.stream()
            .mapToDouble(OcrResult.TextBlock::getConfidence)
            .average()
            .orElse(0.0);

        return OcrResult.builder()
            .id(resultId)
            .engine(OcrResult.OcrEngine.GOOGLE_VISION)
            .status(averageConfidence > 0.5 ? OcrResult.OcrStatus.SUCCESS : OcrResult.OcrStatus.PARTIAL)
            .extractedText(fullTextAnnotation.getDescription())
            .confidence(averageConfidence)
            .textBlocks(textBlocks)
            .language(detectLanguage(fullTextAnnotation.getDescription()))
            .metadata(Map.of(
                "filename", filename,
                "processingType", "text_detection",
                "wordCount", textBlocks.size()
            ))
            .processedAt(LocalDateTime.now())
            .processingTimeMs((int) processingTime)
            .build();
    }

    /**
     * 경계 상자 생성
     */
    private List<OcrResult.Point> createBoundingBox(BoundingPoly boundingPoly) {
        List<OcrResult.Point> points = new ArrayList<>();
        for (Vertex vertex : boundingPoly.getVerticesList()) {
            points.add(OcrResult.Point.builder()
                .x((double) vertex.getX())
                .y((double) vertex.getY())
                .build());
        }
        return points;
    }

    /**
     * 언어 감지 (간단한 휴리스틱)
     */
    private String detectLanguage(String text) {
        if (text == null || text.isEmpty()) return null;
        
        long koreanCount = text.chars().filter(ch -> ch >= 0xAC00 && ch <= 0xD7AF).count();
        long englishCount = text.chars().filter(ch -> (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')).count();
        
        if (koreanCount > englishCount) return "ko";
        if (englishCount > 0) return "en";
        return null;
    }

    /**
     * 서비스 상태 확인
     */
    public boolean isAvailable() {
        return isInitialized && visionEnabled;
    }

    @PreDestroy
    public void cleanup() {
        if (visionClient != null) {
            try {
                visionClient.close();
                log.info("✅ Google Cloud Vision API 클라이언트 정리 완료");
            } catch (Exception e) {
                log.error("❌ Vision API 클라이언트 정리 실패: {}", e.getMessage());
            }
        }
    }
}