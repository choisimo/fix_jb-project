import 'package:flutter/material.dart';
import '../../../../core/managers/report_manager.dart';

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ReportManager _reportManager = ReportManager();

  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadReports();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadReports() {
    setState(() {
      _reports = _reportManager.reports;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 더 많은 보고서 로드 로직 (추후 구현)
    }
  }

  // 새로고침 기능 (외부에서 호출 가능)
  Future<void> refreshReports() async {
    await Future.delayed(const Duration(milliseconds: 500)); // 시뮬레이션
    _loadReports();
  }

  // 내부 새로고침 (Pull to refresh용)
  Future<void> _refreshReports() async {
    await refreshReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보고서 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReports,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReports,
        child: _reports.isEmpty
            ? const Center(
                child: Text(
                  '아직 제출된 보고서가 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return _buildReportCard(report);
                },
              ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          report['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('카테고리: ${report['category']}'),
            Text('위치: ${report['location']}'),
            Text('날짜: ${report['date']}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(report['status']),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            report['status'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/reports/detail',
            arguments: report['id'],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case '완료':
        return Colors.green;
      case '처리중':
        return Colors.orange;
      case '대기':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('필터'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 필터 옵션들 구현
            Text('필터 기능 구현 예정'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }
}
