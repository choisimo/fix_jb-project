package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.StatisticsService;
import com.jeonbuk.report.presentation.dto.response.ApiResponse;
import com.jeonbuk.report.presentation.dto.response.StatisticsResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/statistics")
@RequiredArgsConstructor
@Slf4j
public class StatisticsController {

    private final StatisticsService statisticsService;

    @GetMapping("/overview")
    public ResponseEntity<ApiResponse<StatisticsResponse>> getOverallStatistics() {
        try {
            StatisticsResponse statistics = statisticsService.getOverallStatistics();
            return ResponseEntity.ok(
                    ApiResponse.success("Statistics retrieved successfully", statistics)
            );
        } catch (Exception e) {
            log.error("Error retrieving overall statistics: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to retrieve statistics: " + e.getMessage()));
        }
    }

    @GetMapping("/category/{categoryName}")
    public ResponseEntity<ApiResponse<StatisticsResponse>> getCategoryStatistics(
            @PathVariable String categoryName) {
        try {
            StatisticsResponse statistics = statisticsService.getCategoryStatistics(categoryName);
            return ResponseEntity.ok(
                    ApiResponse.success("Category statistics retrieved successfully", statistics)
            );
        } catch (Exception e) {
            log.error("Error retrieving category statistics for {}: {}", categoryName, e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to retrieve category statistics: " + e.getMessage()));
        }
    }

    @GetMapping("/range")
    public ResponseEntity<ApiResponse<StatisticsResponse>> getTimeRangeStatistics(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        try {
            if (startDate.isAfter(endDate)) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Start date must be before end date"));
            }

            StatisticsResponse statistics = statisticsService.getTimeRangeStatistics(startDate, endDate);
            return ResponseEntity.ok(
                    ApiResponse.success("Time range statistics retrieved successfully", statistics)
            );
        } catch (Exception e) {
            log.error("Error retrieving time range statistics: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to retrieve time range statistics: " + e.getMessage()));
        }
    }

    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<StatisticsResponse>> getDashboardStatistics() {
        try {
            // Dashboard typically shows overview with current month data
            StatisticsResponse statistics = statisticsService.getOverallStatistics();
            return ResponseEntity.ok(
                    ApiResponse.success("Dashboard statistics retrieved successfully", statistics)
            );
        } catch (Exception e) {
            log.error("Error retrieving dashboard statistics: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to retrieve dashboard statistics: " + e.getMessage()));
        }
    }
}