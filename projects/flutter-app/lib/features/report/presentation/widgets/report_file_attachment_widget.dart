import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../file_management/presentation/widgets/file_upload_widget.dart';
import '../../../file_management/presentation/widgets/file_list_widget.dart';
import '../../../file_management/data/models/file_dto.dart';
import '../../domain/services/report_file_service.dart';

class ReportFileAttachmentWidget extends ConsumerStatefulWidget {
  final String reportId;
  final bool readOnly;
  final Function(List<FileUploadResponse>)? onFilesAdded;

  const ReportFileAttachmentWidget({
    Key? key,
    required this.reportId,
    this.readOnly = false,
    this.onFilesAdded,
  }) : super(key: key);

  @override
  ConsumerState<ReportFileAttachmentWidget> createState() =>
      _ReportFileAttachmentWidgetState();
}

class _ReportFileAttachmentWidgetState
    extends ConsumerState<ReportFileAttachmentWidget> {
  List<FileDto> _reportFiles = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReportFiles();
  }

  Future<void> _loadReportFiles() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final reportFileService = ref.read(reportFileServiceProvider);
      final files = await reportFileService.getReportFiles(widget.reportId);

      setState(() {
        _reportFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = '파일을 불러오는 데 실패했습니다: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '첨부 파일',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_reportFiles.isNotEmpty)
              Text(
                '총 ${_reportFiles.length}개',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Upload widget (only if not in read-only mode)
        if (!widget.readOnly) ...[
          FileUploadWidget(
            allowMultiple: true,
            analyzeFiles: true,
            tags: ['report', 'report-${widget.reportId}'],
            onUploadSuccess: (files) async {
              // Update the file list
              await _loadReportFiles();
              
              // Notify the parent
              if (widget.onFilesAdded != null) {
                widget.onFilesAdded!(files);
              }
            },
          ),
          const Divider(),
        ],

        // Loading indicator
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),

        // Error message
        if (_hasError && _errorMessage != null)
          Center(
            child: Column(
              children: [
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: _loadReportFiles,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),

        // File list
        if (!_isLoading && !_hasError) ...[
          if (_reportFiles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text('첨부된 파일이 없습니다'),
              ),
            )
          else
            FileListWidget(
              files: _reportFiles,
              showAnalysisStatus: true,
              allowDelete: !widget.readOnly,
              onFileDeleted: (file) async {
                // Delete the file from the report
                final reportFileService = ref.read(reportFileServiceProvider);
                final success = await reportFileService.deleteReportFile(
                  widget.reportId,
                  file.fileId,
                );

                if (success) {
                  setState(() {
                    _reportFiles.removeWhere((f) => f.fileId == file.fileId);
                  });
                }
              },
            ),
        ],
      ],
    );
  }
}
