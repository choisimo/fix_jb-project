import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/repositories/file_repository.dart';
import '../../data/models/file_dto.dart';

class FileService {
  final FileRepository _repository;

  FileService({required FileRepository repository}) : _repository = repository;

  /// Upload a single file with optional analysis and tags
  Future<FileUploadResponse> uploadFile(
    File file, {
    bool analyze = false,
    List<String>? tags,
  }) async {
    return await _repository.uploadFile(file, analyze: analyze, tags: tags);
  }

  /// Upload multiple files as a batch
  Future<List<FileUploadResponse>> uploadFiles(
    List<File> files, {
    bool analyze = false,
  }) async {
    return await _repository.batchUploadFiles(files, analyze: analyze);
  }

  /// Get a file's metadata by ID
  Future<FileDto> getFile(String fileId) async {
    return await _repository.getFile(fileId);
  }

  /// Delete a file by ID
  Future<void> deleteFile(String fileId) async {
    await _repository.deleteFile(fileId);
  }
  
  /// Search for files by tag
  Future<List<FileDto>> searchFilesByTag(String tag) async {
    try {
      final files = await _repository.searchFilesByTag(tag);
      return files;
    } catch (e) {
      _logger.severe('Error searching files by tag: $e');
      throw FileServiceException('Failed to search files by tag', e);
    }
  }
  
  /// Search for files by multiple tags
  Future<List<FileDto>> searchFilesByTags(List<String> tags) async {
    if (tags.isEmpty) {
      return [];
    }
    
    try {
      // If the backend supports multiple tag search in one call, use that
      // Otherwise, fetch for each tag and combine results
      final results = <FileDto>[];
      final fileIds = <String>{};
      
      for (final tag in tags) {
        final files = await searchFilesByTag(tag);
        for (final file in files) {
          // Avoid duplicates
          if (!fileIds.contains(file.fileId)) {
            fileIds.add(file.fileId);
            results.add(file);
          }
        }
      }
      
      return results;
    } catch (e) {
      _logger.severe('Error searching files by multiple tags: $e');
      throw FileServiceException('Failed to search files by multiple tags', e);
    }
  }

  /// Poll the analysis status periodically
  Future<void> pollAnalysisStatus(
    String taskId, {
    required void Function(AnalysisStatusResponse) onUpdate,
    required void Function(dynamic) onError,
    Duration interval = const Duration(seconds: 3),
    int maxAttempts = 60, // 3 minutes with 3-second intervals
  }) async {
    int attempts = 0;
    bool firstAttempt = true;
    
    while (attempts < maxAttempts) {
      try {
        final status = await _repository.getAnalysisStatus(taskId);
        onUpdate(status);
        
        // Check if we've received analysis results
        if (status.result != null && !firstAttempt) {
          _logger.info('Analysis completed for task $taskId with results');
          // Process the analysis results if needed
          // For example, you might want to store them locally or update UI
        }
        
        // If task is completed or failed, stop polling
        if (status.status == 'completed' || status.status == 'failed') {
          break;
        }
        
        // Wait before next attempt
        await Future.delayed(interval);
        attempts++;
        firstAttempt = false;
      } catch (e) {
        _logger.warning('Error polling analysis status: $e');
        onError(e);
        
        // For temporary errors, we might want to retry after a longer delay
        if (attempts < maxAttempts / 2) {
          await Future.delayed(interval * 2);
          attempts++;
        } else {
          // After several failures, give up
          break;
        }
      }
    }
    
    // If we've reached max attempts without completion, report it
    if (attempts >= maxAttempts) {
      _logger.warning('Max polling attempts reached for task $taskId');
      onError(TimeoutException('Analysis is taking too long to complete'));
    }
  }

  /// Check if the file server is available
  Future<bool> isFileServerAvailable() async {
    return await _repository.isServerHealthy();
  }
}
