import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../domain/models/report.dart';
import '../../image_analysis/domain/services/image_analysis_service.dart';
import '../../image_analysis/domain/models/image_analysis_result.dart';
import '../../../core/providers/service_provider.dart';
import '../../maps/presentation/widgets/naver_map_widget.dart';
import '../../maps/presentation/providers/map_provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReportType _selectedType = ReportType.other;
  Priority _selectedPriority = Priority.medium;
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;
  bool _isAnalyzing = false;
  ComprehensiveAnalysisResult? _analysisResult;
  String? _analysisError;
  NLatLng? _currentLocation;
  String? _currentAddress;

  late final ImageAnalysisService _analysisService;

  @override
  void initState() {
    super.initState();
    // Dio provider를 사용하여 분석 서비스 초기화
        WidgetsBinding.instance.addPostFrameCallback((_) {
      final dio = ref.read(dioProvider);
      _analysisService = ImageAnalysisService(dio);
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _submitReport,
              child: const Text('Submit'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 선택 섹션
              _buildImageSection(),
              const SizedBox(height: 24),

              // AI 분석 결과 섹션
                            if (_analysisResult != null || _isAnalyzing || _analysisError != null)
                _buildAnalysisSection(),
              const SizedBox(height: 24),

              // 지도 섹션
              Text('Location', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (_currentLocation != null)
                Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: NaverMapWidget(
                        initialCameraPosition: NCameraPosition(
                          target: _currentLocation!,
                          zoom: 15,
                        ),
                        onMapTapped: (latlng) {
                          _updateLocationAndAddress(latlng);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Coords: ${_currentLocation!.latitude.toStringAsFixed(5)}, ${_currentLocation!.longitude.toStringAsFixed(5)}\nAddress: ${_currentAddress ?? 'Loading...'}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              else
                const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),


              // 제목 입력
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  border: const OutlineInputBorder(),
                  suffixIcon: _analysisResult != null
                      ? IconButton(
                          icon: const Icon(Icons.auto_fix_high, color: Colors.blue),
                          onPressed: _autoFillTitle,
                          tooltip: 'Auto-fill from AI analysis',
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 타입 선택
              DropdownButtonFormField<ReportType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Report Type *',
                  border: const OutlineInputBorder(),
                  suffixIcon: _analysisResult != null
                      ? IconButton(
                          icon: const Icon(Icons.auto_fix_high, color: Colors.blue),
                          onPressed: _autoFillType,
                          tooltip: 'Auto-detect from AI analysis',
                        )
                      : null,
                ),
                items: ReportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 우선순위 선택
              DropdownButtonFormField<Priority>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: const OutlineInputBorder(),
                  suffixIcon: _analysisResult != null
                      ? IconButton(
                          icon: const Icon(Icons.auto_fix_high, color: Colors.blue),
                          onPressed: _autoFillPriority,
                          tooltip: 'Auto-set from AI analysis',
                        )
                      : null,
                ),
                items: Priority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(_getPriorityDisplayName(priority)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 설명 입력
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  suffixIcon: _analysisResult != null
                      ? IconButton(
                          icon: const Icon(Icons.auto_fix_high, color: Colors.blue),
                          onPressed: _autoFillDescription,
                          tooltip: 'Auto-fill from AI analysis',
                        )
                      : null,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 자동 채우기 버튼
              if (_analysisResult != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _autoFillAll,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Auto-fill All Fields'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // 분석 신뢰도 표시
              if (_analysisResult != null)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Analysis Confidence',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              Text(
                                '${(_analysisResult!.overallConfidence * 100).toInt()}% - ${_getConfidenceLevel(_analysisResult!.overallConfidence)}',
                                style: TextStyle(color: Colors.blue.shade600),
                              ),
                            ],
                          ),
                        ),
                        CircularProgressIndicator(
                          value: _analysisResult!.overallConfidence,
                          backgroundColor: Colors.blue.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Images',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_selectedImages.isNotEmpty && !_isAnalyzing)
              TextButton.icon(
                onPressed: _analyzeImages,
                icon: const Icon(Icons.psychology, size: 20),
                label: const Text('Analyze with AI'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 이미지 그리드
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              final image = _selectedImages[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(image.path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_isAnalyzing)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        const SizedBox(height: 12),

        // 이미지 추가 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isAnalyzing 
                      ? Icons.psychology 
                      : _analysisError != null 
                          ? Icons.error_outline 
                          : Icons.check_circle_outline,
                  color: _isAnalyzing 
                      ? Colors.blue 
                      : _analysisError != null 
                          ? Colors.red 
                          : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  _isAnalyzing 
                      ? 'Analyzing images...' 
                      : _analysisError != null 
                          ? 'Analysis failed' 
                          : 'AI Analysis Complete',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (_isAnalyzing)
              const LinearProgressIndicator()
            else if (_analysisError != null)
              Text(
                _analysisError!,
                style: const TextStyle(color: Colors.red),
              )
            else if (_analysisResult != null)
              _buildAnalysisResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    if (_analysisResult == null) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔍 AI Analysis:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(_analysisResult!.aiAgent.sceneDescription),
        const SizedBox(height: 8),
        
        if (_analysisResult!.ocr.hasText) ...[
          const Text('📝 Detected Text:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: _analysisResult!.ocr.texts.take(3).map((text) => 
              Chip(
                label: Text(text, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue.shade50,
              )
            ).toList(),
          ),
          const SizedBox(height: 8),
        ],
        
        const Text('🎯 Detected Objects:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (_analysisResult!.roboflow.predictions.isNotEmpty)
          Wrap(
            spacing: 4,
            children: _analysisResult!.roboflow.predictions.map((pred) => 
              Chip(
                label: Text('${pred.className} (${(pred.confidence * 100).toInt()}%)', 
                            style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.green.shade50,
                avatar: CircleAvatar(
                  backgroundColor: _getConfidenceColor(pred.confidence),
                  radius: 6,
                ),
              )
            ).toList(),
          )
        else
          Text('No objects detected', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        
        const Text('💡 Priority:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPriorityColor(_analysisResult!.aiAgent.priorityRecommendation).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getPriorityColor(_analysisResult!.aiAgent.priorityRecommendation),
              width: 1,
            ),
          ),
          child: Text(
            '${_analysisResult!.aiAgent.priorityRecommendation.toUpperCase()} priority recommended',
            style: TextStyle(
              color: _getPriorityColor(_analysisResult!.aiAgent.priorityRecommendation),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        const Text('💡 Suggestions:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Use the auto-fill buttons to populate form fields based on AI analysis.'),
      ],
    );
  }

  Future<void> _selectImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        _analysisResult = null;
        _analysisError = null;
      });
      _analyzeImages();
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
        _analysisResult = null;
        _analysisError = null;
      });
      _analyzeImages();
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isEmpty) {
        _analysisResult = null;
        _analysisError = null;
      }
    });
  }

  Future<void> _analyzeImages() async {
    if (_selectedImages.isEmpty) return;
    
    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });
    
    try {
      // 첫 번째 이미지를 분석 (multiple image analysis can be added later)
      final imageFile = File(_selectedImages.first.path);
      final result = await _analysisService.performComprehensiveAnalysis(imageFile);
      
      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
      
      // 분석 완료 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI analysis complete! Confidence: ${(result.overallConfidence * 100).toInt()}%',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Auto-fill',
              textColor: Colors.white,
              onPressed: _autoFillAll,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _analysisError = 'Failed to analyze image: ${e.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  void _autoFillTitle() {
    if (_analysisResult?.aiAgent.sceneDescription.isNotEmpty == true) {
      _titleController.text = _generateTitleFromAnalysis();
    }
  }

  void _autoFillType() {
    final detectedType = _detectReportType();
    if (detectedType != null) {
      setState(() {
        _selectedType = detectedType;
      });
    }
  }

  void _autoFillPriority() {
    final detectedPriority = _detectPriority();
    if (detectedPriority != null) {
      setState(() {
        _selectedPriority = detectedPriority;
      });
    }
  }

  void _autoFillDescription() {
    if (_analysisResult?.aiAgent.sceneDescription.isNotEmpty == true) {
      _descriptionController.text = _generateDescriptionFromAnalysis();
    }
  }

  void _autoFillAll() {
    _autoFillTitle();
    _autoFillType();
    _autoFillPriority();
    _autoFillDescription();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form fields auto-filled from AI analysis!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _generateTitleFromAnalysis() {
    final analysisResult = _analysisResult!;
    final description = analysisResult.aiAgent.sceneDescription;
    final detectedObjects = analysisResult.roboflow.predictions;
    
    if (detectedObjects.isNotEmpty) {
      final mainObject = detectedObjects.first.className;
      return '${mainObject.toUpperCase()} Report - ${DateTime.now().toString().substring(0, 10)}';
    }
    
    if (description.contains('pothole') || description.contains('포트홀')) {
      return 'Pothole Report - ${DateTime.now().toString().substring(0, 10)}';
    } else if (description.contains('trash') || description.contains('쓰레기')) {
      return 'Trash/Litter Report';
    } else if (description.contains('light') || description.contains('가로등')) {
      return 'Street Light Issue';
    } else if (description.contains('graffiti')) {
      return 'Graffiti Report';
    } else if (description.contains('road') || description.contains('도로')) {
      return 'Road Damage Report';
    }
    return 'Infrastructure Issue Report';
  }

  ReportType? _detectReportType() {
    final description = _analysisResult!.aiAgent.sceneDescription.toLowerCase();
    final detectedObjects = _analysisResult!.roboflow.predictions;
    
    // 먼저 객체 감지 결과로 판단
    if (detectedObjects.isNotEmpty) {
      final mainObject = detectedObjects.first.className.toLowerCase();
      if (mainObject.contains('pothole')) return ReportType.pothole;
      if (mainObject.contains('trash')) return ReportType.trash;
      if (mainObject.contains('light')) return ReportType.streetLight;
      if (mainObject.contains('graffiti')) return ReportType.graffiti;
      if (mainObject.contains('road')) return ReportType.roadDamage;
      if (mainObject.contains('construction')) return ReportType.construction;
    }
    
    // 설명으로 판단
    if (description.contains('pothole') || description.contains('포트홀')) {
      return ReportType.pothole;
    } else if (description.contains('trash') || description.contains('쓰레기') || description.contains('litter')) {
      return ReportType.trash;
    } else if (description.contains('light') || description.contains('가로등')) {
      return ReportType.streetLight;
    } else if (description.contains('graffiti')) {
      return ReportType.graffiti;
    } else if (description.contains('road') || description.contains('도로') || description.contains('damage')) {
      return ReportType.roadDamage;
    } else if (description.contains('construction') || description.contains('공사')) {
      return ReportType.construction;
    }
    
    return null;
  }

  Priority? _detectPriority() {
    final description = _analysisResult?.aiAgent.sceneDescription ?? '';
    final priority = _analysisResult!.aiAgent.priorityRecommendation.toLowerCase();
    
    if (priority.contains('urgent')) {
      return Priority.urgent;
    } else if (priority.contains('high')) {
      return Priority.high;
    } else if (priority.contains('medium')) {
      return Priority.medium;
    } else if (priority.contains('low')) {
      return Priority.low;
    }
    
    return Priority.medium; // Default
  }

  String _generateDescriptionFromAnalysis() {
    final aiAgent = _analysisResult!.aiAgent;
    final ocr = _analysisResult!.ocr;
    final roboflow = _analysisResult!.roboflow;
    final integrated = _analysisResult!.integratedAnalysis;
    
    String description = '';
    
    if (aiAgent.sceneDescription.isNotEmpty) {
      description += 'AI Analysis: ${aiAgent.sceneDescription}\n\n';
    }
    
    if (roboflow.predictions.isNotEmpty) {
      description += 'Detected Objects: ${roboflow.predictions.map((p) => '${p.className} (${(p.confidence * 100).toInt()}%)').join(', ')}\n\n';
    }
    
    if (ocr.hasText && ocr.texts.isNotEmpty) {
      description += 'Detected Text: ${ocr.texts.join(', ')}\n\n';
    }
    
    if (integrated.extractedInformation.isNotEmpty) {
      description += 'Extracted Information:\n';
      integrated.extractedInformation.forEach((key, value) {
        description += '- $key: $value\n';
      });
      description += '\n';
    }
    
    description += 'Analysis Confidence: ${(_analysisResult!.overallConfidence * 100).toInt()}%\n';
    description += 'Priority: ${aiAgent.priorityRecommendation.toUpperCase()}\n';
    description += 'Timestamp: ${DateTime.now().toString()}\n\n';
    description += 'Additional notes: [Add any additional observations]';
    
    return description;
  }

  String _getConfidenceLevel(double confidence) {
    if (confidence >= 0.8) return 'High Confidence';
    if (confidence >= 0.6) return 'Medium Confidence';
    if (confidence >= 0.4) return 'Low Confidence';
    return 'Very Low Confidence';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    if (confidence >= 0.4) return Colors.yellow.shade700;
    return Colors.red;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDisplayName(ReportType type) {
    switch (type) {
      case ReportType.pothole:
        return 'Pothole';
      case ReportType.streetLight:
        return 'Street Light';
      case ReportType.trash:
        return 'Trash';
      case ReportType.graffiti:
        return 'Graffiti';
      case ReportType.roadDamage:
        return 'Road Damage';
      case ReportType.construction:
        return 'Construction';
      case ReportType.other:
        return 'Other';
    }
  }

  String _getPriorityDisplayName(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
    }
  }

    void _getCurrentLocation() async {
    try {
      final position = await ref.read(mapServiceProvider).getCurrentLocation();
      final newLocation = NLatLng(position.latitude, position.longitude);
      _updateLocationAndAddress(newLocation);
    } catch (e) {
      print('Error getting location: $e');
      final defaultLocation = const NLatLng(37.5665, 126.9780);
      _updateLocationAndAddress(defaultLocation);
    }
  }

  void _updateLocationAndAddress(NLatLng location) async {
    setState(() {
      _currentLocation = location;
      _currentAddress = 'Loading address...';
    });
    try {
      final address = await ref.read(mapServiceProvider).getAddressFromCoordinates(location);
      if (mounted) {
        setState(() {
          _currentAddress = address;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Could not fetch address.';
        });
      }
    }
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 시뮬레이션: 실제로는 API 호출
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report created successfully!')),
        );
        
        context.pop();
      });
    }
  }
}