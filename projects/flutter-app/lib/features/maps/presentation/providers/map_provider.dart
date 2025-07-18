import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/map_state.dart';
import '../../domain/services/map_service.dart';
import '../../../../core/services/unified_location_service.dart';
import '../../../../core/providers/service_provider.dart';
import '../../../../core/services/unified_location_service.dart';

final mapServiceProvider = Provider<MapService>((ref) {
  final dio = ref.watch(dioProvider);
  return MapService(dio);
});

// Provider for the new unified location service
final mapLocationServiceProvider = Provider<UnifiedLocationService>((ref) {
  return ref.watch(unifiedLocationServiceProvider);
});

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  final mapService = ref.watch(mapServiceProvider);
  final locationService = ref.watch(unifiedLocationServiceProvider);
  return MapNotifier(locationService, mapService);
});

class MapNotifier extends StateNotifier<MapState> {
  final UnifiedLocationService _locationService;
  final MapService _mapService;
  
  MapNotifier(this._locationService, this._mapService) : super(const MapState());
  
  // Update camera position
  void updateCameraPosition(double latitude, double longitude, double zoom) {
    state = state.copyWith(
      centerLatitude: latitude,
      centerLongitude: longitude,
      zoomLevel: zoom,
    );
  }
  
  // Update current location with source information
  void setCurrentLocation({
    required double latitude, 
    required double longitude, 
    LocationSource? source
  }) {
    state = state.copyWith(
      centerLatitude: latitude,
      centerLongitude: longitude,
      locationSource: source?.name ?? state.locationSource,
    );
  }
  
  // Get current location using the unified location service
  Future<LocationResult> getCurrentLocation({
    bool useCache = true, 
    bool updateCache = true
  }) async {
    try {
      final result = await _locationService.getCurrentLocation(
        useCache: useCache,
        updateCache: updateCache,
      );
      
      // Update state with the retrieved location
      state = state.copyWith(
        centerLatitude: result.latitude,
        centerLongitude: result.longitude,
        locationSource: result.source.name,
        lastLocationError: result.errorMessage,
      );
      
      return result;
    } catch (e) {
      // Error handling
      state = state.copyWith(
        lastLocationError: 'Location error: $e',
      );
      rethrow;
    }
  }
  
  // Search for locations
  Future<List<SearchResult>> searchLocation(String query) async {
    try {
      final results = await _mapService.searchLocation(query);
      state = state.copyWith(searchResults: results);
      return results;
    } catch (e) {
      throw Exception('Location search failed: $e');
    }
  }
  
  // Open navigation to a location
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
  
  // Share a location
  Future<void> shareLocation(double latitude, double longitude, String title) async {
    final mapUrl = 'https://map.naver.com/v5/search/$longitude,$latitude';
    await Share.share(
      '$title\n위치: $mapUrl',
      subject: title,
    );
  }
  
  // Update location loading state
  void updateLocationLoadingState(bool isLoading) {
    state = state.copyWith(isLocationLoading: isLoading);
  }
  
  // Get current location using the unified location service
  Future<LocationResult?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    bool useCache = true,
    bool forceFallback = false,
  }) async {
    try {
      updateLocationLoadingState(true);
      
      final result = await _locationService.getCurrentLocation(
        accuracy: accuracy,
        useCache: useCache,
        forceFallback: forceFallback,
      );
      
      if (result.position != null) {
        state = state.copyWith(
          currentLocation: NCameraPosition(
            target: NLatLng(
              result.position!.latitude,
              result.position!.longitude,
            ),
            zoom: state.currentLocation.zoom,
          ),
          locationSource: result.source,
          lastLocationError: null,
        );
      } else if (result.error != null) {
        state = state.copyWith(lastLocationError: result.error);
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(lastLocationError: e.toString());
      return null;
    } finally {
      updateLocationLoadingState(false);
    }
  }
}
