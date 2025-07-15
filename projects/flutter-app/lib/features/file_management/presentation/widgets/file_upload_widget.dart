import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/providers/file_providers.dart';
import '../../data/models/file_dto.dart';
import '../../data/models/analysis_result.dart';
import '../widgets/file_analysis_result_widget.dart';

class FileUploadWidget extends ConsumerStatefulWidget {
  final bool allowMultiple;
  final bool analyzeFiles;
  final List<String>? tags;
  final bool showTagSuggestions;
  final void Function(List<FileUploadResponse>)? onUploadSuccess;
  final void Function(Exception)? onUploadError;
  final void Function(List<String>)? onTagsSelected;

  const FileUploadWidget({
    Key? key,
    this.allowMultiple = false,
    this.analyzeFiles = false,
    this.tags,
    this.showTagSuggestions = true,
    this.onUploadSuccess,
    this.onUploadError,
    this.onTagsSelected,
  }) : super(key: key);

  @override
  ConsumerState<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends ConsumerState<FileUploadWidget> {
  bool _isUploading = false;
  List<File> _selectedFiles = [];
  List<String> _appliedTags = [];
  String? _lastUploadedTaskId;  // Track last analysis task ID

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // File selection buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera button
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _isUploading ? null : _takePicture,
              tooltip: '사진 촬영',
            ),
            const SizedBox(width: 16),
            // Gallery button
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: _isUploading ? null : _pickImage,
              tooltip: '갤러리에서 선택',
            ),
            const SizedBox(width: 16),
            // File button
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _isUploading ? null : _pickFile,
              tooltip: '파일 선택',
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Selected files preview
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '선택된 파일: ${_selectedFiles.length}개',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                final fileName = file.path.split('/').last;
                final isImage = fileName.toLowerCase().endsWith('.jpg') ||
                    fileName.toLowerCase().endsWith('.jpeg') ||
                    fileName.toLowerCase().endsWith('.png') ||
                    fileName.toLowerCase().endsWith('.gif');

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isImage
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.insert_drive_file),
                                    Text(
                                      fileName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFiles.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],

        // Tags input section
        if (widget.tags != null || _appliedTags.isNotEmpty) ...[  
          const SizedBox(height: 16),
          _buildTagsSection(),
        ],
        
        // Last analysis result
        if (_lastUploadedTaskId != null) ...[  
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            '마지막 업로드 파일 분석 결과',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FileAnalysisResultWidget(
            taskId: _lastUploadedTaskId!,
            showSuggestedTags: widget.showTagSuggestions,
            onApplyTags: _handleTagSelection,
          ),
        ],
        
        // Upload button
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _selectedFiles.isEmpty || _isUploading
              ? null
              : _uploadFiles,
          child: _isUploading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('업로드'),
        ),
        
        if (_isUploading) ...[  
          const SizedBox(height: 12),
          const Text('업로드 중...잠시만 기다려주세요'),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  // Build tags selection section
  Widget _buildTagsSection() {
    final allTags = <String>{};
    if (widget.tags != null) allTags.addAll(widget.tags!);
    allTags.addAll(_appliedTags);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '파일 태그:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: _showAddTagDialog,
              tooltip: '태그 추가',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allTags.map((tag) => Chip(
            label: Text(tag),
            onDeleted: widget.tags?.contains(tag) == true 
                ? null  // Don't allow deleting fixed tags
                : () => _removeTag(tag),
          )).toList(),
        ),
      ],
    );
  }

  // Take a picture using the camera
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        if (!widget.allowMultiple) {
          _selectedFiles.clear();
        }
        _selectedFiles.add(File(pickedFile.path));
      });
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        if (!widget.allowMultiple) {
          _selectedFiles.clear();
          _selectedFiles.add(File(pickedFiles.first.path));
        } else {
          _selectedFiles.addAll(pickedFiles.map((e) => File(e.path)).toList());
        }
      });
    }
  }

  // Pick any file
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: widget.allowMultiple,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        if (!widget.allowMultiple) {
          _selectedFiles.clear();
          if (result.files.isNotEmpty) {
            _selectedFiles.add(File(result.files.first.path!));
          }
        } else {
          _selectedFiles.addAll(
            result.files
                .where((file) => file.path != null)
                .map((file) => File(file.path!))
                .toList(),
          );
        }
      });
    }
  }

  // Upload the selected files
  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _lastUploadedTaskId = null; // Reset any previous analysis result
    });

    try {
      final fileUploadsNotifier = ref.read(fileUploadsProvider.notifier);

      List<FileUploadResponse> results = [];
      final combinedTags = _getCombinedTags();
      
      if (widget.allowMultiple && _selectedFiles.length > 1) {
        // Batch upload for multiple files
        final responses = await fileUploadsNotifier.uploadFiles(
          _selectedFiles,
          analyze: widget.analyzeFiles,
          tags: combinedTags,
        );
        
        if (responses != null) {
          results = responses;
        }
      } else {
        // Single file upload
        for (final file in _selectedFiles) {
          final response = await fileUploadsNotifier.uploadFile(
            file,
            analyze: widget.analyzeFiles,
            tags: combinedTags,
          );
          
          if (response != null) {
            results.add(response);
          }
        }
      }

      // Call the success callback
      if (results.isNotEmpty && widget.onUploadSuccess != null) {
        widget.onUploadSuccess!(results);
      }
      
      // Store analysis task ID of the last file for tracking
      if (widget.analyzeFiles && results.isNotEmpty) {
        final lastFile = results.last;
        if (lastFile.analysisTaskId != null) {
          setState(() {
            _lastUploadedTaskId = lastFile.analysisTaskId;
          });
        }
      }

      // Clear selected files after successful upload
      setState(() {
        _selectedFiles.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${results.length}개 파일 업로드 완료${widget.analyzeFiles ? ' (분석 진행 중)' : ''}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (widget.onUploadError != null) {
        widget.onUploadError!(e as Exception);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('업로드 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  
  // Get combined list of fixed tags and applied tags
  List<String> _getCombinedTags() {
    final allTags = <String>{};
    if (widget.tags != null) allTags.addAll(widget.tags!);
    allTags.addAll(_appliedTags);
    return allTags.toList();
  }
  
  // Handle tag selection from AI suggestions
  void _handleTagSelection(List<String> selectedTags) {
    setState(() {
      for (final tag in selectedTags) {
        if (!_appliedTags.contains(tag)) {
          _appliedTags.add(tag);
        }
      }
    });
    
    if (widget.onTagsSelected != null) {
      widget.onTagsSelected!(_appliedTags);
    }
  }
  
  // Remove a tag
  void _removeTag(String tag) {
    setState(() {
      _appliedTags.remove(tag);
    });
    
    if (widget.onTagsSelected != null) {
      widget.onTagsSelected!(_appliedTags);
    }
  }
  
  // Show dialog to add a custom tag
  void _showAddTagDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('태그 추가'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: '태그 입력'),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _addTag(value);
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _addTag(textController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
  
  // Add a custom tag
  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty) return;
    
    setState(() {
      if (!_appliedTags.contains(trimmedTag)) {
        _appliedTags.add(trimmedTag);
      }
    });
    
    if (widget.onTagsSelected != null) {
      widget.onTagsSelected!(_appliedTags);
    }
  }
}
