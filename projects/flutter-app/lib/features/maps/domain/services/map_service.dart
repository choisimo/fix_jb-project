import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../models/map_state.dart';

class MapService {
  final Dio _dio;

  MapService(this._dio);
  
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 활성화해주세요.');
    }

    // 위치 권한 확인 및 요청
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
    }

    // 위치 정보 가져오기 (타임아웃 설정)
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      // 정확한 위치를 가져올 수 없으면 낮은 정확도로 재시도
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        // 그래도 실패하면 마지막으로 알려진 위치 시도
        final lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          return lastKnownPosition;
        }
        throw Exception('현재 위치를 가져올 수 없습니다: $e');
      }
    }
  }

  Future<String> getAddressFromCoordinates(NLatLng location) async {
    // NOTE: Replace with your actual Naver Cloud Platform credentials
    const clientId = '6gmofoay96';
    const clientSecret = '6WQ3He7rBpcsa02WtRY6A9ycU5MsClOvKkwZ6O1B';

    final url = 'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=${location.longitude},${location.latitude}&output=json';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'X-NCP-APIGW-API-KEY-ID': clientId,
            'X-NCP-APIGW-API-KEY': clientSecret,
          },
        ),
      );

      if (response.statusCode == 200 && response.data['results'].isNotEmpty) {
        return response.data['results'][0]['region']['area1']['name'] + ' ' +
               response.data['results'][0]['region']['area2']['name'] + ' ' +
               response.data['results'][0]['region']['area3']['name'];
      } else {
        return 'Failed to get address';
      }
    } catch (e) {
      print('Error getting address: $e');
      return 'Error getting address';
    }
  }
  
  Future<List<SearchResult>> searchLocation(String query) async {
    try {
      final response = await _dio.get(
        '/api/v1/maps/search',
        queryParameters: {
          'query': query,
          'display': 10,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'] ?? [];
        return items.map((item) => SearchResult.fromJson(item)).toList();
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Location search error: $e');
    }
  }
  
  Future<Map<String, dynamic>> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        '/api/v1/maps/reverse-geocode',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Reverse geocoding failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Reverse geocoding error: $e');
    }
  }
}
