package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.application.service.ReportService;
import com.jeonbuk.report.domain.entity.Report;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @PostMapping
    public ResponseEntity<Report> createReport(@RequestBody Report report) {
        Report created = reportService.createReport(report);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Report> getReportById(@PathVariable UUID id) {
        Optional<Report> report = reportService.getReportById(id);
        return report.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<Page<Report>> getAllReports(Pageable pageable) {
        Page<Report> reports = reportService.getAllReports(pageable);
        return ResponseEntity.ok(reports);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Report> updateReport(@PathVariable UUID id, @RequestBody Report updated) {
        Report report = reportService.updateReport(id, updated);
        return ResponseEntity.ok(report);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReport(@PathVariable UUID id) {
        reportService.deleteReport(id);
        return ResponseEntity.noContent().build();
    }
}
