import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../domain/models/report.dart';
import '../data/providers/report_providers.dart';

class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({super.key});

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  final _searchController = TextEditingController();
  // 로컬 필터 상태 - 다이얼로그용
  ReportType? _selectedType;
  ReportStatus? _selectedStatus;
  Priority? _selectedPriority;

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  // 검색어 변경 처리
  void _onSearchChanged() {
    ref.read(reportListProvider.notifier).setSearchQuery(_searchController.text);
  }

  @override
  void initState() {
    super.initState();
    // 초기 로드 및 검색 리스너 등록
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportListProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('신고서 목록'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reportListProvider.notifier).refresh(),
            tooltip: '새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: '필터',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '신고서 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(reportListProvider.notifier).setSearchQuery(null);
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                // 검색어 변경시 프로바이더에 전달
                ref.read(reportListProvider.notifier).setSearchQuery(value);
              },
            ),
          ),

          // Filter Chips
          if (_hasActiveFilters())
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedType != null)
                    _buildFilterChip(
                      label: _getTypeDisplayName(_selectedType!),
                      onDelete: () {
                        setState(() => _selectedType = null);
                        ref.read(reportListProvider.notifier).setFilters(
                          type: null,
                          status: _selectedStatus,
                          priority: _selectedPriority,
                        );
                      },
                    ),
                  if (_selectedStatus != null)
                    _buildFilterChip(
                      label: _getStatusDisplayName(_selectedStatus!),
                      onDelete: () {
                        setState(() => _selectedStatus = null);
                        ref.read(reportListProvider.notifier).setFilters(
                          type: _selectedType,
                          status: null,
                          priority: _selectedPriority,
                        );
                      },
                    ),
                  if (_selectedPriority != null)
                    _buildFilterChip(
                      label: _getPriorityDisplayName(_selectedPriority!),
                      onDelete: () {
                        setState(() => _selectedPriority = null);
                        ref.read(reportListProvider.notifier).setFilters(
                          type: _selectedType,
                          status: _selectedStatus,
                          priority: null,
                        );
                      },
                    ),
                  if (_searchController.text.isNotEmpty)
                    _buildFilterChip(
                      label: '"' + _searchController.text + '" 검색',
                      onDelete: () {
                        _searchController.clear();
                        ref.read(reportListProvider.notifier).setSearchQuery(null);
                      },
                    ),
                ],
              ),
            ),

          // Reports List
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                // 필터링된 보고서가 없을 때 표시할 UI
                if (reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _hasActiveFilters()
                              ? '검색 결과가 없습니다'
                              : '신고서가 없습니다',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        if (_hasActiveFilters())
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                // 모든 필터 초기화 및 프로바이더에 전달
                                _searchController.clear();
                                setState(() {
                                  _selectedType = null;
                                  _selectedStatus = null;
                                  _selectedPriority = null;
                                });
                                ref.read(reportListProvider.notifier).setSearchQuery(null);
                                ref.read(reportListProvider.notifier).setFilters();
                              },
                              child: const Text('필터 초기화'),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(reportListProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _buildReportCard(report);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '신고서 목록을 불러오는 중 오류가 발생했습니다',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await ref.read(reportListProvider.notifier).refresh();
                      },
                      child: const Text('다시 시도'),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-report'),
        tooltip: '신고서 작성',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/report/${report.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    _getTypeIcon(report.type),
                    color: _getTypeColor(report.type),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(report.status),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                report.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    child: Text(
                      report.authorName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    report.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeago.format(report.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  _buildPriorityChip(report.priority),
                ],
              ),
              const SizedBox(height: 8),

              // Stats
              Row(
                children: [
                  _buildStatItem(Icons.visibility, report.viewCount.toString()),
                  const SizedBox(width: 16),
                  _buildStatItem(Icons.thumb_up_outlined, report.likeCount.toString()),
                  const SizedBox(width: 16),
                  _buildStatItem(Icons.comment_outlined, report.commentsCount.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(Priority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getPriorityDisplayName(priority),
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onDelete,
        backgroundColor: Colors.blue.shade50,
        labelStyle: TextStyle(color: Colors.blue.shade700),
        deleteIconColor: Colors.blue.shade700,
      ),
    );
  }

  // 필터링 여부 확인 (UI용)
  bool _hasActiveFilters() {
    return _selectedType != null || 
           _selectedStatus != null || 
           _selectedPriority != null ||
           _searchController.text.isNotEmpty;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신고서 필터링'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('유형'),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReportType?>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('모든 유형')),
                  ...ReportType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeDisplayName(type)),
                  )),
                ],
                onChanged: (value) => _selectedType = value,
              ),
              const SizedBox(height: 16),
              
              const Text('상태'),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReportStatus?>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('모든 상태')),
                  ...ReportStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusDisplayName(status)),
                  )),
                ],
                onChanged: (value) => _selectedStatus = value,
              ),
              const SizedBox(height: 16),
              
              const Text('우선순위'),
              const SizedBox(height: 8),
              DropdownButtonFormField<Priority?>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('모든 우선순위')),
                  ...Priority.values.map((priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(_getPriorityDisplayName(priority)),
                  )),
                ],
                onChanged: (value) => _selectedPriority = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedStatus = null;
                _selectedPriority = null;
              });
              
              // 프로바이더에 필터 초기화 전달
              ref.read(reportListProvider.notifier).setFilters();
              
              Navigator.of(context).pop();
            },
            child: const Text('초기화'),
          ),
          ElevatedButton(
            onPressed: () {
              // 프로바이더에 필터 적용
              ref.read(reportListProvider.notifier).setFilters(
                type: _selectedType,
                status: _selectedStatus,
                priority: _selectedPriority,
              );
              Navigator.of(context).pop();
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.pothole:
        return Icons.warning;
      case ReportType.streetLight:
        return Icons.lightbulb_outline;
      case ReportType.trash:
        return Icons.delete_outline;
      case ReportType.graffiti:
        return Icons.brush;
      case ReportType.roadDamage:
        return Icons.build;
      case ReportType.construction:
        return Icons.construction;
      case ReportType.other:
        return Icons.report_problem_outlined;
    }
  }

  Color _getTypeColor(ReportType type) {
    switch (type) {
      case ReportType.pothole:
        return Colors.orange;
      case ReportType.streetLight:
        return Colors.yellow.shade700;
      case ReportType.trash:
        return Colors.green;
      case ReportType.graffiti:
        return Colors.purple;
      case ReportType.roadDamage:
        return Colors.red;
      case ReportType.construction:
        return Colors.blue;
      case ReportType.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return Colors.grey;
      case ReportStatus.submitted:
        return Colors.blue;
      case ReportStatus.inProgress:
        return Colors.orange;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
      case ReportStatus.closed:
        return Colors.grey.shade600;
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }

  String _getTypeDisplayName(ReportType type) {
    switch (type) {
      case ReportType.pothole:
        return '포트홀';
      case ReportType.streetLight:
        return '가로등';
      case ReportType.trash:
        return '쓰레기';
      case ReportType.graffiti:
        return '낭서';
      case ReportType.roadDamage:
        return '도로 파손';
      case ReportType.construction:
        return '공사장';
      case ReportType.other:
        return '기타';
    }
  }

  String _getStatusDisplayName(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return '임시저장';
      case ReportStatus.submitted:
        return '접수됨';
      case ReportStatus.inProgress:
        return '처리중';
      case ReportStatus.resolved:
        return '해결됨';
      case ReportStatus.rejected:
        return '반려됨';
      case ReportStatus.closed:
        return '완료';
    }
  }

  String _getPriorityDisplayName(Priority priority) {
    switch (priority) {
      case Priority.low:
        return '낮음';
      case Priority.medium:
        return '중간';
      case Priority.high:
        return '높음';
      case Priority.urgent:
        return '긴급';
    }
  }
}