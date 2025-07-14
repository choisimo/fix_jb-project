package com.jeonbuk.report.controller;

import com.jeonbuk.report.service.AiAgentAnalysisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.concurrent.CompletableFuture;

@Slf4j
@RestController
@RequestMapping("/api/v1/webhook/images")   // 새 경로, 기존 API 영향 없음
@RequiredArgsConstructor
public class ImageWebhookController {

    private final AiAgentAnalysisService aiAgentAnalysisService;

    /**
     * 보조용 웹훅 업로드 엔드포인트.
     * - 실패해도 기존 기능엔 영향 없음.
     * - 성공 시 AI 분석을 비동기로 수행.
     */
    @PostMapping(consumes = "multipart/form-data")
    public ResponseEntity<Void> uploadImage(@RequestPart("file") MultipartFile file) {
        try {
            String filename = file.getOriginalFilename();
            byte[] data = file.getBytes();

            // 비동기 분석; 결과는 로그로만 남기고, 호출자는 202 반환
            CompletableFuture
                .supplyAsync(() -> aiAgentAnalysisService.analyzeImageWithAI(data, filename))
                .thenAccept(r -> log.info("Webhook AI analysis finished: {}", r))
                .exceptionally(e -> { log.error("Webhook analysis failed", e); return null; });

            return ResponseEntity.accepted().build();   // 202 Accepted
        } catch (Exception e) {
            log.error("Webhook upload failed", e);
            return ResponseEntity.accepted().build();   // 실패해도 202 → 서비스 무중단
        }
    }
}