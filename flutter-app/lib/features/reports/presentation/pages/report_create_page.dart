import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signature/signature.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/roboflow_service.dart';
import '../../../../core/ai/ocr_service.dart';
import '../../../../core/ai/hybrid_analysis_manager.dart';
import '../../domain/entities/report.dart';
import '../providers/report_provider.dart';
import '../widgets/analysis_result_widget.dart';

class ReportCreatePage extends StatefulWidget {
  const ReportCreatePage({super.key});

  @override
  State<ReportCreatePage> createState() => _ReportCreatePageState();
}

class _ReportCreatePageState extends State<ReportCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // 이미지 관련
  final List<File> _selectedImages = [];
  final List<ObjectDetectionResult> _detectionResults = [];
  final List<OCRResult> _ocrResults = [];
  final ImagePicker _imagePicker = ImagePicker();

  // 위치 관련
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  // 폼 데이터
  String _selectedCategory = '기타';
  String _selectedPriority = '보통';
  bool _isProcessing = false;

  final List<String> _categories = [
    '도로/교통',
    '환경/위생',
    '상하수도',
    '전기/조명',
    '건축물',
    '공원/시설물',
    '공사/안전',
    '기타',
  ];

  final List<String> _priorities = ['긴급', '높음', '보통', '낮음'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('신고서 작성'),
            actions: [
              if (reportProvider.canSubmit && !reportProvider.isCreating)
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => _submitReport(context, reportProvider),
                ),
      ],
    );
  }

  /// 분석 결과 섹션
  Widget _buildAnalysisSection(BuildContext context, ReportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, size: 20),
                const SizedBox(width: 8),
                Text(
                  '분석 결과 (${provider.analysisResults.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            TextButton.icon(
              onPressed: provider.isAnalyzing 
                  ? null 
                  : () => provider.analyzeAllImages(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('전체 재분석'),
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 분석 결과 목록
        ...provider.analysisResults.entries.map((entry) {
          final imagePath = entry.key;
          final result = entry.value;
          
          return AnalysisResultWidget(
            analysisResult: result,
            onReanalyze: () => provider.reanalyzeImage(imagePath),
          );
        }),
        
        const SizedBox(height: 16),
      ],
    );
  }

  /// 분석 상태에 따른 색상 반환
  Color _getAnalysisStatusColor(HybridAnalysisResult result) {
    if (result.hasError) return Colors.red;
    
    final riskLevel = result.combinedRiskLevel;
    if (riskLevel >= 4) return Colors.red;
    if (riskLevel >= 3) return Colors.orange;
    if (riskLevel >= 2) return Colors.yellow[700]!;
    return Colors.green;
  }

  /// 분석 상태에 따른 아이콘 반환
  IconData _getAnalysisStatusIcon(HybridAnalysisResult result) {
    if (result.hasError) return Icons.error_outline;
    
    final riskLevel = result.combinedRiskLevel;
    if (riskLevel >= 4) return Icons.warning;
    if (riskLevel >= 3) return Icons.priority_high;
    if (riskLevel >= 2) return Icons.info_outline;
    return Icons.check_circle_outline;
  }

  Future<void> _submitReport(
    BuildContext context,
    ReportProvider provider,
  ) async {
    final success = await provider.submitReport();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('신고서가 성공적으로 제출되었습니다.'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(provider.error ?? '제출 중 오류가 발생했습니다.')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: '다시 시도',
            textColor: Colors.white,
            onPressed: () => _submitReport(context, provider),
          ),
        ),
      );
    }
  }
}
