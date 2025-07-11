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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('보고서 목록'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                color: colorScheme.primary,
              ),
              onPressed: _refreshReports,
              tooltip: '새로고침',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: colorScheme.secondary,
              ),
              onPressed: () => _showFilterDialog(),
              tooltip: '필터',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshReports,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: _filteredReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '조건에 맞는 보고서가 없습니다',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '새로운 보고서를 작성해보세요',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = _filteredReports[index];
                    return _buildReportCard(report, index);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: 16,
        top: index == 0 ? 8 : 0,
      ),
      child: Card(
        elevation: 3,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/reports/detail',
              arguments: report['id'],
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surface.withOpacity(0.98),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 영역
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report['title'] ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusChip(report['status'], colorScheme),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 정보 영역
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.category_outlined,
                        '카테고리',
                        report['category'] ?? '',
                        colorScheme,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        '위치',
                        report['location'] ?? '',
                        colorScheme,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.schedule_outlined,
                        '날짜',
                        report['date'] ?? '',
                        colorScheme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String? status, ColorScheme colorScheme) {
    final statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status ?? '',
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
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
