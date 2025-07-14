import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/image_analysis_result.dart';

class OCRResultWidget extends StatelessWidget {
  final OCRResult? result;
  
  const OCRResultWidget({
    Key? key,
    required this.result,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const Center(
        child: Text('No OCR result available'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confidence score
          Card(
            child: ListTile(
              leading: Icon(
                Icons.verified,
                color: _getConfidenceColor(result!.confidence),
              ),
              title: const Text('Confidence Score'),
              trailing: Text(
                '${(result!.confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getConfidenceColor(result!.confidence),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Raw text
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Extracted Text',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: result!.rawText),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Text copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    result!.rawText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Extracted fields
          if (result!.extractedFields.isNotEmpty) ...[
            Text(
              'Extracted Fields',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...result!.extractedFields.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(_formatFieldName(entry.key)),
                  subtitle: Text(entry.value.toString()),
                  trailing: IconButton(
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
                ),
              );
            }).toList(),
          ],
          
          // Text blocks visualization
          if (result!.textBlocks != null && result!.textBlocks!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Detected Text Regions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: result!.textBlocks!.length,
                itemBuilder: (context, index) {
                  final block = result!.textBlocks![index];
                  return Card(
                    margin: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Region ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              block.text,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confidence: ${(block.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
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
}
