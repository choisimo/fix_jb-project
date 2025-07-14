import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/analysis_model.dart';
import '../../domain/models/analysis_type.dart';
import '../providers/ai_analysis_provider.dart';
import '../widgets/analysis_card.dart';
import 'new_analysis_screen.dart';
import 'analysis_detail_screen.dart';

class AIDashboardScreen extends ConsumerStatefulWidget {
  const AIDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIDashboardScreen> createState() => _AIDashboardScreenState();
}

class _AIDashboardScreenState extends ConsumerState<AIDashboardScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  
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
    final analysisState = ref.watch(aiAnalysisProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(aiAnalysisProvider),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(analysisState),
          _buildActiveTab(analysisState),
          _buildHistoryTab(analysisState),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewAnalysisScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildOverviewTab(AsyncValue<List<AnalysisModel>> analysisState) {
    return analysisState.when(
      data: (analyses) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Analyses',
                    analyses.length.toString(),
                    Icons.analytics,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    analyses.where((a) => a.status == 'processing').length.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    analyses.where((a) => a.status == 'completed').length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Failed',
                    analyses.where((a) => a.status == 'failed').length.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Analysis Type Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analysis Type Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildPieChart(analyses),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Recent Activity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildRecentActivity(analyses.take(5).toList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(aiAnalysisProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActiveTab(AsyncValue<List<AnalysisModel>> analysisState) {
    return analysisState.when(
      data: (analyses) {
        final activeAnalyses = analyses
            .where((a) => a.status == 'processing' || a.status == 'pending')
            .toList();
            
        if (activeAnalyses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No active analyses'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeAnalyses.length,
          itemBuilder: (context, index) {
            final analysis = activeAnalyses[index];
            return AnalysisCard(
              analysis: analysis,
              onTap: () => _navigateToDetail(analysis),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
  
  Widget _buildHistoryTab(AsyncValue<List<AnalysisModel>> analysisState) {
    return analysisState.when(
      data: (analyses) {
        final completedAnalyses = analyses
            .where((a) => a.status == 'completed' || a.status == 'failed')
            .toList();
            
        if (completedAnalyses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No completed analyses'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedAnalyses.length,
          itemBuilder: (context, index) {
            final analysis = completedAnalyses[index];
            return AnalysisCard(
              analysis: analysis,
              onTap: () => _navigateToDetail(analysis),
              onDelete: () => _deleteAnalysis(analysis),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPieChart(List<AnalysisModel> analyses) {
    final typeCount = <AnalysisType, int>{};
    for (final analysis in analyses) {
      typeCount[analysis.type] = (typeCount[analysis.type] ?? 0) + 1;
    }
    
    final sections = typeCount.entries.map((entry) {
      final percentage = (entry.value / analyses.length) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getTypeColor(entry.key),
        radius: 80,
      );
    }).toList();
    
    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
  
  Color _getTypeColor(AnalysisType type) {
    switch (type) {
      case AnalysisType.textClassification:
        return Colors.blue;
      case AnalysisType.sentimentAnalysis:
        return Colors.green;
      case AnalysisType.imageRecognition:
        return Colors.orange;
      case AnalysisType.dataAnalytics:
        return Colors.purple;
      case AnalysisType.predictiveModeling:
        return Colors.red;
      case AnalysisType.anomalyDetection:
        return Colors.teal;
    }
  }
  
  List<Widget> _buildRecentActivity(List<AnalysisModel> analyses) {
    return analyses.map((analysis) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(analysis.type),
          child: Icon(
            _getTypeIcon(analysis.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(analysis.title),
        subtitle: Text(
          '${_getTypeLabel(analysis.type)} • ${_formatDate(analysis.createdAt)}',
        ),
        trailing: Chip(
          label: Text(
            analysis.status.toUpperCase(),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getStatusColor(analysis.status),
        ),
        onTap: () => _navigateToDetail(analysis),
      );
    }).toList();
  }
  
  IconData _getTypeIcon(AnalysisType type) {
    switch (type) {
      case AnalysisType.textClassification:
        return Icons.text_fields;
      case AnalysisType.sentimentAnalysis:
        return Icons.sentiment_satisfied;
      case AnalysisType.imageRecognition:
        return Icons.image;
      case AnalysisType.dataAnalytics:
        return Icons.analytics;
      case AnalysisType.predictiveModeling:
        return Icons.trending_up;
      case AnalysisType.anomalyDetection:
        return Icons.warning;
    }
  }
  
  String _getTypeLabel(AnalysisType type) {
    switch (type) {
      case AnalysisType.textClassification:
        return 'Text Classification';
      case AnalysisType.sentimentAnalysis:
        return 'Sentiment Analysis';
      case AnalysisType.imageRecognition:
        return 'Image Recognition';
      case AnalysisType.dataAnalytics:
        return 'Data Analytics';
      case AnalysisType.predictiveModeling:
        return 'Predictive Modeling';
      case AnalysisType.anomalyDetection:
        return 'Anomaly Detection';
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade100;
      case 'processing':
      case 'pending':
        return Colors.orange.shade100;
      case 'failed':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Analyses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Text Analysis'),
              value: 'text',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Image Analysis'),
              value: 'image',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Data Analysis'),
              value: 'data',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToDetail(AnalysisModel analysis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisDetailScreen(analysis: analysis),
      ),
    );
  }
  
  Future<void> _deleteAnalysis(AnalysisModel analysis) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Analysis'),
        content: Text('Are you sure you want to delete "${analysis.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await ref.read(aiAnalysisProvider.notifier).deleteAnalysis(analysis.id);
    }
  }
}
