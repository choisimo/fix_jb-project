import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/reports_provider.dart';
import '../widgets/report_generation_dialog.dart';
import 'report_detail_screen.dart';

class AIPoweredReportsScreen extends ConsumerStatefulWidget {
  const AIPoweredReportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIPoweredReportsScreen> createState() => _AIPoweredReportsScreenState();
}

class _AIPoweredReportsScreenState extends ConsumerState<AIPoweredReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Powered Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Generated'),
            Tab(text: 'Templates'),
            Tab(text: 'Scheduled'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedCategory = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Categories')),
              const PopupMenuItem(value: 'financial', child: Text('Financial')),
              const PopupMenuItem(value: 'operational', child: Text('Operational')),
              const PopupMenuItem(value: 'analytics', child: Text('Analytics')),
              const PopupMenuItem(value: 'compliance', child: Text('Compliance')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneratedReportsTab(reportsState),
          _buildTemplatesTab(reportsState),
          _buildScheduledReportsTab(reportsState),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportGenerationDialog(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Generate Report'),
      ),
    );
  }
  
  Widget _buildGeneratedReportsTab(AsyncValue<ReportsState> reportsState) {
    return reportsState.when(
      data: (state) {
        final filteredReports = _filterReports(state.generatedReports);
        
        if (filteredReports.isEmpty) {
          return _buildEmptyState(
            'No reports found',
            'Generate your first AI-powered report',
            Icons.description_outlined,
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(reportsProvider.future);
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }
  
  Widget _buildTemplatesTab(AsyncValue<ReportsState> reportsState) {
    return reportsState.when(
      data: (state) {
        final templates = state.templates;
        
        if (templates.isEmpty) {
          return _buildEmptyState(
            'No templates available',
            'Templates will be available soon',
            Icons.folder_outlined,
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return _buildTemplateCard(template);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }
  
  Widget _buildScheduledReportsTab(AsyncValue<ReportsState> reportsState) {
    return reportsState.when(
      data: (state) {
        final scheduledReports = state.scheduledReports;
        
        if (scheduledReports.isEmpty) {
          return _buildEmptyState(
            'No scheduled reports',
            'Set up automated report generation',
            Icons.schedule_outlined,
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scheduledReports.length,
          itemBuilder: (context, index) {
            final schedule = scheduledReports[index];
            return _buildScheduledReportCard(schedule);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }
  
  Widget _buildReportCard(Report report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToReportDetail(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getCategoryColor(report.category),
                    child: Icon(
                      _getCategoryIcon(report.category),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          report.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleReportAction(value, report),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('View'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'download',
                        child: ListTile(
                          leading: Icon(Icons.download),
                          title: Text('Download'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: ListTile(
                          leading: Icon(Icons.share),
                          title: Text('Share'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (report.description != null)
                Text(
                  report.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(report.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (report.aiGenerated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: Colors.purple.shade800,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI Generated',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.purple.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getFormatColor(report.format),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          report.format.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (report.insights != null && report.insights!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.insights!.first,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTemplateCard(ReportTemplate template) {
    return Card(
      child: InkWell(
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _getCategoryColor(template.category),
                child: Icon(
                  _getCategoryIcon(template.category),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                template.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                template.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildScheduledReportCard(ScheduledReport schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: schedule.enabled ? Colors.green : Colors.grey,
          child: Icon(
            schedule.enabled ? Icons.check : Icons.pause,
            color: Colors.white,
          ),
        ),
        title: Text(schedule.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${schedule.frequency} • Next: ${_formatNextRun(schedule.nextRun)}'),
            if (schedule.lastRun != null)
              Text(
                'Last run: ${DateFormat('MMM dd, HH:mm').format(schedule.lastRun!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: Switch(
          value: schedule.enabled,
          onChanged: (value) {
            ref.read(reportsProvider.notifier).toggleSchedule(schedule.id, value);
          },
        ),
        onTap: () => _editSchedule(schedule),
      ),
    );
  }
  
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showReportGenerationDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Generate Report'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(reportsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  List<Report> _filterReports(List<Report> reports) {
    return reports.where((report) {
      final matchesCategory = _selectedCategory == 'all' || report.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          report.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (report.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'financial':
        return Colors.green;
      case 'operational':
        return Colors.blue;
      case 'analytics':
        return Colors.purple;
      case 'compliance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'financial':
        return Icons.attach_money;
      case 'operational':
        return Icons.business;
      case 'analytics':
        return Icons.analytics;
      case 'compliance':
        return Icons.gavel;
      default:
        return Icons.description;
    }
  }
  
  Color _getFormatColor(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'excel':
        return Colors.green;
      case 'csv':
        return Colors.blue;
      case 'json':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  String _formatNextRun(DateTime nextRun) {
    final now = DateTime.now();
    final difference = nextRun.difference(now);
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minutes';
    } else {
      return 'soon';
    }
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Reports'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Search term',
            hintText: 'Enter title or description',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
  
  void _showReportGenerationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReportGenerationDialog(),
    );
  }
  
  void _navigateToReportDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: report),
      ),
    );
  }
  
  void _handleReportAction(String action, Report report) {
    switch (action) {
      case 'view':
        _navigateToReportDetail(report);
        break;
      case 'download':
        ref.read(reportsProvider.notifier).downloadReport(report.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading report...')),
        );
        break;
      case 'share':
        ref.read(reportsProvider.notifier).shareReport(report.id);
        break;
      case 'delete':
        _confirmDelete(report);
        break;
    }
  }
  
  void _confirmDelete(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(reportsProvider.notifier).deleteReport(report.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _useTemplate(ReportTemplate template) {
    showDialog(
      context: context,
      builder: (context) => ReportGenerationDialog(template: template),
    );
  }
  
  void _editSchedule(ScheduledReport schedule) {
    showDialog(
      context: context,
      builder: (context) => ScheduleEditDialog(schedule: schedule),
    );
  }
}
