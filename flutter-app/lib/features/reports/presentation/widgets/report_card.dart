import 'package:flutter/material.dart';
import '../../domain/entities/report.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(report.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.content,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildCategoryChip(report.category),
                  const SizedBox(width: 8),
                  _buildPriorityChip(report.priority),
                  const Spacer(),
                  if (report.imageUrls.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.image,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${report.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    report.authorName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
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
      label: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
