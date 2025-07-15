import 'dart:io';
import 'package:dio/dio.dart';
import '../api/file_api_client.dart';
import '../models/file_dto.dart';

class FileRepository {
  final FileApiClient _fileApiClient;

  FileRepository({required FileApiClient fileApiClient}) 
      : _fileApiClient = fileApiClient;

  /// Upload a file to the file server
  Future<FileUploadResponse> uploadFile(
    File file, {
    bool analyze = false,
    List<String>? tags,
  }) async {
    try {
      return await _fileApiClient.uploadFile(file, analyze, tags);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  /// Get file information by ID
  Future<FileDto> getFile(String fileId) async {
    try {
      return await _fileApiClient.getFile(fileId);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a file by ID
  Future<void> deleteFile(String fileId) async {
    try {
      await _fileApiClient.deleteFile(fileId);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  /// Check status of an AI analysis task
  Future<AnalysisStatusResponse> getAnalysisStatus(String taskId) async {
    try {
      return await _fileApiClient.getAnalysisStatus(taskId);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload multiple files in a batch
  Future<List<FileUploadResponse>> batchUploadFiles(
    List<File> files, {
    bool analyze = false,
  }) async {
    try {
      return await _fileApiClient.batchUploadFiles(files, analyze);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  /// Check if the file server is healthy and responsive
  Future<bool> isServerHealthy() async {
    try {
      final response = await _fileApiClient.checkHealth();
      return response['status'] == 'healthy';
    } on DioError catch (e) {
      return false;
    }
  }
  
  /// Search for files by tag
  Future<List<FileDto>> searchFilesByTag(String tag) async {
    try {
      // Call the API client
      final response = await _fileApiClient.searchFilesByTag(tag);
      return response.files;
    } on DioException catch (e) {
      _logger.severe('Failed to search files by tag: ${e.message}');
      if (e.response?.statusCode == 404) {
        // If the endpoint is not found, it might not be implemented yet
        _logger.warning('Tag search endpoint might not be implemented yet');
        return []; // Return empty list instead of throwing
      }
      throw FileRepositoryException('Failed to search files by tag', e);
    } catch (e) {
      _logger.severe('Unexpected error searching files by tag: $e');
      throw FileRepositoryException('Unexpected error searching files by tag', e);
    }
  }

  /// Handle Dio errors and convert to appropriate exceptions
  Exception _handleError(DioError error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final errorMessage = error.response!.data['message'] ?? 'Unknown server error';
      
      if (statusCode == 404) {
        return FileNotFoundException('File not found: $errorMessage');
      } else if (statusCode == 401 || statusCode == 403) {
        return UnauthorizedException('Authentication failed: $errorMessage');
      } else if (statusCode == 413) {
        return FileTooLargeException('File too large: $errorMessage');
      } else {
        return FileServerException('Server error ($statusCode): $errorMessage');
      }
    } else if (error.type == DioErrorType.connectTimeout ||
               error.type == DioErrorType.receiveTimeout ||
               error.type == DioErrorType.sendTimeout) {
      return FileServerTimeoutException('Connection timed out');
    }
    
    return FileServerException('Network error: ${error.message}');
  }
}

/// Custom exceptions for file operations
class FileServerException implements Exception {
  final String message;
  FileServerException(this.message);
  @override
  String toString() => 'FileServerException: $message';
}

class FileNotFoundException extends FileServerException {
  FileNotFoundException(String message) : super(message);
}

class UnauthorizedException extends FileServerException {
  UnauthorizedException(String message) : super(message);
}

class FileTooLargeException extends FileServerException {
  FileTooLargeException(String message) : super(message);
}

class FileServerTimeoutException extends FileServerException {
  FileServerTimeoutException(String message) : super(message);
}
