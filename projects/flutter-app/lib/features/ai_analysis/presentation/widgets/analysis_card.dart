import 'package:flutter/material.dart';
import '../../domain/models/analysis_model.dart';
import '../../domain/models/analysis_type.dart';

class AnalysisCard extends StatelessWidget {
  final AnalysisModel analysis;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  const AnalysisCard({
    Key? key,
    required this.analysis,
    this.onTap,
    this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
                  CircleAvatar(
                    backgroundColor: _getTypeColor(analysis.type),
                    child: Icon(
                      _getTypeIcon(analysis.type),
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
                          analysis.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (analysis.description != null)
                          Text(
                            analysis.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildStatusChip(analysis.status),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(analysis.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (analysis.progress != null && analysis.status == 'processing')
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: analysis.progress! / 100,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                ],
              ),
              if (analysis.results != null && analysis.results!['summary'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    analysis.results!['summary'],
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;
    
    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
      case 'processing':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.hourglass_empty;
        break;
      case 'pending':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.schedule;
        break;
      case 'failed':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
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
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
