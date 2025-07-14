import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/models/analysis_type.dart';
import '../providers/ai_analysis_provider.dart';

class NewAnalysisScreen extends ConsumerStatefulWidget {
  const NewAnalysisScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NewAnalysisScreen> createState() => _NewAnalysisScreenState();
}

class _NewAnalysisScreenState extends ConsumerState<NewAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  AnalysisType _selectedType = AnalysisType.textClassification;
  String? _selectedFilePath;
  Map<String, dynamic> _parameters = {};
  bool _isSubmitting = false;
  
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
        title: const Text('New AI Analysis'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitAnalysis,
            child: const Text('Start', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Analysis Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analysis Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: AnalysisType.values.map((type) {
                        return ChoiceChip(
                          label: Text(_getTypeLabel(type)),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type;
                                _parameters = {};
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getTypeDescription(_selectedType),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Basic Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Analysis Title',
                        hintText: 'Enter a descriptive title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Add any additional notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Data Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Input',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDataInputSection(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Parameters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analysis Parameters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildParametersSection(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Advanced Options
            ExpansionTile(
              title: const Text('Advanced Options'),
              children: [
                SwitchListTile(
                  title: const Text('High Priority'),
                  subtitle: const Text('Process this analysis with higher priority'),
                  value: _parameters['highPriority'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _parameters['highPriority'] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Enable Caching'),
                  subtitle: const Text('Cache results for faster future access'),
                  value: _parameters['enableCaching'] ?? true,
                  onChanged: (value) {
                    setState(() {
                      _parameters['enableCaching'] = value;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Notification Preferences'),
                  subtitle: Text(_parameters['notificationPreference'] ?? 'On completion'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showNotificationPreferences,
                ),
              ],
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSubmitting ? null : _submitAnalysis,
        label: Text(_isSubmitting ? 'Processing...' : 'Start Analysis'),
        icon: _isSubmitting 
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.play_arrow),
      ),
    );
  }
  
  Widget _buildDataInputSection() {
    switch (_selectedType) {
      case AnalysisType.textClassification:
      case AnalysisType.sentimentAnalysis:
        return Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Text Input',
                hintText: 'Enter or paste your text here',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              onChanged: (value) => _parameters['text'] = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('OR'),
            const SizedBox(height: 16),
            _buildFileUploadSection(),
          ],
        );
        
      case AnalysisType.imageRecognition:
        return _buildFileUploadSection(
          allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
          fileType: FileType.image,
        );
        
      case AnalysisType.dataAnalytics:
        return _buildFileUploadSection(
          allowedExtensions: ['csv', 'xlsx', 'json'],
          fileType: FileType.custom,
        );
        
      default:
        return _buildFileUploadSection();
    }
  }
  
  Widget _buildFileUploadSection({
    List<String>? allowedExtensions,
    FileType fileType = FileType.any,
  }) {
    return Column(
      children: [
        if (_selectedFilePath != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.file_present),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedFilePath!.split('/').last,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedFilePath = null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(
          onPressed: _selectFile,
          icon: const Icon(Icons.upload_file),
          label: Text(_selectedFilePath == null ? 'Upload File' : 'Change File'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
  
  Widget _buildParametersSection() {
    switch (_selectedType) {
      case AnalysisType.textClassification:
        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Classification Model',
                border: OutlineInputBorder(),
              ),
              value: _parameters['model'] ?? 'bert-base',
              items: const [
                DropdownMenuItem(value: 'bert-base', child: Text('BERT Base')),
                DropdownMenuItem(value: 'bert-large', child: Text('BERT Large')),
                DropdownMenuItem(value: 'roberta', child: Text('RoBERTa')),
                DropdownMenuItem(value: 'distilbert', child: Text('DistilBERT')),
              ],
              onChanged: (value) => setState(() => _parameters['model'] = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Categories (comma-separated)',
                hintText: 'e.g., positive, negative, neutral',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _parameters['categories'] = value.split(','),
            ),
          ],
        );
        
      case AnalysisType.sentimentAnalysis:
        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
              ),
              value: _parameters['language'] ?? 'en',
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Spanish')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
                DropdownMenuItem(value: 'de', child: Text('German')),
                DropdownMenuItem(value: 'ko', child: Text('Korean')),
              ],
              onChanged: (value) => setState(() => _parameters['language'] = value),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include Emotion Analysis'),
              value: _parameters['includeEmotions'] ?? false,
              onChanged: (value) => setState(() => _parameters['includeEmotions'] = value),
            ),
          ],
        );
        
      case AnalysisType.imageRecognition:
        return Column(
          children: [
            CheckboxListTile(
              title: const Text('Object Detection'),
              value: _parameters['objectDetection'] ?? true,
              onChanged: (value) => setState(() => _parameters['objectDetection'] = value),
            ),
            CheckboxListTile(
              title: const Text('Face Recognition'),
              value: _parameters['faceRecognition'] ?? false,
              onChanged: (value) => setState(() => _parameters['faceRecognition'] = value),
            ),
            CheckboxListTile(
              title: const Text('Text Extraction (OCR)'),
              value: _parameters['textExtraction'] ?? false,
              onChanged: (value) => setState(() => _parameters['textExtraction'] = value),
            ),
          ],
        );
        
      default:
        return const Text('No additional parameters required');
    }
  }
  
  String _getTypeLabel(AnalysisType type) {
    switch (type) {
      case AnalysisType.textClassification:
        return 'Text Classification';
      case AnalysisType.sentimentAnalysis:
        return 'Sentiment Analysis';
      case AnalysisType.imageRecognition:
        return 'Image Recognition';
      case AnalysisType.dataAnalytics:
        return 'Data Analytics';
      case AnalysisType.predictiveModeling:
        return 'Predictive Modeling';
      case AnalysisType.anomalyDetection:
        return 'Anomaly Detection';
    }
  }
  
  String _getTypeDescription(AnalysisType type) {
    switch (type) {
      case AnalysisType.textClassification:
        return 'Classify text into predefined categories using machine learning';
      case AnalysisType.sentimentAnalysis:
        return 'Analyze emotional tone and sentiment in text content';
      case AnalysisType.imageRecognition:
        return 'Identify objects, faces, and text in images';
      case AnalysisType.dataAnalytics:
        return 'Analyze patterns and insights in structured data';
      case AnalysisType.predictiveModeling:
        return 'Build predictive models based on historical data';
      case AnalysisType.anomalyDetection:
        return 'Detect unusual patterns or outliers in data';
    }
  }
  
  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFilePath = result.files.first.path;
      });
    }
  }
  
  void _showNotificationPreferences() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Preferences'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('On completion'),
              value: 'On completion',
              groupValue: _parameters['notificationPreference'] ?? 'On completion',
              onChanged: (value) {
                setState(() => _parameters['notificationPreference'] = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('On error only'),
              value: 'On error only',
              groupValue: _parameters['notificationPreference'],
              onChanged: (value) {
                setState(() => _parameters['notificationPreference'] = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Never'),
              value: 'Never',
              groupValue: _parameters['notificationPreference'],
              onChanged: (value) {
                setState(() => _parameters['notificationPreference'] = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _submitAnalysis() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      await ref.read(aiAnalysisProvider.notifier).createAnalysis(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        filePath: _selectedFilePath,
        parameters: _parameters,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis started successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
