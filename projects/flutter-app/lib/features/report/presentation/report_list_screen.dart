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
  ReportType? _selectedType;
  ReportStatus? _selectedStatus;
  Priority? _selectedPriority;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
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
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                // TODO: Implement search
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
                      onDelete: () => setState(() => _selectedType = null),
                    ),
                  if (_selectedStatus != null)
                    _buildFilterChip(
                      label: _getStatusDisplayName(_selectedStatus!),
                      onDelete: () => setState(() => _selectedStatus = null),
                    ),
                  if (_selectedPriority != null)
                    _buildFilterChip(
                      label: _getPriorityDisplayName(_selectedPriority!),
                      onDelete: () => setState(() => _selectedPriority = null),
                    ),
                ],
              ),
            ),

          // Reports List
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                final filteredReports = _filterReports(reports);
                
                if (filteredReports.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No reports found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
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
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
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
                      'Error loading reports',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await ref.read(reportListProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
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

  List<Report> _filterReports(List<Report> reports) {
    return reports.where((report) {
      if (_selectedType != null && report.type != _selectedType) {
        return false;
      }
      if (_selectedStatus != null && report.status != _selectedStatus) {
        return false;
      }
      if (_selectedPriority != null && report.priority != _selectedPriority) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        return report.title.toLowerCase().contains(query) ||
               report.description.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  bool _hasActiveFilters() {
    return _selectedType != null || 
           _selectedStatus != null || 
           _selectedPriority != null;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reports'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type'),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReportType?>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Types')),
                  ...ReportType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeDisplayName(type)),
                  )),
                ],
                onChanged: (value) => _selectedType = value,
              ),
              const SizedBox(height: 16),
              
              const Text('Status'),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReportStatus?>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Statuses')),
                  ...ReportStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusDisplayName(status)),
                  )),
                ],
                onChanged: (value) => _selectedStatus = value,
              ),
              const SizedBox(height: 16),
              
              const Text('Priority'),
              const SizedBox(height: 8),
              DropdownButtonFormField<Priority?>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Priorities')),
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
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
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
        return 'Pothole';
      case ReportType.streetLight:
        return 'Street Light';
      case ReportType.trash:
        return 'Trash';
      case ReportType.graffiti:
        return 'Graffiti';
      case ReportType.roadDamage:
        return 'Road Damage';
      case ReportType.construction:
        return 'Construction';
      case ReportType.other:
        return 'Other';
    }
  }

  String _getStatusDisplayName(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return 'Draft';
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
      case ReportStatus.closed:
        return 'Closed';
    }
  }

  String _getPriorityDisplayName(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
    }
  }
}