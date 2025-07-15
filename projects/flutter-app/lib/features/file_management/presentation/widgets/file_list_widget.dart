import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/file_dto.dart';
import '../../data/providers/file_providers.dart';

class FileListWidget extends ConsumerWidget {
  final List<FileDto>? files;
  final bool showAnalysisStatus;
  final bool allowDelete;
  final Function(FileDto)? onFileTap;
  final Function(FileDto)? onFileDeleted;
  final Function(String)? onAnalysisSelected;

  const FileListWidget({
    Key? key,
    this.files,
    this.showAnalysisStatus = false,
    this.allowDelete = false,
    this.onFileTap,
    this.onFileDeleted,
    this.onAnalysisSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If files are passed in, use those. Otherwise use the files from the provider
    final filesList = files ?? ref.watch(fileUploadsProvider).asData?.value ?? [];

    if (filesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '파일이 없습니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: filesList.length,
      itemBuilder: (context, index) {
        final file = filesList[index];
        return _buildFileItem(context, ref, file);
      },
    );
  }

  Widget _buildFileItem(BuildContext context, WidgetRef ref, FileDto file) {
    final bool isImage = file.contentType.contains('image');
    
    // Build the status widget if needed
    Widget? statusWidget;
    if (showAnalysisStatus && file.analysisTaskId != null) {
      statusWidget = _buildAnalysisStatus(
        context, 
        ref, 
        file.analysisTaskId!,
        onTap: () => onAnalysisSelected?.call(file.analysisTaskId!),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => onFileTap?.call(file),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File thumbnail or icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: isImage && file.thumbnailUrl != null
                      ? Image.network(
                          file.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        )
                      : Center(
                          child: Icon(
                            _getFileIcon(file.contentType),
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              
              // File details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.filename,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFileSize(file.size),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (statusWidget != null) ...[
                      const SizedBox(height: 8),
                      statusWidget,
                    ],
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // View file button
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 20),
                          onPressed: () => _openFile(file.fileUrl),
                          tooltip: '파일 보기',
                        ),
                        
                        // Delete button
                        if (allowDelete)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _deleteFile(context, ref, file),
                            tooltip: '파일 삭제',
                            color: Colors.red,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the analysis status widget based on the task ID
  Widget _buildAnalysisStatus(
    BuildContext context, 
    WidgetRef ref, 
    String taskId, {
    VoidCallback? onTap,
  }) {
    final taskState = ref.watch(analysisTaskProvider(taskId));
    
    return taskState.when(
      data: (status) {
        if (status == null) {
          return const Text('분석 상태를 확인할 수 없음');
        }
        
        switch (status.status) {
          case 'pending':
            return GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '분석 대기 중...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          case 'in_progress':
            final progress = status.progress ?? 0.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '분석 중...${progress > 0 ? ' ${(progress * 100).toStringAsFixed(0)}%' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 12, 
                      height: 12, 
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: progress > 0 ? progress : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 4,
                ),
              ],
            );
          case 'completed':
            if (status.result != null) {
              return GestureDetector(
                onTap: onTap,
                child: Row(
                  children: [
                    Text(
                      '분석 완료',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    if (onTap != null) ...[  
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.info_outline,
                        color: Colors.green,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              );
            } else {
              return Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    '분석 완료',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              );
            }
          case 'failed':
            return Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 14),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '분석 실패: ${status.error ?? "알 수 없는 오류"}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
            
          default:
            return Text(
              '상태: ${status.status}',
              style: Theme.of(context).textTheme.bodySmall,
            );
        }
      },
      loading: () => Row(
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            '분석 상태 확인 중...',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      error: (error, stackTrace) => Text(
        '오류: $error',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
      ),
    );
  }

  // Open file in browser or with appropriate handler
  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Delete a file
  void _deleteFile(BuildContext context, WidgetRef ref, FileDto file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('파일 삭제'),
        content: Text('${file.filename}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final fileUploadsNotifier = ref.read(fileUploadsProvider.notifier);
              final success = await fileUploadsNotifier.deleteFile(file.fileId);
              
              if (success) {
                if (onFileDeleted != null) {
                  onFileDeleted!(file);
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('파일이 삭제되었습니다')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('파일 삭제 중 오류가 발생했습니다'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // Get appropriate icon based on file type
  IconData _getFileIcon(String contentType) {
    if (contentType.contains('image')) {
      return Icons.image;
    } else if (contentType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (contentType.contains('word') || contentType.contains('document')) {
      return Icons.description;
    } else if (contentType.contains('excel') || contentType.contains('sheet')) {
      return Icons.table_chart;
    } else if (contentType.contains('video')) {
      return Icons.videocam;
    } else if (contentType.contains('audio')) {
      return Icons.audiotrack;
    } else if (contentType.contains('zip') || contentType.contains('archive')) {
      return Icons.archive;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // Format file size as human-readable string
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
