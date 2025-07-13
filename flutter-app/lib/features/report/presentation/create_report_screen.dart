import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jb_report_app/features/report/presentation/controllers/create_report_controller.dart';
import 'package:jb_report_app/features/report/presentation/widgets/image_picker_widget.dart';
import 'package:jb_report_app/features/report/presentation/widgets/location_widget.dart';
import 'package:jb_report_app/features/report/presentation/widgets/ai_analysis_widget.dart';
import 'package:jb_report_app/features/report/domain/models/report.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createReportControllerProvider.notifier).getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createReportControllerProvider);

    ref.listen(createReportControllerProvider, (previous, next) {
      if (previous?.isSubmitting == true && next.isSubmitting == false) {
        if (next.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully!')),
          );
          context.pop();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
        centerTitle: true,
        actions: [
          if (createState.isFormValid && !createState.isSubmitting)
            TextButton(
              onPressed: () async {
                await ref.read(createReportControllerProvider.notifier).createReport();
              },
              child: const Text('Submit'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter report title',
                  border: const OutlineInputBorder(),
                  errorText: createState.fieldErrors?['title'],
                ),
                onChanged: (value) {
                  ref.read(createReportControllerProvider.notifier).updateTitle(value);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (value.trim().length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Type selection
              DropdownButtonFormField<ReportType>(
                value: createState.type,
                decoration: InputDecoration(
                  labelText: 'Report Type *',
                  border: const OutlineInputBorder(),
                  errorText: createState.fieldErrors?['type'],
                ),
                items: ReportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getTypeIcon(type), size: 20),
                        const SizedBox(width: 8),
                        Text(_getTypeDisplayName(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(createReportControllerProvider.notifier).updateType(value);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Report type is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Priority selection
              DropdownButtonFormField<Priority>(
                value: createState.priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: Priority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_getPriorityDisplayName(priority)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(createReportControllerProvider.notifier).updatePriority(value);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe the issue in detail',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  errorText: createState.fieldErrors?['description'],
                ),
                maxLines: 5,
                onChanged: (value) {
                  ref.read(createReportControllerProvider.notifier).updateDescription(value);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Location widget
              LocationWidget(
                location: createState.location,
                isLoading: createState.isLoading,
                onRefresh: () {
                  ref.read(createReportControllerProvider.notifier).getCurrentLocation();
                },
              ),

              const SizedBox(height: 24),

              // Image picker widget
              ImagePickerWidget(
                selectedImages: createState.selectedImages,
                uploadedImages: createState.uploadedImages,
                isUploading: createState.isUploadingImages,
                onSelectImages: () {
                  ref.read(createReportControllerProvider.notifier).selectImages();
                },
                onTakePhoto: () {
                  ref.read(createReportControllerProvider.notifier).takePhoto();
                },
                onRemoveImage: (index) {
                  ref.read(createReportControllerProvider.notifier).removeImage(index);
                },
                onUploadImages: () {
                  ref.read(createReportControllerProvider.notifier).uploadImages();
                },
              ),

              const SizedBox(height: 24),

              // AI Analysis widget
              if (createState.aiAnalysis != null)
                AIAnalysisWidget(
                  analysis: createState.aiAnalysis!,
                  isAnalyzing: createState.isAnalyzing,
                ),

              const SizedBox(height: 24),

              // Error message
              if (createState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          createState.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(createReportControllerProvider.notifier).clearError();
                        },
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        color: Colors.red[700],
                      ),
                    ],
                  ),
                ),

              // Submit button
              ElevatedButton(
                onPressed: createState.isSubmitting || !createState.isFormValid
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await ref.read(createReportControllerProvider.notifier).createReport();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: createState.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Report', style: TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 16),

              // Form validation info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required Information:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildValidationItem('Title (min 5 characters)', createState.title != null && createState.title!.length >= 5),
                    _buildValidationItem('Report type', createState.type != null),
                    _buildValidationItem('Description (min 10 characters)', createState.description != null && createState.description!.length >= 10),
                    _buildValidationItem('Location', createState.location != null),
                    _buildValidationItem('At least one image', createState.hasImages),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isValid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green[700] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.pothole:
        return Icons.construction;
      case ReportType.streetLight:
        return Icons.lightbulb_outline;
      case ReportType.trash:
        return Icons.delete_outline;
      case ReportType.graffiti:
        return Icons.format_paint;
      case ReportType.roadDamage:
        return Icons.warning;
      case ReportType.construction:
        return Icons.build;
      case ReportType.other:
        return Icons.help_outline;
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

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.red[800]!;
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
}
