import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/file_api_client.dart';
import '../models/file_dto.dart';
import '../repositories/file_repository.dart';
import '../../domain/services/file_service.dart';

// Provider for the API client
final fileApiClientProvider = Provider<FileApiClient>((ref) {
  final dio = Dio();
  // Configure API key, baseUrl, etc
  dio.options.headers['X-Auth-Token'] = const String.fromEnvironment('FILE_SERVER_API_KEY', defaultValue: '');
  
  // We can override the baseUrl when the app is initialized
  const baseUrl = String.fromEnvironment('FILE_SERVER_URL', defaultValue: 'http://localhost:12020');
  return FileApiClient(dio, baseUrl: baseUrl);
});

// Repository provider
final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final apiClient = ref.watch(fileApiClientProvider);
  return FileRepository(fileApiClient: apiClient);
});

// Service provider
final fileServiceProvider = Provider<FileService>((ref) {
  final repository = ref.watch(fileRepositoryProvider);
  return FileService(repository: repository);
});

// Provider to track upload progress
final fileUploadProgressProvider = StateNotifierProvider.family<FileUploadProgressNotifier, double, String>(
  (ref, fileId) => FileUploadProgressNotifier(),
);

class FileUploadProgressNotifier extends StateNotifier<double> {
  FileUploadProgressNotifier() : super(0.0);

  void setProgress(double progress) {
    state = progress;
  }

  void reset() {
    state = 0.0;
  }
}

// Provider for file uploads
final fileUploadsProvider = StateNotifierProvider<FileUploadsNotifier, AsyncValue<List<FileDto>>>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  return FileUploadsNotifier(fileService);
});

class FileUploadsNotifier extends StateNotifier<AsyncValue<List<FileDto>>> {
  final FileService _fileService;
  
  FileUploadsNotifier(this._fileService) : super(const AsyncValue.data([]));
  
  // Upload a single file
  Future<FileUploadResponse?> uploadFile(File file, {bool analyze = false, List<String>? tags}) async {
    try {
      state = const AsyncValue.loading();
      final response = await _fileService.uploadFile(file, analyze: analyze, tags: tags);
      
      // Add the new file to the list
      final currentFiles = state.asData?.value ?? [];
      final newFile = FileDto(
        fileId: response.fileId,
        filename: response.filename,
        fileUrl: response.fileUrl,
        thumbnailUrl: response.thumbnailUrl,
        size: response.size,
        contentType: response.contentType,
        analysisTaskId: response.analysisTaskId,
      );
      
      state = AsyncValue.data([...currentFiles, newFile]);
      return response;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
  
  // Upload multiple files
  Future<List<FileUploadResponse>?> uploadFiles(List<File> files, {bool analyze = false}) async {
    try {
      state = const AsyncValue.loading();
      final responses = await _fileService.uploadFiles(files, analyze: analyze);
      
      // Add all new files to the list
      final currentFiles = state.asData?.value ?? [];
      final newFiles = responses.map((response) => FileDto(
        fileId: response.fileId,
        filename: response.filename,
        fileUrl: response.fileUrl,
        thumbnailUrl: response.thumbnailUrl,
        size: response.size,
        contentType: response.contentType,
        analysisTaskId: response.analysisTaskId,
      )).toList();
      
      state = AsyncValue.data([...currentFiles, ...newFiles]);
      return responses;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
  
  // Delete a file
  Future<bool> deleteFile(String fileId) async {
    try {
      await _fileService.deleteFile(fileId);
      
      // Remove the file from the list
      final currentFiles = state.asData?.value ?? [];
      final updatedFiles = currentFiles.where((file) => file.fileId != fileId).toList();
      
      state = AsyncValue.data(updatedFiles);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Clear all files from the list
  void clearFiles() {
    state = const AsyncValue.data([]);
  }
}

// Provider for files search by tags
final fileSearchProvider = FutureProvider.family<List<FileDto>, List<String>>((ref, tags) async {
  final fileService = ref.watch(fileServiceProvider);
  try {
    final files = await fileService.searchFilesByTags(tags);
    return files;
  } catch (e) {
    throw Exception('Failed to search files: $e');
  }
});

// Provider for all files (base provider)
final filesProvider = FutureProvider<List<FileDto>>((ref) async {
  final fileService = ref.watch(fileServiceProvider);
  try {
    final files = await fileService.getAllFiles();
    return files;
  } catch (e) {
    throw Exception('Failed to fetch files: $e');
  }
});

// Provider for tracking analysis tasks
final analysisTaskProvider = StateNotifierProvider.family<AnalysisTaskNotifier, AsyncValue<AnalysisStatusResponse?>, String>(
  (ref, taskId) => AnalysisTaskNotifier(ref.watch(fileServiceProvider), taskId),
);

class AnalysisTaskNotifier extends StateNotifier<AsyncValue<AnalysisStatusResponse?>> {
  final FileService _fileService;
  final String _taskId;
  bool _isPolling = false;
  
  AnalysisTaskNotifier(this._fileService, this._taskId) : super(const AsyncValue.loading()) {
    _startPolling();
  }
  
  Future<void> _startPolling() async {
    if (_isPolling) return;
    _isPolling = true;
    
    try {
      await _fileService.pollAnalysisStatus(
        _taskId,
        onUpdate: (status) {
          state = AsyncValue.data(status);
          
          // Stop polling if completed or failed
          if (status.status == 'completed' || status.status == 'failed') {
            _isPolling = false;
          }
        },
        onError: (error) {
          state = AsyncValue.error(error, StackTrace.current);
          _isPolling = false;
        },
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _isPolling = false;
    }
  }
  
  void restartPolling() {
    _isPolling = false;
    _startPolling();
  }
}
