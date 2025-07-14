import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/analysis_model.dart';
import '../../domain/models/analysis_type.dart';
import '../providers/ai_analysis_provider.dart';

class AnalysisDetailScreen extends ConsumerStatefulWidget {
  final AnalysisModel analysis;
  
  const AnalysisDetailScreen({
    Key? key,
    required this.analysis,
  }) : super(key: key);
  
  @override
  ConsumerState<AnalysisDetailScreen> createState() => _AnalysisDetailScreenState();
}

class _AnalysisDetailScreenState extends ConsumerState<AnalysisDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshAnalysis();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshAnalysis() async {
    setState(() => _isRefreshing = true);
    try {
      await ref.read(aiAnalysisProvider.notifier).refreshAnalysis(widget.analysis.id);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final analysisAsync = ref.watch(singleAnalysisProvider(widget.analysis.id));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.analysis.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAnalysis,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadReport,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                ),
              ),
              const PopupMenuItem(
                value: 'rerun',
                child: ListTile(
                  leading: Icon(Icons.replay),
                  title: Text('Re-run Analysis'),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Results'),
            Tab(text: 'Details'),
            Tab(text: 'Logs'),
          ],
        ),
      ),
      body: analysisAsync.when(
        data: (analysis) => TabBarView(
          controller: _tabController,
          children: [
            _buildResultsTab(analysis),
            _buildDetailsTab(analysis),
            _buildLogsTab(analysis),
          ],
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
                onPressed: _refreshAnalysis,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildResultsTab(AnalysisModel analysis) {
    if (analysis.status != 'completed') {
      return _buildProcessingView(analysis);
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analysis Complete',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Processed in ${_calculateDuration(analysis)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildSummaryMetrics(analysis),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Type-specific results
          _buildTypeSpecificResults(analysis),
          
          // Confidence Score
          if (analysis.results?['confidence'] != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confidence Score',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (analysis.results!['confidence'] as num).toDouble() / 100,
                      minHeight: 20,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getConfidenceColor(analysis.results!['confidence']),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${analysis.results!['confidence']}% confidence',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getConfidenceColor(analysis.results!['confidence']),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Raw Results
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text('Raw Results'),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: SelectableText(
                  _formatJson(analysis.results ?? {}),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailsTab(AnalysisModel analysis) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard('Basic Information', [
          _buildDetailRow('ID', analysis.id),
          _buildDetailRow('Title', analysis.title),
          _buildDetailRow('Description', analysis.description ?? 'N/A'),
          _buildDetailRow('Type', _getTypeLabel(analysis.type)),
          _buildDetailRow('Status', analysis.status.toUpperCase()),
          _buildDetailRow('Created', _formatDateTime(analysis.createdAt)),
          _buildDetailRow('Updated', _formatDateTime(analysis.updatedAt)),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Parameters', [
          ...(analysis.parameters ?? {}).entries.map((entry) =>
            _buildDetailRow(entry.key, entry.value.toString()),
          ).toList(),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Processing Information', [
          _buildDetailRow('Duration', _calculateDuration(analysis)),
          _buildDetailRow('Processing Node', analysis.processingNode ?? 'N/A'),
          _buildDetailRow('Model Version', analysis.modelVersion ?? 'N/A'),
          _buildDetailRow('Input Size', _formatBytes(analysis.inputSize ?? 0)),
          _buildDetailRow('Output Size', _formatBytes(analysis.outputSize ?? 0)),
        ]),
      ],
    );
  }
  
  Widget _buildLogsTab(AnalysisModel analysis) {
    final logs = analysis.logs ?? [];
    
    if (logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No logs available'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getLogLevelColor(log['level']),
              child: Text(
                log['level'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(log['message']),
            subtitle: Text(_formatDateTime(DateTime.parse(log['timestamp']))),
            isThreeLine: log['details'] != null,
            trailing: log['details'] != null
                ? IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showLogDetails(log),
                  )
                : null,
          ),
        );
      },
    );
  }
  
  Widget _buildProcessingView(AnalysisModel analysis) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 4),
          const SizedBox(height: 24),
          Text(
            'Processing Analysis...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            analysis.status.toUpperCase(),
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (analysis.progress != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: analysis.progress! / 100,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text('${analysis.progress}% complete'),
          ],
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: _refreshAnalysis,
            child: const Text('Refresh Status'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeSpecificResults(AnalysisModel analysis) {
    switch (analysis.type) {
      case AnalysisType.textClassification:
        return _buildTextClassificationResults(analysis);
      case AnalysisType.sentimentAnalysis:
        return _buildSentimentAnalysisResults(analysis);
      case AnalysisType.imageRecognition:
        return _buildImageRecognitionResults(analysis);
      case AnalysisType.dataAnalytics:
        return _buildDataAnalyticsResults(analysis);
      default:
        return _buildGenericResults(analysis);
    }
  }
  
  Widget _buildTextClassificationResults(AnalysisModel analysis) {
    final categories = analysis.results?['categories'] ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Classification Results',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...categories.map<Widget>((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['label'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: category['score'] / 100,
                            backgroundColor: Colors.grey[200],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${category['score']}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSentimentAnalysisResults(AnalysisModel analysis) {
    final sentiment = analysis.results?['sentiment'] ?? {};
    final emotions = analysis.results?['emotions'] ?? [];
    
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Sentiment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSentimentIndicator(
                      'Positive',
                      sentiment['positive'] ?? 0,
                      Colors.green,
                    ),
                    _buildSentimentIndicator(
                      'Neutral',
                      sentiment['neutral'] ?? 0,
                      Colors.grey,
                    ),
                    _buildSentimentIndicator(
                      'Negative',
                      sentiment['negative'] ?? 0,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (emotions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected Emotions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: emotions.map<Widget>((emotion) {
                      return Chip(
                        label: Text('${emotion['name']}: ${emotion['score']}%'),
                        backgroundColor: _getEmotionColor(emotion['name']),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildImageRecognitionResults(AnalysisModel analysis) {
    final objects = analysis.results?['objects'] ?? [];
    final faces = analysis.results?['faces'] ?? [];
    final text = analysis.results?['text'] ?? '';
    
    return Column(
      children: [
        if (objects.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected Objects',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...objects.map<Widget>((object) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${object['confidence']}%'),
                      ),
                      title: Text(object['label']),
                      subtitle: Text('Confidence: ${object['confidence']}%'),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        if (faces.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Face Detection',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text('${faces.length} face(s) detected'),
                ],
              ),
            ),
          ),
        ],
        if (text.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extracted Text',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildDataAnalyticsResults(AnalysisModel analysis) {
    final stats = analysis.results?['statistics'] ?? {};
    final insights = analysis.results?['insights'] ?? [];
    
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistical Summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildStatsGrid(stats),
              ],
            ),
          ),
        ),
        if (insights.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Insights',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...insights.map<Widget>((insight) {
                    return ListTile(
                      leading: Icon(
                        Icons.lightbulb,
                        color: Colors.amber,
                      ),
                      title: Text(insight['title']),
                      subtitle: Text(insight['description']),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildGenericResults(AnalysisModel analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis Results',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _formatJson(analysis.results ?? {}),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryMetrics(AnalysisModel analysis) {
    final metrics = analysis.results?['metrics'] ?? {};
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetric('Accuracy', '${metrics['accuracy'] ?? 'N/A'}%'),
        _buildMetric('Precision', '${metrics['precision'] ?? 'N/A'}%'),
        _buildMetric('Recall', '${metrics['recall'] ?? 'N/A'}%'),
      ],
    );
  }
  
  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSentimentIndicator(String label, num value, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
        Text(
          '$value%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.entries.map((entry) {
        return Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
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
  
  Color _getConfidenceColor(num confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }
  
  Color _getLogLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
        return Colors.yellow.shade200;
      case 'sadness':
        return Colors.blue.shade200;
      case 'anger':
        return Colors.red.shade200;
      case 'fear':
        return Colors.purple.shade200;
      case 'surprise':
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade200;
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
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  String _calculateDuration(AnalysisModel analysis) {
    if (analysis.completedAt == null) return 'In progress';
    
    final duration = analysis.completedAt!.difference(analysis.createdAt);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }
  
  void _showLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Details - ${log['level']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Message: ${log['message']}'),
              const SizedBox(height: 8),
              Text('Timestamp: ${log['timestamp']}'),
              if (log['details'] != null) ...[
                const SizedBox(height: 8),
                const Text('Details:'),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[100],
                  child: SelectableText(
                    _formatJson(log['details']),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _shareAnalysis() {
    final text = '''
Analysis: ${widget.analysis.title}
Type: ${_getTypeLabel(widget.analysis.type)}
Status: ${widget.analysis.status}
Created: ${_formatDateTime(widget.analysis.createdAt)}

Results Summary:
${_generateShareSummary()}
''';
    
    Share.share(text, subject: 'AI Analysis Results - ${widget.analysis.title}');
  }
  
  String _generateShareSummary() {
    final results = widget.analysis.results ?? {};
    final buffer = StringBuffer();
    
    // Add type-specific summary
    switch (widget.analysis.type) {
      case AnalysisType.sentimentAnalysis:
        final sentiment = results['sentiment'] ?? {};
        buffer.writeln('Positive: ${sentiment['positive'] ?? 0}%');
        buffer.writeln('Neutral: ${sentiment['neutral'] ?? 0}%');
        buffer.writeln('Negative: ${sentiment['negative'] ?? 0}%');
        break;
      case AnalysisType.textClassification:
        final categories = results['categories'] ?? [];
        for (final category in categories) {
          buffer.writeln('${category['label']}: ${category['score']}%');
        }
        break;
      default:
        buffer.writeln('See detailed results in the app');
    }
    
    return buffer.toString();
  }
  
  Future<void> _downloadReport() async {
    try {
      await ref.read(aiAnalysisProvider.notifier).downloadReport(widget.analysis.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _refreshAnalysis();
        break;
      case 'rerun':
        _rerunAnalysis();
        break;
      case 'delete':
        _deleteAnalysis();
        break;
    }
  }
  
  Future<void> _rerunAnalysis() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-run Analysis'),
        content: const Text('This will create a new analysis with the same parameters. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Re-run'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await ref.read(aiAnalysisProvider.notifier).rerunAnalysis(widget.analysis.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Analysis re-run started'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Re-run failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  Future<void> _deleteAnalysis() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Analysis'),
        content: Text('Are you sure you want to delete "${widget.analysis.title}"? This action cannot be undone.'),
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
      try {
        await ref.read(aiAnalysisProvider.notifier).deleteAnalysis(widget.analysis.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Analysis deleted'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
