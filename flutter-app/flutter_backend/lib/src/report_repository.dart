
// lib/src/report_repository.dart

import 'dart:math';

// A simple Report model.
class Report {
  Report({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final String authorName;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// An in-memory repository for reports.
class ReportRepository {
  final List<Report> _reports = [
    Report(
      id: '1',
      title: '1번 구역 안전 점검 보고',
      content: '소화기 상태 양호, 비상구 확보 완료.',
      authorName: '김철수',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Report(
      id: '2',
      title: '자재 입고 현황 보고',
      content: '시멘트 100포, 철근 2톤 입고 완료.',
      authorName: '이영희',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Report(
      id: '3',
      title: '주간 공정 회의 결과',
      content: '다음 주 공정 계획에 대해 논의하였음.',
      authorName: '박민준',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  Future<List<Report>> getAllReports() async => _reports;

  Future<Report?> getReportById(String id) async {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Report> createReport({
    required String title,
    required String content,
    required String authorName,
  }) async {
    final report = Report(
      id: (Random().nextInt(10000) + 10).toString(),
      title: title,
      content: content,
      authorName: authorName,
      createdAt: DateTime.now(),
    );
    _reports.insert(0, report);
    return report;
  }

  Future<void> deleteReport(String id) async {
    _reports.removeWhere((r) => r.id == id);
  }
}
