import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env_config.dart';

enum LocationSource {
  HIGH_ACCURACY,
  MEDIUM_ACCURACY,
  LAST_KNOWN,
  CACHED,
  DEFAULT
}

class LocationResult {
  final double latitude;
  final double longitude;
  final LocationSource source;
  final String? errorMessage;
  final bool isSuccessful;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.source,
    this.errorMessage,
    this.isSuccessful = true,
  });

  // Create a result for successful location retrieval
  factory LocationResult.success({
    required double latitude,
    required double longitude,
    required LocationSource source,
  }) {
    return LocationResult(
      latitude: latitude,
      longitude: longitude,
      source: source,
      isSuccessful: true,
    );
  }

  // Create a result for location retrieval failure
  factory LocationResult.failure({
    required double fallbackLatitude,
    required double fallbackLongitude,
    required LocationSource fallbackSource,
    required String errorMessage,
  }) {
    return LocationResult(
      latitude: fallbackLatitude,
      longitude: fallbackLongitude,
      source: fallbackSource,
      errorMessage: errorMessage,
      isSuccessful: false,
    );
  }

  // Helper to create a NLatLng object from this result
  NLatLng toNLatLng() {
    return NLatLng(latitude, longitude);
  }
}

// Provider for the unified location service
final unifiedLocationServiceProvider = Provider<UnifiedLocationService>((ref) {
  final service = UnifiedLocationService();
  ref.onDispose(() async {
    await service.dispose();
  });
  return service;
});

class UnifiedLocationService {
  // Constants for caching
  static const String _cachedLatKey = 'cached_location_lat';
  static const String _cachedLngKey = 'cached_location_lng';
  static const String _cachedTimestampKey = 'cached_location_timestamp';
  
  // 위치 추적 및 저장 관련 필드
  StreamSubscription<Position>? _locationSubscription;
  Position? _lastKnownPosition;
  
  // Configuration options
  final Duration _cacheTtl = const Duration(hours: 24);
  final Duration _highAccuracyTimeout = const Duration(seconds: 8);
  final Duration _mediumAccuracyTimeout = const Duration(seconds: 5);
  bool _debugMode = false;

