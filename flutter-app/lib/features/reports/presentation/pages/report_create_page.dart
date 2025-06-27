import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signature/signature.dart';
import '../../../../core/ai/roboflow_service.dart';
import '../../../../core/ai/ocr_service.dart';

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
          ),
          body: reportProvider.isCreating
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('신고서를 제출하고 있습니다...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reportProvider.error != null)
                        _buildErrorCard(context, reportProvider),

                      _buildTitleField(context, reportProvider),
                      const SizedBox(height: 16),

                      _buildCategoryField(context, reportProvider),
                      const SizedBox(height: 16),

                      _buildContentField(context, reportProvider),
                      const SizedBox(height: 16),

                      _buildImageSection(context, reportProvider),
                      const SizedBox(height: 16),

                      _buildLocationSection(context, reportProvider),
                      const SizedBox(height: 32),

                      _buildSubmitButton(context, reportProvider),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildErrorCard(BuildContext context, ReportProvider provider) {
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
              child: Text(
                provider.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              onPressed: () {
                // TODO: 에러 메시지 클리어 기능 추가
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(BuildContext context, ReportProvider provider) {
    return Container(
      height: 56,
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: '제목 *',
          hintText: '신고 제목을 입력하세요',
          prefixIcon: Icon(Icons.title),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onChanged: provider.updateTitle,
        maxLength: 100,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _buildCategoryField(BuildContext context, ReportProvider provider) {
    return DropdownButtonFormField<ReportCategory>(
      value: provider.category,
      decoration: const InputDecoration(
        labelText: '카테고리',
        prefixIcon: Icon(Icons.category),
      ),
      items: ReportCategory.values.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(_getCategoryDisplayName(cat)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          provider.updateCategory(value);
        }
      },
    );
  }

  String _getCategoryDisplayName(ReportCategory category) {
    switch (category) {
      case ReportCategory.safety:
        return '안전';
      case ReportCategory.quality:
        return '품질';
      case ReportCategory.progress:
        return '진행상황';
      case ReportCategory.maintenance:
        return '유지보수';
      case ReportCategory.other:
        return '기타';
    }
  }

  Widget _buildContentField(BuildContext context, ReportProvider provider) {
    return Container(
      height: 160, // 멀티라인이므로 더 큰 높이
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: '내용 *',
          hintText: '상세 내용을 입력하세요',
          prefixIcon: Icon(Icons.description),
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        maxLines: 6,
        onChanged: provider.updateContent,
        maxLength: 1000,
        textInputAction: TextInputAction.newline,
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, ReportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_camera, size: 20),
            const SizedBox(width: 8),
            Text(
              '사진 첨부 (${provider.selectedImages.length}/5)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.selectedImages.isEmpty)
          _buildEmptyImageState(context, provider)
        else
          _buildImageGrid(context, provider),
      ],
    );
  }

  Widget _buildEmptyImageState(BuildContext context, ReportProvider provider) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showImagePickerDialog(context, provider),
          borderRadius: BorderRadius.circular(8),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('사진을 추가하려면 탭하세요', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, ReportProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...provider.selectedImages.asMap().entries.map((entry) {
          return _buildImageThumbnail(entry.value, entry.key, provider);
        }),
        if (provider.selectedImages.length < 5)
          _buildAddImageButton(context, provider),
      ],
    );
  }

  Widget _buildImageThumbnail(File image, int index, ReportProvider provider) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => provider.removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(BuildContext context, ReportProvider provider) {
    return GestureDetector(
      onTap: () => _showImagePickerDialog(context, provider),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.add_a_photo,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context, ReportProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  provider.pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  provider.pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationSection(BuildContext context, ReportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Text('위치 정보', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            FilledButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () => provider.getCurrentLocation(),
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(provider.isLoading ? '위치 확인 중...' : '현재 위치'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                provider.currentPosition != null
                    ? Icons.location_on
                    : Icons.location_off,
                color: provider.currentPosition != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  provider.locationText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ReportProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: provider.canSubmit && !provider.isCreating
            ? () => _submitReport(context, provider)
            : null,
        icon: provider.isCreating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
        label: Text(
          provider.isCreating ? '제출 중...' : '신고 제출',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
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
