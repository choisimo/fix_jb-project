import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/analysis_result.dart';
import '../../data/models/file_dto.dart';
import '../../data/providers/file_providers.dart';

class FileAnalysisResultWidget extends ConsumerWidget {
  final String taskId;
  final bool showSuggestedTags;
  final Function(List<String>)? onApplyTags;

  const FileAnalysisResultWidget({
    Key? key,
    required this.taskId,
    this.showSuggestedTags = true,
    this.onApplyTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisTaskProvider(taskId));

    return analysisState.when(
      data: (analysisStatus) {
        if (analysisStatus == null) {
          return const Center(child: Text('분석 정보를 찾을 수 없습니다'));
        }

        // Analysis is not completed yet
        if (analysisStatus.status != 'completed') {
          return _buildProgressWidget(context, analysisStatus);
        }

        // Analysis completed - get the result
        final result = analysisStatus.typedResult;
        if (result == null) {
          return const Center(child: Text('분석 결과가 없습니다'));
        }

        return _buildResultWidget(context, result);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('오류: $error'),
      ),
    );
  }

  Widget _buildProgressWidget(BuildContext context, AnalysisStatusResponse status) {
    switch (status.status) {
      case 'pending':
        return const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('분석 대기 중...'),
          ],
        );

      case 'in_progress':
        final progress = status.progress ?? 0.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이미지 분석 중...${progress > 0 ? ' (${(progress * 100).toStringAsFixed(0)}%)' : ''}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress > 0 ? progress : null),
          ],
        );

      case 'failed':
        return Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '분석 실패: ${status.error ?? "알 수 없는 오류"}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );

      default:
        return Text('상태: ${status.status}');
    }
  }

  Widget _buildResultWidget(BuildContext context, AnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Analysis header
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              '이미지 분석 완료',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Detected labels
        if (result.detectedLabels.isNotEmpty) ...[
          Text(
            '감지된 항목:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.detectedLabels
                .map((label) => Chip(
                      label: Text(label),
                      backgroundColor: Colors.blue.shade100,
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Suggested tags (if enabled)
        if (showSuggestedTags && result.suggestedTags.isNotEmpty) ...[
          Row(
            children: [
              Text(
                '추천 태그:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              if (onApplyTags != null)
                TextButton(
                  onPressed: () => onApplyTags!(result.suggestedTags),
                  child: const Text('모두 적용'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.suggestedTags
                .map((tag) => ActionChip(
                      label: Text(tag),
                      onPressed: () => onApplyTags?.call([tag]),
                      backgroundColor: Colors.green.shade100,
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Confidence
        Text(
          '신뢰도: ${(result.confidence * 100).toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        
        // Analysis time
        Text(
          '분석 시간: ${_formatDateTime(result.analysisTime)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
