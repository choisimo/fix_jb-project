import 'dart:io';
import '../network/api_client.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  static ProfileService get instance => _instance;
  ProfileService._internal();

  final ApiClient _apiClient = ApiClient();

  /// 프로필 이미지 업로드
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final response = await _apiClient.uploadFile(
        '/api/profile/image',
        imageFile.path,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('프로필 이미지 업로드 실패');
      }
    } catch (e) {
      // 에러 메시지 파싱
      String errorMessage = '네트워크 오류가 발생했습니다.';
      if (e.toString().contains('413')) {
        errorMessage = '이미지 파일이 너무 큽니다. 더 작은 파일을 선택해주세요.';
      } else if (e.toString().contains('400')) {
        errorMessage = '지원하지 않는 이미지 형식입니다.';
      } else if (e.toString().contains('5')) {
        errorMessage = '서버 오류가 발생했습니다.';
      }
      throw Exception(errorMessage);
    }
  }

  /// 프로필 이미지 URL 가져오기
  Future<String?> getProfileImageUrl() async {
    try {
      final response = await _apiClient.get('/api/profile/image');

      if (response.statusCode == 200 && response.data != null) {
        return response.data['imageUrl'] as String?;
      }
      return null;
    } catch (e) {
      // 프로필 이미지가 없거나 가져올 수 없는 경우 null 반환
      return null;
    }
  }

  /// 프로필 이미지 삭제
  Future<void> deleteProfileImage() async {
    try {
      final response = await _apiClient.delete('/api/profile/image');

      if (response.statusCode != 200) {
        throw Exception('프로필 이미지 삭제 실패');
      }
    } catch (e) {
      throw Exception('서버 오류가 발생했습니다.');
    }
  }

  /// 프로필 정보 업데이트
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _apiClient.put('/api/profile', data: profileData);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('프로필 업데이트 실패');
      }
    } catch (e) {
      throw Exception('서버 오류가 발생했습니다.');
    }
  }
}
