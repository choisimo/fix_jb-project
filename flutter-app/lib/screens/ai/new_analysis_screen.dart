import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/ai_analysis_provider.dart';
import '../../models/ai_analysis.dart';
import '../../widgets/common/loading_overlay.dart';

class NewAnalysisScreen extends StatefulWidget {
  const NewAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<NewAnalysisScreen> createState() => _NewAnalysisScreenState();
}

class _NewAnalysisScreenState extends State<NewAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'text';
  String _selectedModel = 'gpt-4';
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _analysisTypes = [
    {'value': 'text', 'label': '텍스트 분석', 'icon': Icons.text_fields},
    {'value': 'image', 'label': '이미지 분석', 'icon': Icons.image},
    {'value': 'document', 'label': '문서 분석', 'icon': Icons.description},
    {'value': 'sentiment', 'label': '감정 분석', 'icon': Icons.sentiment_satisfied},
    {'value': 'summary', 'label': '요약', 'icon': Icons.summarize},
  ];

  final List<Map<String, String>> _aiModels = [
    {'value': 'gpt-4', 'label': 'GPT-4'},
    {'value': 'gpt-3.5-turbo', 'label': 'GPT-3.5 Turbo'},
    {'value': 'claude-3', 'label': 'Claude 3'},
    {'value': 'custom', 'label': '사용자 정의 모델'},
  ];

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
        title: const Text('새 AI 분석'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnalysisTypeSection(),
                const SizedBox(height: 24),
                _buildFormFields(),
                const SizedBox(height: 24),
                _buildModelSelection(),
                const SizedBox(height: 24),
                _buildFileUploadSection(),
                const SizedBox(height: 24),
                _buildAdvancedOptions(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '분석 유형',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _analysisTypes.map((type) {
            final isSelected = _selectedType == type['value'];
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : null,
                  ),
                  const SizedBox(width: 4),
                  Text(type['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type['value'] as String;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: '분석 제목',
            hintText: '분석 작업의 제목을 입력하세요',
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '제목을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '설명',
            hintText: '분석하고자 하는 내용을 자세히 설명해주세요',
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '설명을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI 모델 선택',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedModel,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.psychology),
          ),
          items: _aiModels.map((model) {
            return DropdownMenuItem(
              value: model['value'],
              child: Text(model['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedModel = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '파일 업로드',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: _pickFiles,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 8),
                      const Text('파일을 선택하거나 드래그 앤 드롭하세요'),
                      const SizedBox(height: 4),
                      Text(
                        _getAcceptedFileTypes(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedFiles.isNotEmpty) ...[
                const Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    return ListTile(
                      leading: Icon(_getFileIcon(file.extension)),
                      title: Text(file.name),
                      subtitle: Text(_formatFileSize(file.size)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedFiles.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return ExpansionTile(
      title: const Text(
        '고급 옵션',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        SwitchListTile(
          title: const Text('실시간 분석'),
          subtitle: const Text('분석 진행 상황을 실시간으로 확인합니다'),
          value: false,
          onChanged: (value) {},
        ),
        SwitchListTile(
          title: const Text('자동 요약'),
          subtitle: const Text('분석 결과를 자동으로 요약합니다'),
          value: true,
          onChanged: (value) {},
        ),
        ListTile(
          title: const Text('신뢰도 임계값'),
          subtitle: Slider(
            value: 0.8,
            min: 0.5,
            max: 1.0,
            divisions: 10,
            label: '80%',
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _submitAnalysis,
        child: const Text(
          '분석 시작',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  String _getAcceptedFileTypes() {
    switch (_selectedType) {
      case 'image':
        return 'JPG, PNG, GIF (최대 10MB)';
      case 'document':
        return 'PDF, DOCX, TXT (최대 50MB)';
      default:
        return 'TXT, CSV, JSON (최대 10MB)';
    }
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _getAllowedExtensions(),
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  List<String> _getAllowedExtensions() {
    switch (_selectedType) {
      case 'image':
        return ['jpg', 'jpeg', 'png', 'gif'];
      case 'document':
        return ['pdf', 'doc', 'docx', 'txt'];
      default:
        return ['txt', 'csv', 'json'];
    }
  }

  Future<void> _submitAnalysis() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<AIAnalysisProvider>();
      
      final analysisRequest = AnalysisRequest(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        model: _selectedModel,
        files: _selectedFiles,
      );

      await provider.createAnalysis(analysisRequest);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('분석이 시작되었습니다'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
