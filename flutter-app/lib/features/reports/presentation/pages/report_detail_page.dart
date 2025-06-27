import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../../domain/entities/report.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class ReportDetailPage extends StatefulWidget {
  final String reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  Report? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final reportProvider = context.read<ReportProvider>();
    final report = await reportProvider.getReport(widget.reportId);

    if (mounted) {
      setState(() {
        _report = report;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보고서 상세'),
        actions: [
          if (_report != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    // 수정 페이지로 이동
                    break;
                  case 'delete':
                    _showDeleteDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('수정')),
                const PopupMenuItem(value: 'delete', child: Text('삭제')),
              ],
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _report == null
            ? const Center(child: Text('보고서를 찾을 수 없습니다.'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildContent(),
                    const SizedBox(height: 16),
                    if (_report!.imageUrls.isNotEmpty) ...[
                      _buildImages(),
                      const SizedBox(height: 16),
                    ],
                    if (_report!.location != null) ...[
                      _buildLocation(),
                      const SizedBox(height: 16),
                    ],
                    _buildComments(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _report!.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(_report!.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCategoryChip(_report!.category),
                const SizedBox(width: 8),
                _buildPriorityChip(_report!.priority),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _report!.authorName,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  _formatDate(_report!.createdAt),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '내용',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_report!.content, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildImages() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '첨부 사진',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _report!.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _report!.imageUrls[index],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '위치 정보',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_report!.location!.address),
            const SizedBox(height: 4),
            Text(
              '위도: ${_report!.location!.latitude.toStringAsFixed(6)}, '
              '경도: ${_report!.location!.longitude.toStringAsFixed(6)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '댓글',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_report!.comments.isEmpty)
              const Text('댓글이 없습니다.', style: TextStyle(color: Colors.grey))
            else
              ...(_report!.comments.map(
                (comment) => _buildCommentItem(comment),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(ReportComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.authorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                _formatDate(comment.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color color;
    String text;

    switch (status) {
      case ReportStatus.draft:
        color = Colors.grey;
        text = '임시저장';
        break;
      case ReportStatus.submitted:
        color = Colors.blue;
        text = '제출완료';
        break;
      case ReportStatus.approved:
        color = Colors.green;
        text = '승인';
        break;
      case ReportStatus.rejected:
        color = Colors.red;
        text = '반려';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCategoryChip(ReportCategory category) {
    String text;

    switch (category) {
      case ReportCategory.safety:
        text = '안전';
        break;
      case ReportCategory.quality:
        text = '품질';
        break;
      case ReportCategory.progress:
        text = '진행상황';
        break;
      case ReportCategory.maintenance:
        text = '유지보수';
        break;
      case ReportCategory.other:
        text = '기타';
        break;
    }

    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPriorityChip(ReportPriority priority) {
    Color color;
    String text;

    switch (priority) {
      case ReportPriority.low:
        color = Colors.green;
        text = '낮음';
        break;
      case ReportPriority.normal:
        color = Colors.blue;
        text = '보통';
        break;
      case ReportPriority.high:
        color = Colors.orange;
        text = '높음';
        break;
      case ReportPriority.urgent:
        color = Colors.red;
        text = '긴급';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('보고서 삭제'),
        content: const Text('정말 이 보고서를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final reportProvider = context.read<ReportProvider>();
              final success = await reportProvider.deleteReport(
                widget.reportId,
              );

              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('보고서가 삭제되었습니다.')));
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('보고서 삭제에 실패했습니다.')),
                );
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
