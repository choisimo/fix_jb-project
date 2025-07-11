import 'package:flutter/material.dart';
import '../../../../core/ai/hybrid_analysis_manager.dart';

/// 분석 결과 표시 위젯
class AnalysisResultWidget extends StatelessWidget {
  final HybridAnalysisResult analysisResult;
  final VoidCallback? onReanalyze;

  const AnalysisResultWidget({
    super.key,
    required this.analysisResult,
    this.onReanalyze,
  });

  @override
  Widget build(BuildContext context) {
    if (!analysisResult.isSuccessful) {
      return _buildErrorCard(context);
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: _buildStatusIcon(),
        title: Text(
          '분석 결과',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          analysisResult.summary,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // OCR 결과
                if (analysisResult.ocrResult?.hasText == true)
                  _buildOCRSection(context),
                
                // 객체 감지 결과
                if (analysisResult.detectionResult?.hasDetections == true)
                  _buildDetectionSection(context),
                
                // AI 분석 결과
                if (analysisResult.aiAnalysisResult?.isSuccessful == true)
                  _buildAIAnalysisSection(context),
                
                // 처리 시간 및 액션
                _buildFooterSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    Color color;
    IconData icon;
    
    if (analysisResult.hasError) {
      color = Colors.red;
      icon = Icons.error_outline;
    } else if (analysisResult.isSuccessful) {
      // 위험도에 따른 색상
      final riskLevel = analysisResult.combinedRiskLevel;
      if (riskLevel >= 4) {
        color = Colors.red;
        icon = Icons.warning;
      } else if (riskLevel >= 3) {
        color = Colors.orange;
        icon = Icons.priority_high;
      } else if (riskLevel >= 2) {
        color = Colors.yellow[700]!;
        icon = Icons.info_outline;
      } else {
        color = Colors.green;
        icon = Icons.check_circle_outline;
      }
    } else {
      color = Colors.grey;
      icon = Icons.help_outline;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '분석 실패',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (analysisResult.error != null)
                    Text(
                      analysisResult.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (onReanalyze != null)
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                onPressed: onReanalyze,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOCRSection(BuildContext context) {
    final ocrResult = analysisResult.ocrResult!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '🔤 텍스트 추출', Icons.text_fields),
        const SizedBox(height: 8),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '추출된 텍스트:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                ocrResult.fullText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              
              if (ocrResult.extractedInfo.hasUsefulInfo) ...[
                const SizedBox(height: 12),
                Text(
                  '핵심 정보:',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  ocrResult.extractedInfo.formattedSummary,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetectionSection(BuildContext context) {
    final detectionResult = analysisResult.detectionResult!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '🔍 객체 감지', Icons.camera_alt),
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: detectionResult.detections.map((detection) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: _getConfidenceColor(detection.confidence).withOpacity(0.2),
                child: Text(
                  '${(detection.confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getConfidenceColor(detection.confidence),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              label: Text(detection.name),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAIAnalysisSection(BuildContext context) {
    final aiResult = analysisResult.aiAnalysisResult!;
    final analysis = aiResult.analysis;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '🤖 AI 종합 분석', Icons.psychology),
        const SizedBox(height: 8),
        
        // 요약
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            analysis.summary,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 위험도 및 긴급도
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                context,
                '위험도',
                analysis.riskLevelText,
                _getRiskColor(analysis.riskLevel),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoChip(
                context,
                '긴급도',
                analysis.urgencyText,
                _getUrgencyColor(analysis.urgency),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 담당 부서
        _buildInfoChip(
          context,
          '담당 부서',
          analysis.responsibleDepartment,
          Theme.of(context).colorScheme.primary,
        ),
        
        const SizedBox(height: 12),
        
        // 추천 조치사항
        if (analysis.recommendations.isNotEmpty) ...[
          Text(
            '추천 조치사항:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          ...analysis.recommendations.map((recommendation) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_right,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '처리 시간: ${analysisResult.totalProcessingTime}ms',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (onReanalyze != null)
          TextButton.icon(
            onPressed: onReanalyze,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('재분석'),
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getRiskColor(int riskLevel) {
    switch (riskLevel) {
      case 5: return Colors.red;
      case 4: return Colors.deepOrange;
      case 3: return Colors.orange;
      case 2: return Colors.yellow[700]!;
      case 1: return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getUrgencyColor(ReportUrgency urgency) {
    switch (urgency) {
      case ReportUrgency.immediate: return Colors.red;
      case ReportUrgency.urgent: return Colors.orange;
      case ReportUrgency.week: return Colors.blue;
      case ReportUrgency.month: return Colors.green;
    }
  }
}