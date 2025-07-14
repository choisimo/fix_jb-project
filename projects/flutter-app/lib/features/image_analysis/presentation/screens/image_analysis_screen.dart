import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../providers/image_analysis_provider.dart';
import '../widgets/ocr_result_widget.dart';
import '../widgets/ai_analysis_result_widget.dart';

class ImageAnalysisScreen extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>)? onDataExtracted;
  final String? analysisType; // 'ocr', 'ai', or 'both'
  
  const ImageAnalysisScreen({
    Key? key,
    this.onDataExtracted,
    this.analysisType = 'both',
  }) : super(key: key);
  
  @override
  ConsumerState<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends ConsumerState<ImageAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.analysisType == 'both' ? 2 : 1,
      vsync: this,
    );
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }
  
  @override
  void dispose() {
    _cameraController?.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(imageAnalysisProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Analysis'),
        bottom: widget.analysisType == 'both'
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'OCR Analysis'),
                  Tab(text: 'AI Analysis'),
                ],
              )
            : null,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearSelection,
            ),
        ],
      ),
      body: _selectedImage == null
          ? _buildImageSelectionView()
          : _buildAnalysisView(analysisState),
      floatingActionButton: _selectedImage != null && 
          analysisState.maybeWhen(
            data: (result) => result != null,
            orElse: () => false,
          )
          ? FloatingActionButton.extended(
              onPressed: _applyExtractedData,
              icon: const Icon(Icons.check),
              label: const Text('Apply to Form'),
            )
          : null,
    );
  }
  
  Widget _buildImageSelectionView() {
    return Column(
      children: [
        // Camera preview or image capture area
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.black,
            child: _isCameraInitialized && _cameraController != null
                ? Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      // Overlay for document scanning guide
                      CustomPaint(
                        size: Size.infinite,
                        painter: DocumentGuidePainter(),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Camera not available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        
        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Select or capture an image for analysis',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onPressed: _pickFromGallery,
                  ),
                  if (_isCameraInitialized)
                    _buildActionButton(
                      icon: Icons.camera,
                      label: 'Capture',
                      onPressed: _capturePhoto,
                      isPrimary: true,
                    ),
                  _buildActionButton(
                    icon: Icons.upload_file,
                    label: 'Upload',
                    onPressed: _pickFile,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAnalysisView(AsyncValue<ImageAnalysisResult?> analysisState) {
    return Column(
      children: [
        // Image preview
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[200],
          child: Stack(
            children: [
              Image.file(
                _selectedImage!,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
              if (_isAnalyzing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Analysis options
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _performOCR,
                  icon: const Icon(Icons.text_fields),
                  label: const Text('Extract Text (OCR)'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _performAIAnalysis,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('AI Analysis'),
                ),
              ),
            ],
          ),
        ),
        
        // Results
        Expanded(
          child: analysisState.when(
            data: (result) {
              if (result == null) {
                return const Center(
                  child: Text('Select an analysis type to begin'),
                );
              }
              
              return widget.analysisType == 'both'
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        OCRResultWidget(result: result.ocrResult),
                        AIAnalysisResultWidget(result: result.aiResult),
                      ],
                    )
                  : widget.analysisType == 'ocr'
                      ? OCRResultWidget(result: result.ocrResult)
                      : AIAnalysisResultWidget(result: result.aiResult);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Analysis failed: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(imageAnalysisProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: isPrimary ? Theme.of(context).primaryColor : null,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
  
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }
  
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() => _selectedImage = File(image.path));
    } catch (e) {
      _showErrorSnackBar('Failed to capture photo: $e');
    }
  }
  
  Future<void> _pickFile() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      
      if (file != null) {
        setState(() => _selectedImage = File(file.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: $e');
    }
  }
  
  Future<void> _performOCR() async {
    if (_selectedImage == null) return;
    
    setState(() => _isAnalyzing = true);
    
    try {
      await ref.read(imageAnalysisProvider.notifier).performOCR(_selectedImage!);
    } catch (e) {
      _showErrorSnackBar('OCR failed: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }
  
  Future<void> _performAIAnalysis() async {
    if (_selectedImage == null) return;
    
    setState(() => _isAnalyzing = true);
    
    try {
      await ref.read(imageAnalysisProvider.notifier).performAIAnalysis(
        _selectedImage!,
        analysisType: widget.analysisType ?? 'both',
      );
    } catch (e) {
      _showErrorSnackBar('AI Analysis failed: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }
  
  void _applyExtractedData() {
    final result = ref.read(imageAnalysisProvider).value;
    if (result == null) return;
    
    final extractedData = <String, dynamic>{};
    
    // Combine OCR and AI results
    if (result.ocrResult != null) {
      extractedData.addAll(result.ocrResult!.extractedFields);
    }
    
    if (result.aiResult != null) {
      extractedData.addAll(result.aiResult!.extractedData);
    }
    
    if (widget.onDataExtracted != null) {
      widget.onDataExtracted!(extractedData);
      Navigator.pop(context);
    } else {
      // Show extracted data
      _showExtractedDataDialog(extractedData);
    }
  }
  
  void _showExtractedDataDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extracted Data'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${entry.key}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(entry.value.toString()),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, data);
            },
            child: const Text('Use Data'),
          ),
        ],
      ),
    );
  }
  
  void _clearSelection() {
    setState(() {
      _selectedImage = null;
      _isAnalyzing = false;
    });
    ref.invalidate(imageAnalysisProvider);
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class DocumentGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.9,
      height: size.height * 0.7,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      paint,
    );
    
    // Corner guides
    final cornerLength = 30.0;
    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];
    
    paint
      ..color = Colors.white
      ..strokeWidth = 3.0;
    
    for (var i = 0; i < corners.length; i++) {
      final corner = corners[i];
      final isLeft = i % 2 == 0;
      final isTop = i < 2;
      
      // Horizontal line
      canvas.drawLine(
        corner,
        corner + Offset(isLeft ? cornerLength : -cornerLength, 0),
        paint,
      );
      
      // Vertical line
      canvas.drawLine(
        corner,
        corner + Offset(0, isTop ? cornerLength : -cornerLength),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
