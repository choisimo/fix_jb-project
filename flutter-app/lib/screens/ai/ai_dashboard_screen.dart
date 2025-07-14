import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/ai_analysis_provider.dart';
import '../../models/ai_analysis.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import 'new_analysis_screen.dart';
import 'analysis_detail_screen.dart';

class AIDashboardScreen extends StatefulWidget {
  const AIDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AIDashboardScreen> createState() => _AIDashboardScreenState();
}

class _AIDashboardScreenState extends State<AIDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIAnalysisProvider>().loadAnalyses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 분석 대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AIAnalysisProvider>().refreshAnalyses(),
          ),
        ],
      ),
      body: Consumer<AIAnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          if (provider.error != null) {
            return CustomErrorWidget(
              error: provider.error!,
              onRetry: () => provider.loadAnalyses(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshAnalyses(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildAnalyticsCards(provider),
                ),
                SliverToBoxAdapter(
                  child: _buildChartSection(provider),
                ),
                SliverToBoxAdapter(
                  child: _buildRecentAnalysesHeader(),
                ),
                _buildAnalysesList(provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewAnalysis(context),
        icon: const Icon(Icons.add),
        label: const Text('새 분석'),
      ),
    );
  }

  Widget _buildAnalyticsCards(AIAnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildAnalyticsCard(
              title: '총 분석',
              value: provider.totalAnalyses.toString(),
              icon: Icons.analytics,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildAnalyticsCard(
              title: '진행 중',
              value: provider.inProgressAnalyses.toString(),
              icon: Icons.pending,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildAnalyticsCard(
              title: '완료됨',
              value: provider.completedAnalyses.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(AIAnalysisProvider provider) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '분석 트렌드',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: provider.analysisChartData,
                        isCurved: true,
                        color: Theme.of(context).primaryColor,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAnalysesHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '최근 분석',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => _navigateToAllAnalyses(context),
            child: const Text('모두 보기'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysesList(AIAnalysisProvider provider) {
    final analyses = provider.recentAnalyses;
    
    if (analyses.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('분석 기록이 없습니다'),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final analysis = analyses[index];
          return _buildAnalysisItem(analysis);
        },
        childCount: analyses.length,
      ),
    );
  }

  Widget _buildAnalysisItem(AIAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(analysis.status),
          child: Icon(
            _getStatusIcon(analysis.status),
            color: Colors.white,
          ),
        ),
        title: Text(analysis.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(analysis.type),
            Text(
              '생성일: ${_formatDate(analysis.createdAt)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (analysis.score != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreColor(analysis.score!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${analysis.score}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _navigateToAnalysisDetail(context, analysis),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check;
      case 'in_progress':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _navigateToNewAnalysis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewAnalysisScreen(),
      ),
    );
  }

  void _navigateToAnalysisDetail(BuildContext context, AIAnalysis analysis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisDetailScreen(analysis: analysis),
      ),
    );
  }

  void _navigateToAllAnalyses(BuildContext context) {
    Navigator.pushNamed(context, '/ai/analyses');
  }
}
