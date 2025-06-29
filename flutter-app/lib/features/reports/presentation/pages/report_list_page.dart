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
  List<Map<String, dynamic>> _filteredReports = [];

  // 필터 상태
  String? _selectedStatus;
  String? _selectedCategory;

  // 필터 옵션들
  final List<String> _statusOptions = ['전체', '접수', '처리중', '완료', '보류'];
  final List<String> _categoryOptions = [
    '전체',
    '안전',
    '품질',
    '진행상황',
    '유지보수',
    '기타',
  ];

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
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredReports = _reports.where((report) {
      // 상태 필터
      if (_selectedStatus != null && _selectedStatus != '전체') {
        if (report['status'] != _selectedStatus) {
          return false;
        }
      }

      // 카테고리 필터
      if (_selectedCategory != null && _selectedCategory != '전체') {
        if (report['category'] != _selectedCategory) {
          return false;
        }
      }

      return true;
    }).toList();
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
        child: _filteredReports.isEmpty
            ? const Center(
                child: Text(
                  '조건에 맞는 보고서가 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _filteredReports.length,
                itemBuilder: (context, index) {
                  final report = _filteredReports[index];
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
    String? tempStatus = _selectedStatus;
    String? tempCategory = _selectedCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('필터 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('상태', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tempStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                hint: const Text('상태 선택'),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    tempStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tempCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                hint: const Text('카테고리 선택'),
                items: _categoryOptions.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    tempCategory = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 필터 초기화
                setState(() {
                  _selectedStatus = null;
                  _selectedCategory = null;
                  _applyFilters();
                });
                Navigator.of(context).pop();
              },
              child: const Text('초기화'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                // 필터 적용
                setState(() {
                  _selectedStatus = tempStatus;
                  _selectedCategory = tempCategory;
                  _applyFilters();
                });
                Navigator.of(context).pop();
              },
              child: const Text('적용'),
            ),
          ],
        ),
      ),
    );
  }
}