  // Turn debug mode on or off
  void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }
  
  // 서비스 초기화
  Future<void> init() async {
    try {
      // 권한 확인
      await checkLocationPermission();
      
      // 캐시된 위치 확인
      await _getCachedLocation();
      
      if (_debugMode) debugPrint('UnifiedLocationService 초기화 완료');
    } catch (e) {
      debugPrint('UnifiedLocationService 초기화 실패: $e');
    }
  }
  
  // 권한 확인 메서드 (외부에서 호출 가능)
  Future<bool> checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // 권한 요청은 하지 않고 상태만 확인
        if (_debugMode) debugPrint('위치 권한이 거부됨');
        return false;
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (_debugMode) debugPrint('위치 권한이 영구 거부됨');
        return false;
      }
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (_debugMode) debugPrint('위치 서비스가 비활성화됨');
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('권한 확인 중 오류: $e');
      return false;
    }
  }

  // Get current location with progressive fallback strategy
  Future<LocationResult> getCurrentLocation({
    bool useCache = true,
    bool updateCache = true,
  }) async {
    try {
      // Step 1: Check permissions and location services
      final permissionResult = await _checkLocationPermission();
      if (!permissionResult) {
        if (_debugMode) debugPrint('🚫 위치 권한이 없습니다. 기본 위치를 사용합니다.');
        return await _getFallbackLocation('위치 권한이 필요합니다.');
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (_debugMode) debugPrint('🚫 위치 서비스가 비활성화되어 있습니다. 기본 위치를 사용합니다.');
        return await _getFallbackLocation('위치 서비스가 비활성화되어 있습니다.');
      }

      // Step 2: Try to get high accuracy location
      try {
        if (_debugMode) debugPrint('🔍 고정밀 위치 정보 요청 중...');
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: _highAccuracyTimeout,
        );
        
        if (_debugMode) debugPrint('✅ 고정밀 위치 획득 성공: ${position.latitude}, ${position.longitude}');
        
        // Cache this successful location
        if (updateCache) {
          _cacheLocation(position.latitude, position.longitude);
        }

        return LocationResult.success(
          latitude: position.latitude,
          longitude: position.longitude,
          source: LocationSource.HIGH_ACCURACY,
        );
      } catch (e) {
        if (_debugMode) debugPrint('⚠️ 고정밀 위치 획득 실패: $e, 중간 정밀도로 시도합니다.');
        
        // Step 3: Try medium accuracy if high accuracy fails
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: _mediumAccuracyTimeout,
          );
          
          if (_debugMode) debugPrint('✅ 중간 정밀 위치 획득 성공: ${position.latitude}, ${position.longitude}');
          
          // Cache this successful location
          if (updateCache) {
            _cacheLocation(position.latitude, position.longitude);
          }

          return LocationResult.success(
            latitude: position.latitude,
            longitude: position.longitude,
            source: LocationSource.HIGH_ACCURACY,
          );
        } catch (e) {
          if (_debugMode) debugPrint('⚠️ 중간 정밀 위치 획득 실패: $e, 마지막 알려진 위치를 확인합니다.');
          
          // Step 4: Try last known position
          final lastKnownPosition = await Geolocator.getLastKnownPosition();
          if (lastKnownPosition != null) {
            if (_debugMode) debugPrint('✅ 마지막 알려진 위치 사용: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}');
            
            return LocationResult.success(
              latitude: lastKnownPosition.latitude,
              longitude: lastKnownPosition.longitude,
              source: LocationSource.LAST_KNOWN,
            );
          }
          
          // Step 5: Try cached position if allowed
          if (useCache) {
            final cachedLocation = await _getCachedLocation();
            if (cachedLocation != null) {
              return cachedLocation;
            }
          }
          
          // Step 6: Fall back to default location
          if (_debugMode) debugPrint('⚠️ 위치 정보를 가져올 수 없습니다. 기본 위치를 사용합니다.');
          return await _getFallbackLocation('위치 정보를 가져올 수 없습니다.');
        }
      }
    } catch (e) {
      if (_debugMode) debugPrint('❌ 위치 서비스 오류: $e');
      return await _getFallbackLocation('위치 서비스 오류: $e');
    }
  }

  // Check and request location permissions
  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  // Get address from coordinates
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final addressParts = [
          place.street,
          place.subLocality, 
          place.locality,
          place.administrativeArea
        ].where((part) => part != null && part.isNotEmpty).toList();
        
        return addressParts.join(', ');
      }
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      if (_debugMode) debugPrint('❌ 주소 변환 오류: $e');
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
  }

  // Save location to cache
  Future<void> _cacheLocation(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_cachedLatKey, latitude);
      await prefs.setDouble(_cachedLngKey, longitude);
      await prefs.setInt(_cachedTimestampKey, DateTime.now().millisecondsSinceEpoch);
      if (_debugMode) debugPrint('💾 위치 정보 캐시 저장: $latitude, $longitude');
    } catch (e) {
      if (_debugMode) debugPrint('❌ 위치 캐싱 실패: $e');
    }
  }

  // Get cached location if available and not expired
  Future<LocationResult?> _getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedLat = prefs.getDouble(_cachedLatKey);
      final cachedLng = prefs.getDouble(_cachedLngKey);
      final timestamp = prefs.getInt(_cachedTimestampKey);

      if (cachedLat != null && cachedLng != null && timestamp != null) {
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        
        // Check if cache is still valid
        if (now.difference(cachedTime) < _cacheTtl) {
          if (_debugMode) debugPrint('💾 캐시된 위치 사용: $cachedLat, $cachedLng (${now.difference(cachedTime).inHours}시간 전)');
          
          return LocationResult.success(
            latitude: cachedLat,
            longitude: cachedLng,
            source: LocationSource.CACHED,
          );
        } else {
          if (_debugMode) debugPrint('⚠️ 캐시된 위치가 만료되었습니다');
        }
      }
      
      return null;
    } catch (e) {
      if (_debugMode) debugPrint('❌ 캐시된 위치 확인 실패: $e');
      return null;
    }
  }

  // Get default location from config
  Future<LocationResult> _getFallbackLocation(String errorMessage) async {
    final defaultLocation = EnvConfig.instance.mapDefaultLocation;
    if (_debugMode) debugPrint('🗺️ 기본 위치 사용: ${defaultLocation['latitude']}, ${defaultLocation['longitude']} (오류: $errorMessage)');
    
    return LocationResult.failure(
      fallbackLatitude: defaultLocation['latitude']!,
      fallbackLongitude: defaultLocation['longitude']!,
      fallbackSource: LocationSource.DEFAULT,
      errorMessage: errorMessage,
    );
  }

  // Helper to create a NLatLng for Naver Maps
  NLatLng createLatLng(double latitude, double longitude) {
    return NLatLng(latitude, longitude);
  }

  // Calculate distance between two points in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings for permission management
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // 마지막 위치 저장
  Future<void> _saveLastKnownLocation() async {
    if (_lastKnownPosition != null) {
      await _cacheLocation(_lastKnownPosition!.latitude, _lastKnownPosition!.longitude);
      if (_debugMode) debugPrint('마지막 위치 저장: ${_lastKnownPosition!.latitude}, ${_lastKnownPosition!.longitude}');
    }
  }
  
  // 서비스 정리
  Future<void> dispose() async {
    _locationSubscription?.cancel();
    await _saveLastKnownLocation();
    debugPrint('UnifiedLocationService disposed');
  }
}

// 주석: 중복된 Provider 선언 제거됨
