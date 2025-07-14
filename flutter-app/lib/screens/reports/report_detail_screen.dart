import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/report_provider.dart';
import '../../providers/ai_analysis_provider.dart';
import '../../models/report.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailScreen({
    Key? key,
    required this.reportId,
  }) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    await context.read<ReportProvider>().loadReport(widget.reportId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        final report = provider.currentReport;

        if (provider.isLoading || report == null) {
          return const Scaffold(
            body: LoadingIndicator(),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(),
            body: CustomErrorWidget(
              error: provider.error!,
              onRetry: _loadReport,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(report.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareReport(report),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, report),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.download),
                      title: Text('내보내기'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'print',
                    child: ListTile(
                      leading: Icon(Icons.print),
                      title: Text('인쇄'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '개요'),
                Tab(text: '상세 데이터'),
                Tab(text: 'AI 분석'),
                Tab(text: '시각화'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(report),
              _buildDataTab(report),
              _buildAIAnalysisTab(report),
              _buildVisualizationTab(report),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(Report report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(report),
          const SizedBox(height: 16),
          _buildSummaryCard(report),
          const SizedBox(height: 16),
          _buildMetricsCard(report),
          const SizedBox(height: 16),
          _buildRecommendationsCard(report),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Report report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '보고서 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(report.status),
                  backgroundColor: _getStatusColor(report.status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('유형', report.type),
            _buildInfoRow('생성일', _formatDate(report.createdAt)),
            _buildInfoRow('생성자', report.createdBy),
            _buildInfoRow('기간', '${_formatDate(report.startDate)} - ${_formatDate(report.endDate)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Report report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '요약',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(report.summary ?? '요약 정보가 없습니다.'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(Report report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주요 지표',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: report.metrics.entries.map((entry) {
                return _buildMetricItem(entry.key, entry.value);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(Report report) {
    if (report.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '권장사항',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...report.recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTab(Report report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataTable(report),
          const SizedBox(height: 16),
          _buildRawDataSection(report),
        ],
      ),
    );
  }

  Widget _buildDataTable(Report report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '데이터 테이블',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: report.dataColumns.map((col) {
                  return DataColumn(label: Text(col));
                }).toList(),
                rows: report.dataRows.map((row) {
                  return DataRow(
                    cells: row.map((cell) {
                      return DataCell(Text(cell.toString()));
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawDataSection(Report report) {
    return Card(
      child: ExpansionTile(
        title: const Text(
          'Raw 데이터',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              report.rawData ?? 'Raw 데이터가 없습니다.',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisTab(Report report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIAnalysisCard(report),
          const SizedBox(height: 16),
          _buildInsightsCard(report),
          const SizedBox(height: 16),
          _buildPredictionsCard(report),
          const SizedBox(height: 16),
          _buildAnomaliesCard(report),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard(Report report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI 분석',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : () => _runAIAnalysis(report),
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.psychology),
                  label: Text(_isAnalyzing ? '분석 중...' : '재분석'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (report.aiAnalysis != null) ...[
              _buildAnalysisItem('신뢰도', '${report.aiAnalysis!.confidence}%'),
              _buildAnalysisItem('모델', report.aiAnalysis!.model),
              _buildAnalysisItem('분석 시간', _formatDate(report.aiAnalysis!.analyzedAt)),
              const SizedBox(height: 16),
              Text(report.aiAnalysis!.summary),
            ] else
              const Text('AI 분석이 아직 수행되지 않았습니다.'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(Report report) {
    final insights = report.aiAnalysis?.insights ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주요 인사이트',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (insights.isEmpty)
              const Text('발견된 인사이트가 없습니다.')
            else
              ...insights.map((insight) {
                return Card(
                  color: Colors.blue[50],
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb, color: Colors.orange),
                    title: Text(insight.title),
                    subtitle: Text(insight.description),
                    trailing: Text(
                      '${insight.impact}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsCard(Report report) {
    final predictions = report.aiAnalysis?.predictions ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '예측',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (predictions.isEmpty)
              const Text('예측 데이터가 없습니다.')
            else
              SizedBox(
                height: 200,
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
                        spots: predictions
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: Colors.blue,
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
    );
  }

  Widget _buildAnomaliesCard(Report report) {
    final anomalies = report.aiAnalysis?.anomalies ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이상 징후',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (anomalies.isEmpty)
              const Text('감지된 이상 징후가 없습니다.')
            else
              ...anomalies.map((anomaly) {
                return Card(
                  color: Colors.red[50],
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(anomaly.description),
                    subtitle: Text('심각도: ${anomaly.severity}'),
                    trailing: Text(
                      _formatDate(anomaly.detectedAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizationTab(Report report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartCard(
            title: '트렌드 차트',
            chart: _buildLineChart(report),
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            title: '분포 차트',
            chart: _buildPieChart(report),
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            title: '비교 차트',
            chart: _buildBarChart(report),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(Report report) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
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
            spots: report.chartData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Report report) {
    return PieChart(
      PieChartData(
        sections: report.pieChartData.asMap().entries.map((entry) {
          final colors = [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.orange,
            Colors.purple,
          ];
          return PieChartSectionData(
            value: entry.value['value'],
            title: entry.value['label'],
            color: colors[entry.key % colors.length],
            radius: 100,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(Report report) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: report.barChartData.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b) * 1.2,
        barGroups: report.barChartData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value['value'],
                color: Theme.of(context).primaryColor,
                width: 30,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green[100]!;
      case 'processing':
        return Colors.orange[100]!;
      case 'failed':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _shareReport(Report report) async {
    await Share.share(
      '${report.title}\n\n${report.summary ?? ''}',
      subject: report.title,
    );
  }

  void _handleMenuAction(String action, Report report) {
    switch (action) {
      case 'export':
        _exportReport(report);
        break;
      case 'print':
        _printReport(report);
        break;
      case 'delete':
        _deleteReport(report);
        break;
    }
  }

  Future<void> _exportReport(Report report) async {
    // Export implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('보고서를 내보내는 중...')),
    );
  }

  Future<void> _printReport(Report report) async {
    // Print implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인쇄 준비 중...')),
    );
  }

  Future<void> _deleteReport(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('보고서 삭제'),
        content: const Text('이 보고서를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<ReportProvider>().deleteReport(report.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 필터'),
        content: const Text('필터 옵션 구현 예정'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Future<void> _runAIAnalysis(Report report) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      await context.read<AIAnalysisProvider>().analyzeReport(report.id);
      await _loadReport(); // Reload to get updated analysis
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI 분석이 완료되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('분석 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
}
