import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/models/report.dart';
import '../providers/reports_provider.dart';
import '../widgets/report_viewer_widget.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final Report report;
  
  const ReportDetailScreen({
    Key? key,
    required this.report,
  }) : super(key: key);
  
  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReportDetails();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadReportDetails() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(reportsProvider.notifier).loadReportDetails(widget.report.id);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(singleReportProvider(widget.report.id));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Preview'),
            Tab(text: 'Insights'),
            Tab(text: 'Details'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportDetails,
          ),
          PopupMenuButton<String>(
            onSelected: _handleAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Download'),
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: ListTile(
                  leading: Icon(Icons.print),
                  title: Text('Print'),
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
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.import_export),
                  title: Text('Export Data'),
                ),
              ),
              const PopupMenuItem(
                value: 'regenerate',
                child: ListTile(
                  leading: Icon(Icons.replay),
                  title: Text('Regenerate'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) => TabBarView(
          controller: _tabController,
          children: [
            _buildPreviewTab(report),
            _buildInsightsTab(report),
            _buildDetailsTab(report),
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
                onPressed: _loadReportDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPreviewTab(Report report) {
    if (report.fileUrl == null) {
      return const Center(
        child: Text('No preview available'),
      );
    }
    
    switch (report.format.toLowerCase()) {
      case 'pdf':
        return SfPdfViewer.network(
          report.fileUrl!,
          onDocumentLoadFailed: (details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load PDF: ${details.error}')),
            );
          },
        );
      
      case 'excel':
      case 'csv':
        return ReportViewerWidget(
          report: report,
          format: report.format,
        );
      
      case 'json':
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            report.content ?? 'No content available',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        );
      
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text('${report.format.toUpperCase()} format'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _downloadReport(report),
                icon: const Icon(Icons.download),
                label: const Text('Download to View'),
              ),
            ],
          ),
        );
    }
  }
  
  Widget _buildInsightsTab(Report report) {
    final insights = report.insights ?? [];
    final recommendations = report.recommendations ?? [];
    
    if (insights.isEmpty && recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No AI insights available'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _generateInsights(report),
              child: const Text('Generate Insights'),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (insights.isNotEmpty) ...[
          _buildSectionHeader('Key Insights', Icons.lightbulb),
          ...insights.map((insight) => _buildInsightCard(insight)),
          const SizedBox(height: 24),
        ],
        
        if (recommendations.isNotEmpty) ...[
          _buildSectionHeader('Recommendations', Icons.thumb_up),
          ...recommendations.map((rec) => _buildRecommendationCard(rec)),
          const SizedBox(height: 24),
        ],
        
        // Summary statistics
        if (report.statistics != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Summary Statistics', Icons.bar_chart),
                  const SizedBox(height: 16),
                  _buildStatisticsGrid(report.statistics!),
                ],
              ),
            ),
          ),
        
        // AI Analysis Score
        if (report.aiScore != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('AI Analysis Score', Icons.psychology),
                  const SizedBox(height: 16),
                  _buildAIScoreIndicator(report.aiScore!),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildDetailsTab(Report report) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard('Report Information', [
          _buildDetailRow('Title', report.title),
          _buildDetailRow('Category', report.category.toUpperCase()),
          _buildDetailRow('Format', report.format.toUpperCase()),
          _buildDetailRow('Created', _formatDateTime(report.createdAt)),
          _buildDetailRow('Size', _formatFileSize(report.fileSize ?? 0)),
          _buildDetailRow('Status', report.status.toUpperCase()),
        ]),
        
        const SizedBox(height: 16),
        
        _buildDetailCard('Generation Details', [
          _buildDetailRow('AI Generated', report.aiGenerated ? 'Yes' : 'No'),
          _buildDetailRow('Template Used', report.templateName ?? 'None'),
          _buildDetailRow('Date Range', report.dateRange ?? 'Not specified'),
          _buildDetailRow('Processing Time', '${report.processingTime ?? 0}s'),
          _buildDetailRow('Data Sources', report.dataSources?.join(', ') ?? 'N/A'),
        ]),
        
        const SizedBox(height: 16),
        
        _buildDetailCard('Metadata', [
          ...(report.metadata ?? {}).entries.map(
            (entry) => _buildDetailRow(entry.key, entry.value.toString()),
          ),
        ]),
        
        const SizedBox(height: 16),
        
        // Action buttons
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _regenerateReport(report),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate Report'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _scheduleReport(report),
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule This Report'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _createTemplate(report),
                  icon: const Icon(Icons.save_as),
                  label: const Text('Save as Template'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
  
  Widget _buildInsightCard(String insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.insights, color: Colors.blue.shade700),
        ),
        title: Text(insight),
      ),
    );
  }
  
  Widget _buildRecommendationCard(String recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.recommend, color: Colors.green.shade700),
        ),
        title: Text(recommendation),
      ),
    );
  }
  
  Widget _buildStatisticsGrid(Map<String, dynamic> statistics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: statistics.entries.map((entry) {
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
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildAIScoreIndicator(double score) {
    final color = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.orange
            : Colors.red;
    
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  '${score.toInt()}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _getScoreDescription(score),
          style: TextStyle(color: color),
        ),
      ],
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
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
           '${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  String _getScoreDescription(double score) {
    if (score >= 90) return 'Excellent analysis quality';
    if (score >= 80) return 'Very good analysis quality';
    if (score >= 70) return 'Good analysis quality';
    if (score >= 60) return 'Fair analysis quality';
    return 'Needs improvement';
  }
  
  void _handleAction(String action) async {
    switch (action) {
      case 'download':
        await _downloadReport(widget.report);
        break;
      case 'print':
        await _printReport(widget.report);
        break;
      case 'share':
        await _shareReport(widget.report);
        break;
      case 'export':
        await _exportData(widget.report);
        break;
      case 'regenerate':
        await _regenerateReport(widget.report);
        break;
    }
  }
  
  Future<void> _downloadReport(Report report) async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(reportsProvider.notifier).downloadReport(report.id);
      
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _printReport(Report report) async {
    try {
      final pdf = pw.Document();
      
      // Create PDF content
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                report.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(report.content ?? 'No content available'),
            ],
          ),
        ),
      );
      
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: report.title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Print failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _shareReport(Report report) async {
    try {
      if (report.fileUrl != null) {
        await Share.share(
          'Check out this report: ${report.title}\n\n${report.fileUrl}',
          subject: report.title,
        );
      } else {
        await Share.share(
          'Report: ${report.title}\n\n${report.content ?? "No content available"}',
          subject: report.title,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _exportData(Report report) async {
    // Show export options dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              onTap: () {
                Navigator.pop(context);
                _exportAs(report, 'csv');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON'),
              onTap: () {
                Navigator.pop(context);
                _exportAs(report, 'json');
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_on),
              title: const Text('Excel'),
              onTap: () {
                Navigator.pop(context);
                _exportAs(report, 'excel');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _exportAs(Report report, String format) async {
    try {
      await ref.read(reportsProvider.notifier).exportReport(
        report.id,
        format: format,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report exported as $format'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _regenerateReport(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Report'),
        content: const Text(
          'This will create a new version of the report with updated data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await ref.read(reportsProvider.notifier).regenerateReport(report.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report regeneration started'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Regeneration failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  Future<void> _scheduleReport(Report report) async {
    Navigator.pushNamed(
      context,
      '/reports/schedule',
      arguments: report,
    );
  }
  
  Future<void> _createTemplate(Report report) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        String templateName = '';
        return AlertDialog(
          title: const Text('Save as Template'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Template Name',
              hintText: 'Enter a name for this template',
            ),
            onChanged: (value) => templateName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, templateName),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    
    if (name != null && name.isNotEmpty) {
      try {
        await ref.read(reportsProvider.notifier).createTemplate(
          report.id,
          name: name,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create template: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  Future<void> _generateInsights(Report report) async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(reportsProvider.notifier).generateInsights(report.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI insights generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate insights: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
