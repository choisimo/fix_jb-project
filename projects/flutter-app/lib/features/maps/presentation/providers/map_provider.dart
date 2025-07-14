import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/map_state.dart';
import '../../domain/services/map_service.dart';
import '../../../../core/providers/service_provider.dart';

final mapServiceProvider = Provider<MapService>((ref) {
  final dio = ref.watch(dioProvider);
  return MapService(dio);
});

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  final service = ref.watch(mapServiceProvider);
  return MapNotifier(service);
});

class MapNotifier extends StateNotifier<MapState> {
  final MapService _service;
  
  MapNotifier(this._service) : super(const MapState());
  
  void updateCameraPosition(double latitude, double longitude, double zoom) {
    state = state.copyWith(
      centerLatitude: latitude,
      centerLongitude: longitude,
      zoomLevel: zoom,
    );
  }
  
  Future<List<SearchResult>> searchLocation(String query) async {
    try {
      final results = await _service.searchLocation(query);
      state = state.copyWith(searchResults: results);
      return results;
    } catch (e) {
      throw Exception('Location search failed: $e');
    }
  }
  
  Future<void> openNavigation(double latitude, double longitude) async {
    final url = 'nmap://route/car?dlat=$latitude&dlng=$longitude&appname=com.jbreport.app';
    final fallbackUrl = 'https://map.naver.com/v5/directions/-/-/-/$longitude,$latitude';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      throw Exception('Failed to open navigation: $e');
    }
  }
  
  Future<void> shareLocation(double latitude, double longitude, String title) async {
    final mapUrl = 'https://map.naver.com/v5/search/$longitude,$latitude';
    await Share.share(
      '$title\n위치: $mapUrl',
      subject: title,
    );
  }
}
