package com.jeonbuk.report.dto.report;

import com.jeonbuk.report.domain.entity.ReportSignature;
import com.jeonbuk.report.dto.user.UserSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

@Schema(description = "신고서 서명 정보")
public record ReportSignatureResponse(
        @Schema(description = "서명 ID") UUID id,
        @Schema(description = "서명자 이름") String signerName,
        @Schema(description = "서명자 역할") String signerRole,
        @Schema(description = "서명 데이터") String signatureData,
        @Schema(description = "서명 유형") String signatureType,
        @Schema(description = "서명일시") LocalDateTime signedAt
) {
    public static ReportSignatureResponse from(ReportSignature signature) {
        return new ReportSignatureResponse(
                signature.getId(),
                signature.getSignerName(),
                signature.getSignerRole(),
                signature.getSignatureData(),
                signature.getSignatureType(),
                signature.getSignedAt()
        );
    }
}