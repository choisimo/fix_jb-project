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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
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
