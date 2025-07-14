import 'package:dio/dio.dart';
import '../models/map_state.dart';

class MapService {
  final Dio _dio;
  
  MapService(this._dio);
  
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
