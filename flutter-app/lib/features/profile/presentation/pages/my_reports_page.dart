import 'package:flutter/material.dart';
import '../../../../core/managers/report_manager.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final ReportManager _reportManager = ReportManager();
  List<Map<String, dynamic>> _myReports = [];
  String _selectedFilter = '전체';

  final List<String> _filters = ['전체', '대기', '처리중', '완료'];

  @override
  void initState() {
    super.initState();
    _loadMyReports();
  }

  void _loadMyReports() {
    // 현재 사용자의 보고서만 필터링 (시뮬레이션)
    final allReports = _reportManager.reports;
    setState(() {
      _myReports = _selectedFilter == '전체'
          ? allReports
          : allReports
                .where((report) => report['status'] == _selectedFilter)
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 보고서'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
              _loadMyReports();
            },
            itemBuilder: (context) => _filters
                .map(
                  (filter) => PopupMenuItem(
                    value: filter,
                    child: Row(
                      children: [
                        if (_selectedFilter == filter)
                          const Icon(Icons.check, size: 16),
                        if (_selectedFilter == filter) const SizedBox(width: 8),
                        Text(filter),
                      ],
                    ),
                  ),
                )
                .toList(),
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _myReports.isEmpty ? _buildEmptyState() : _buildReportsList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '보고서가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '새로운 신고서를 작성해보세요',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '총 ${_myReports.length}개의 보고서',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '필터: $_selectedFilter',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _myReports.length,
            itemBuilder: (context, index) {
              final report = _myReports[index];
              return _buildReportCard(report);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '카테고리: ${report['category']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '위치: ${report['location']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    report['date'] ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (report['images'] != null && report['images'] > 0) ...[
                    Icon(
                      Icons.photo_library,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${report['images']}장',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
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

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report['title'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('상태', report['status'] ?? ''),
              _buildDetailRow('카테고리', report['category'] ?? ''),
              _buildDetailRow('날짜', report['date'] ?? ''),
              _buildDetailRow('위치', _getLocationString(report['location'])),
              if (report['content'] != null) ...[
                const SizedBox(height: 8),
                const Text('내용', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(report['content'].toString()),
              ],
              if (report['aiAnalysis'] != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'AI 분석 결과',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ..._buildAIAnalysisResults(report['aiAnalysis']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // 위치 정보를 String으로 변환하는 헬퍼 메서드
  String _getLocationString(dynamic location) {
    if (location == null) return '위치 정보 없음';

    if (location is String) {
      return location;
    }

    if (location is Map<String, dynamic>) {
      // ReportLocation.toJson() 형태의 Map인 경우
      if (location.containsKey('address')) {
        return location['address']?.toString() ?? '위치 정보 없음';
      }
      // 다른 Map 형태인 경우
      return location.toString();
    }

    return location.toString();
  }

  // AI 분석 결과를 안전하게 처리하는 헬퍼 메서드
  List<Widget> _buildAIAnalysisResults(dynamic aiAnalysis) {
    if (aiAnalysis == null) return [];

    try {
      if (aiAnalysis is List) {
        return aiAnalysis.map((analysis) {
          if (analysis is Map<String, dynamic>) {
            final name = analysis['name']?.toString() ?? '알 수 없음';
            final confidence = analysis['confidence']?.toString() ?? '0';
            return Text('• $name: $confidence%');
          } else {
            return Text('• ${analysis.toString()}');
          }
        }).toList();
      } else if (aiAnalysis is Map<String, dynamic>) {
        // AI 분석 결과가 Map인 경우
        return [Text('• ${aiAnalysis.toString()}')];
      } else {
        // 다른 타입인 경우
        return [Text('• ${aiAnalysis.toString()}')];
      }
    } catch (e) {
      // 오류가 발생한 경우 안전한 기본값 반환
      return [const Text('• AI 분석 결과를 표시할 수 없습니다')];
    }
  }
}
