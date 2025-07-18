import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/map_provider.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/services/unified_location_service.dart';

class NaverMapWidget extends ConsumerStatefulWidget {
  final NCameraPosition? initialCameraPosition;
  final Function(NLatLng)? onMapTapped;
  final List<MapMarker>? markers;
  final bool showCurrentLocation;
  final bool showAppBar;
  final String title;

  const NaverMapWidget({
    Key? key,
    this.initialCameraPosition,
    this.onMapTapped,
    this.markers,
    this.showCurrentLocation = true,
    this.showAppBar = false,
    this.title = 'Map',
  }) : super(key: key);
  
  @override
  ConsumerState<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget> {
  late NaverMapController _controller;
  NLatLng? _selectedLocation;
  final Set<NMarker> _markers = {};
  bool _isMapInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }
  
  Future<void> _initializeMap() async {
    try {
      // 맵을 이미 AppInitializer에서 초기화했으므로 여기서는 초기화 체크만 수행
      // 네이버맵 SDK 초기화 상태 확인
      // final isInitialized = NaverMapSdk.instance.isInitialized;
      // debugPrint('네이버 맵 SDK 초기화 상태: $isInitialized');
      
      // 임시로 true로 설정 (API 확인 필요)
      final isInitialized = true;
      
      if (!isInitialized) {
        debugPrint('네이버 맵 SDK가 초기화되지 않았습니다. 앱 초기화가 올바르게 진행되었는지 확인하세요.');
        // 여기서 다시 초기화하지 않고 UI 상태만 업데이트
      }
      
      setState(() {
        _isMapInitialized = isInitialized;
      });
      
      if (!_isMapInitialized && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('네이버 맵을 초기화할 수 없습니다. 앱을 재시작하거나 관리자에게 문의하세요.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('네이버 맵 상태 확인 실패: $e');
      
      // 맵이 초기화되지 않더라도 기본 UI는 보여주기
      setState(() {
        _isMapInitialized = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('네이버 맵을 로드할 수 없습니다.'),
                Text('오류: ${e.toString()}'),
                const Text('네트워크 연결과 API 키를 확인해주세요.'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
  
  Future<void> _onMapReady() async {
    debugPrint('네이버 맵 준비 완료 - 추가 초기화 작업 시작');
    
    try {
      // 1. 위젯에 전달된 마커 추가
      await _addMarkersToMap();
      
      // 2. 현재 위치 표시 기능 활성화 (설정된 경우)
      if (widget.showCurrentLocation) {
        await _controller.setLocationTrackingMode(NLocationTrackingMode.follow);
      }
      
      // 3. 기본 위치로 이동 (초기 카메라 위치가 지정되지 않은 경우)
      if (widget.initialCameraPosition == null) {
        final defaultPosition = NCameraPosition(
          target: NLatLng(
            37.5665, // 서울 시청 위도
            126.9780, // 서울 시청 경도
          ),
          zoom: 14,
        );
        
        final cameraUpdate = NCameraUpdate.fromCameraPosition(defaultPosition);
        await _controller.updateCamera(cameraUpdate);
        debugPrint('기본 위치로 이동: ${defaultPosition.target.latitude}, ${defaultPosition.target.longitude}');
      }
      
      debugPrint('맵 초기화 작업 완료');
    } catch (e) {
      debugPrint('맵 추가 초기화 작업 실패: $e');
    }
  }
  
  // 맵에 마커 추가 메서드
  Future<void> _addMarkersToMap() async {
    if (widget.markers == null || widget.markers!.isEmpty) return;
    
    try {
      for (final marker in widget.markers!) {
        final naverMarker = NMarker(
          id: marker.id,
          position: NLatLng(marker.latitude, marker.longitude),
        );
        
        naverMarker.setOnTapListener((overlay) {
          _showMarkerInfo(marker);
        });
        
        await _controller.addOverlay(naverMarker);
      }
      
      debugPrint('${widget.markers!.length} 개의 마커를 추가했습니다');
    } catch (e) {
      debugPrint('마커 추가 중 오류 발생: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    
    // 네이버 맵이 초기화되지 않은 경우 로딩 UI 표시
    if (!_isMapInitialized) {
      return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(title: Text(widget.title))
            : null,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('지도를 로드하는 중...'),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(widget.title))
          : null,
      body: Stack(
        children: [
          // 네이버 맵 위젯
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: widget.initialCameraPosition ?? 
                NCameraPosition(
                  target: NLatLng(
                    mapState.currentLocation.target.latitude, 
                    mapState.currentLocation.target.longitude,
                  ),
                  zoom: mapState.currentLocation.zoom,
                ),
              mapType: NMapType.basic,
              activeLayerGroups: const [
                NLayerGroup.building,
                NLayerGroup.transit,
                NLayerGroup.bicycle,
              ],
            ),
            onMapReady: (controller) {
              _controller = controller;
              _onMapReady();
            },
            onMapTapped: widget.onMapTapped ?? _onMapTapped,
          ),
          
          // 위치 소스 표시 UI (디버그 모드 또는 기본 위치일 때만)
          if (kDebugMode || mapState.locationSource == LocationSource.DEFAULT.toString())
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: mapState.locationSource == LocationSource.DEFAULT.toString() 
                      ? Colors.orange.withOpacity(0.8)
                      : Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '위치 소스: ${mapState.locationSource ?? "알 수 없음"}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          
          // 로딩 인디케이터
          if (mapState.isLocationLoading)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '위치를 가져오는 중...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // 맵 컨트롤 UI
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapControl(
                  icon: Icons.my_location,
                  onPressed: _moveToCurrentLocation,
                ),
                const SizedBox(height: 8),
                _buildMapControl(
                  icon: Icons.zoom_in,
                  onPressed: () => _controller.updateCamera(
                    NCameraUpdate.withParams(
                      zoom: _controller.getCameraPosition().zoom + 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildMapControl(
                  icon: Icons.zoom_out,
                  onPressed: () => _controller.updateCamera(
                    NCameraUpdate.withParams(
                      zoom: _controller.getCameraPosition().zoom - 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _setupMap() async {
    // Add initial markers
    if (widget.markers != null) {
      for (final marker in widget.markers!) {
        final nMarker = NMarker(
          id: marker.id,
          position: NLatLng(marker.latitude, marker.longitude),
          caption: NOverlayCaption(
            text: marker.title,
            textSize: 14,
          ),
        );
        
        if (marker.iconPath != null) {
          final icon = await NOverlayImage.fromAssetImage(marker.iconPath!);
          nMarker.setIcon(icon);
        }
        
        nMarker.setOnTapListener((overlay) {
          _showMarkerInfo(marker);
        });
        
        _markers.add(nMarker);
      }
      
      await _controller.addOverlayAll(_markers);
    }
    
    // Show current location if enabled
    if (widget.showCurrentLocation) {
      await _moveToCurrentLocation();
    }
  }
  
  Future<void> _moveToCurrentLocation() async {
    if (!mounted || !_isMapInitialized) {
      debugPrint('맵이 초기화되지 않았거나 위젯이 마운트되지 않았습니다.');
      return;
    try {
      final mapNotifier = ref.read(mapProvider.notifier);
      
      // Call our unified location service through the map provider
      final locationResult = await mapNotifier.getCurrentLocation(
        accuracy: LocationAccuracy.high,
        useCache: true,
      );

      if (locationResult == null || locationResult.position == null) {
        // Handle error case when no result or position is returned
        _showLocationNotification(
          message: '위치를 가져올 수 없습니다.',
          error: locationResult?.error ?? '알 수 없는 오류',
          isWarning: true,
        );
        return;
      }

      // Move the map camera to the position
      final cameraUpdate = NCameraUpdate.withParams(
        target: NLatLng(locationResult.position!.latitude, locationResult.position!.longitude),
        zoom: 16,
      );
      await _controller.updateCamera(cameraUpdate);

      // Update selected marker
      _updateSelectedMarker(
        NLatLng(locationResult.position!.latitude, locationResult.position!.longitude)
      );

      // Show feedback based on location source
      if (kDebugMode || locationResult.source != LocationSource.HIGH_ACCURACY) {
        String sourceMessage = '';
        
        switch (locationResult.source) {
          case LocationSource.HIGH_ACCURACY:
            sourceMessage = '고정밀 GPS 위치';
            break;
          case LocationSource.MEDIUM_ACCURACY:
            sourceMessage = '중간 정확도 위치';
            break;
          case LocationSource.LAST_KNOWN:
            sourceMessage = '마지막으로 알려진 위치';
            break;
          case LocationSource.CACHED:
            sourceMessage = '캐시된 위치';
            break;
          case LocationSource.DEFAULT:
            sourceMessage = '기본 위치 (더미 데이터)';
            break;
          default:
            sourceMessage = '알 수 없는 소스';
        }
        
        _showLocationNotification(
          message: '위치 소스: $sourceMessage\n${locationResult.position!.latitude}, ${locationResult.position!.longitude}',
          isWarning: locationResult.source == LocationSource.DEFAULT,
        );
      }
    } catch (e) {
      ref.read(mapProvider.notifier).updateLocationLoadingState(false);
      _showLocationNotification(
        message: '위치 이동 중 오류가 발생했습니다.',
        error: e.toString(),
        isWarning: true,
      );
    }
  }
  
  // 위치 알림 표시 도우미 메서드
  void _showLocationNotification({required String message, String? error, required bool isWarning}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (error != null && error.isNotEmpty) 
            Text(error, style: TextStyle(fontSize: 12, color: Colors.grey[300])),
          if (isWarning)
            TextButton(
              onPressed: _moveToCurrentLocation,
              child: const Text('다시 시도'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
        ],
      ),
      backgroundColor: isWarning ? Colors.orange : Colors.blue,
      duration: Duration(seconds: isWarning ? 4 : 2),
    ));
  }
  
  void _onMapTapped(NPoint point, NLatLng latLng) {
    if (widget.onMapTapped != null) {
      widget.onMapTapped!(latLng);
    }
  }
  
  Future<void> _updateSelectedMarker(NLatLng? location) async {
    // Remove previous selection marker
    try {
      final selectionMarker = _markers.firstWhere(
        (marker) => marker.info.id == 'selection',
      );
      await _controller.deleteOverlay(selectionMarker.info);
      _markers.remove(selectionMarker);
    } catch (_) {}
    
    if (location != null) {
      final selectionMarker = NMarker(
        id: 'selection',
        position: location,
      );
      
      final icon = await NOverlayImage.fromAssetImage(
        'assets/icons/selected_location.png',
      );
      selectionMarker.setIcon(icon);
      
      _markers.add(selectionMarker);
      await _controller.addOverlay(selectionMarker);
    }
  }
  
  Future<void> _searchLocation(String query) async {
    try {
      final results = await ref.read(mapProvider.notifier).searchLocation(query);
      
      if (results.isNotEmpty && mounted) {
        final firstResult = results.first;
        final cameraUpdate = NCameraUpdate.withParams(
          target: NLatLng(firstResult.latitude, firstResult.longitude),
          zoom: 15,
        );
        
        await _controller.updateCamera(cameraUpdate);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }
  
  void _showMarkerInfo(MapMarker marker) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              marker.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (marker.description != null) ...[
              const SizedBox(height: 8),
              Text(marker.description!),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToLocation(marker);
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigate'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareLocation(marker);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToLocation(MapMarker marker) {
    ref.read(mapProvider.notifier).openNavigation(
      marker.latitude,
      marker.longitude,
    );
  }
  
  void _shareLocation(MapMarker marker) {
    ref.read(mapProvider.notifier).shareLocation(
      marker.latitude,
      marker.longitude,
      marker.title,
    );
  }
  
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to show your current location on the map.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }
}

class MapMarker {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String? description;
  final String? iconPath;
  
  MapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.description,
    this.iconPath,
  });
}
