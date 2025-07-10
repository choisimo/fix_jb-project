import 'dart:io';

class ImageUtils {
  /// 이미지 파일 크기 확인 (바이트)
  static Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// 파일 크기를 사람이 읽기 쉬운 형태로 변환
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// 이미지 파일 유효성 검사
  static bool isValidImageFile(String path) {
    final String extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// 파일 크기 체크 (최대 5MB)
  static Future<bool> isFileSizeValid(File file, {int maxSizeInMB = 5}) async {
    final int fileSize = await getFileSize(file);
    final int maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSize <= maxSizeInBytes;
  }

  /// 임시 파일 정리
  static Future<void> cleanupTempFiles(String directoryPath) async {
    try {
      final Directory dir = Directory(directoryPath);
      if (await dir.exists()) {
        final List<FileSystemEntity> files = dir.listSync();
        for (FileSystemEntity file in files) {
          if (file is File && file.path.contains('compressed_')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // 정리 실패는 무시
    }
  }
}
