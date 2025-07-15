import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../file_management/data/models/file_dto.dart';
import '../../../file_management/domain/services/file_service.dart';
import '../../../file_management/data/providers/file_providers.dart';
import '../../data/api/report_api_client.dart';
import '../../data/providers/report_providers.dart';

/// Service to handle file operations related to reports
class ReportFileService {
  final FileService _fileService;
  final ReportApiClient _reportApiClient;
  
  ReportFileService({
    required FileService fileService,
    required ReportApiClient reportApiClient,
  })  : _fileService = fileService,
        _reportApiClient = reportApiClient;

  /// Upload a file and attach it to a report
  Future<FileUploadResponse> uploadAndAttachFile(
    String reportId, 
    File file, {
    bool analyze = true,
  }) async {
    // 1. Upload file to file server
    final uploadResponse = await _fileService.uploadFile(
      file,
      analyze: analyze,
      tags: ['report', 'report-$reportId'],
    );
    
    // 2. Attach the file to the report via the main API
    await _reportApiClient.attachFileToReport(
      reportId, 
      uploadResponse.fileId,
      uploadResponse.fileUrl,
      uploadResponse.thumbnailUrl,
    );
    
    return uploadResponse;
  }

  /// Get all files attached to a report
  Future<List<FileDto>> getReportFiles(String reportId) async {
    // This would typically call the main API to get file IDs attached to the report,
    // then fetch the actual file details from the file server
    // For now, we'll just fetch files with the report tag
    try {
      final files = await _fileService.getFilesByTag('report-$reportId');
      return files;
    } catch (e) {
      // Log error
      print('Error fetching report files: $e');
      return [];
    }
  }
  
  /// Delete a file attached to a report
  Future<bool> deleteReportFile(String reportId, String fileId) async {
    try {
      // 1. Remove the file association from the report
      await _reportApiClient.detachFileFromReport(reportId, fileId);
      
      // 2. Delete the file from the file server
      await _fileService.deleteFile(fileId);
      return true;
    } catch (e) {
      // Log error
      print('Error deleting report file: $e');
      return false;
    }
  }
}

// Provider for the report file service
final reportFileServiceProvider = Provider<ReportFileService>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  final reportApiClient = ref.watch(reportApiClientProvider);
  
  return ReportFileService(
    fileService: fileService,
    reportApiClient: reportApiClient,
  );
});
