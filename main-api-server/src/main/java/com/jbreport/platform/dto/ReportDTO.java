package com.jbreport.platform.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReportDTO {
    private Long id;
    private String title;
    private String description;
    private String category;
    private String status;
    private String priority;
    private Double latitude;
    private Double longitude;
    private String address;
    private boolean aiAnalyzed;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long userId;
    private String userName;
    private List<String> fileUrls;
    private Integer commentCount;
}
