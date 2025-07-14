import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/image_analysis_result.dart';

class AIAnalysisResultWidget extends StatelessWidget {
  final AIAnalysisResult? result;
  
  const AIAnalysisResultWidget({
    Key? key,
    required this.result,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const Center(
        child: Text('No AI analysis result available'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analysis summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Analysis Results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Analysis Type', result!.analysisType),
                  _buildInfoRow(
                    'Confidence',
                    '${(result!.confidence * 100).toStringAsFixed(1)}%',
                    valueColor: _getConfidenceColor(result!.confidence),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Detected objects
          if (result!.detectedObjects != null && 
              result!.detectedObjects!.isNotEmpty) ...[
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
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result!.detectedObjects!.map((object) {
                        return Chip(
                          label: Text(object),
                          avatar: const Icon(Icons.check_circle, size: 18),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Extracted data
          if (result!.extractedData.isNotEmpty) ...[
            Text(
              'Extracted Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...result!.extractedData.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(_formatFieldName(entry.key)),
                  subtitle: Text(
                    _formatValue(entry.value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: entry.value.toString()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${_formatFieldName(entry.key)} copied'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const Icon(Icons.expand_more),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildValueWidget(entry.value),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          
          // Metadata
          if (result!.metadata != null && result!.metadata!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Metadata',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...result!.metadata!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildInfoRow(
                          _formatFieldName(entry.key),
                          _formatValue(entry.value),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildValueWidget(dynamic value) {
    if (value is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    '${_formatFieldName(entry.key.toString())}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(_formatValue(entry.value)),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.arrow_right, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(item.toString())),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return SelectableText(value.toString());
    }
  }
  
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return Colors.green;
    if (confidence >= 0.7) return Colors.orange;
    return Colors.red;
  }
  
  String _formatFieldName(String fieldName) {
    return fieldName
        .split('_')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }
  
  String _formatValue(dynamic value) {
    if (value is Map || value is List) {
      return '${value.runtimeType} (${value.length} items)';
    }
    return value.toString();
  }
}
