package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Report;
import com.jeonbuk.report.domain.repository.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReportService {

    private final ReportRepository reportRepository;

    @Transactional
    public Report createReport(Report report) {
        return reportRepository.save(report);
    }

    public Optional<Report> getReportById(UUID id) {
        return reportRepository.findById(id);
    }

    public Page<Report> getAllReports(Pageable pageable) {
        return reportRepository.findAll(pageable);
    }

    @Transactional
    public Report updateReport(UUID id, Report updated) {
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("리포트를 찾을 수 없습니다: " + id));
        report.setTitle(updated.getTitle());
        report.setContent(updated.getContent());
        // 필요한 필드 추가
        return reportRepository.save(report);
    }

    @Transactional
    public void deleteReport(UUID id) {
        reportRepository.deleteById(id);
    }
}
