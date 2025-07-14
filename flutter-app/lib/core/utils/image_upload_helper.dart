import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUploadHelper {
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDimension = 2048;
  
  // 이미지 선택 및 준비
  static Future<File?> pickAndPrepareImage({
    required ImageSource source,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble() ?? maxDimension.toDouble(),
        maxHeight: maxHeight?.toDouble() ?? maxDimension.toDouble(),
        imageQuality: imageQuality ?? 85,
      );
      
      if (pickedFile == null) return null;
      
      final file = File(pickedFile.path);
      
      // 파일 크기 확인
      final fileSize = await file.length();
      if (fileSize > maxImageSize) {
        // 크기가 초과하면 추가 압축
        return await compressImage(file);
      }
      
      return file;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }
  
  // 이미지 압축
  static Future<File> compressImage(File imageFile, {int quality = 70}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // 리사이즈 (필요시)
      var resized = image;
      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          resized = img.copyResize(image, width: maxDimension);
        } else {
          resized = img.copyResize(image, height: maxDimension);
        }
      }
      
      // 압축하여 저장
      final compressedBytes = img.encodeJpg(resized, quality: quality);
      
      final tempDir = await getTemporaryDirectory();
      final compressedPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      final compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }
  
  // MultipartFile 생성 (직렬화 불가능한 객체를 즉시 사용)
  static Future<FormData> createFormData({
    required File imageFile,
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      final fileName = path.basename(imageFile.path);
      
      final formData = FormData();
      
      // 이미지 추가
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
          ),
        ),
      );
      
      // 추가 필드
      if (additionalFields != null) {
        additionalFields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }
      
      return formData;
    } catch (e) {
      throw Exception('Failed to create form data: $e');
    }
  }
  
  // 이미지 바이트로 변환 (직렬화 가능)
  static Future<Uint8List> imageToBytes(File imageFile) async {
    return await imageFile.readAsBytes();
  }
  
  // 바이트에서 임시 파일 생성
  static Future<File> bytesToTempFile(Uint8List bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = path.join(tempDir.path, fileName);
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }
}
