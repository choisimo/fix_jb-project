import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/map_provider.dart';

class NaverMapWidget extends ConsumerStatefulWidget {
  final NCameraPosition? initialCameraPosition;
  final Function(NLatLng)? onMapTapped;
  final List<MapMarker>? markers;
  final bool showCurrentLocation;

  const NaverMapWidget({
    Key? key,
    this.initialCameraPosition,
    this.onMapTapped,
    this.markers,
    this.showCurrentLocation = true,
  }) : super(key: key);
  
  @override
  ConsumerState<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget> {
  late NaverMapController _controller;
  NLatLng? _selectedLocation;
  final Set<NMarker> _markers = {};
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }
  
  Future<void> _initializeMap() async {
    await NaverMapSdk.instance.initialize(
      clientId: 'YOUR_NAVER_CLIENT_ID', // Replace with actual client ID
      onAuthFailed: (error) {
        debugPrint('Naver Map Auth Failed: $error');
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    
    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: widget.initialCameraPosition ?? const NCameraPosition(
              target: NLatLng(37.5666805, 126.9784147),
              zoom: 15,
            ),
            mapType: NMapType.basic,
            activeLayerGroups: [
              NLayerGroup.building,
              NLayerGroup.transit,
            ],
            locationButtonEnable: widget.showCurrentLocation,
            consumeSymbolTapEvents: false,
          ),
          onMapReady: (controller) async {
            _controller = controller;
            await _setupMap();
          },
          onMapTapped: _onMapTapped,
          onCameraChange: (reason, animated) {
            // 필요한 경우 카메라 변경 처리 로직 추가
          },
        ),
        
        // Map controls
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapControl(
                icon: Icons.add,
                onPressed: () async {
                  final cameraUpdate = NCameraUpdate.withParams(
                    zoom: 1,
                  );
                  await _controller.updateCamera(cameraUpdate);
                },
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.remove,
                onPressed: () async {
                  final cameraUpdate = NCameraUpdate.withParams(
                    zoom: -1,
                  );
                  await _controller.updateCamera(cameraUpdate);
                },
              ),
              const SizedBox(height: 16),
              _buildMapControl(
                icon: Icons.my_location,
                onPressed: _moveToCurrentLocation,
              ),
            ],
          ),
        ),
        

          
        // Search bar
        Positioned(
          top: 16,
          left: 16,
          right: 72,
          child: Card(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: _searchLocation,
            ),
          ),
        ),
      ],
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
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          _showLocationPermissionDialog();
          return;
        }
      }
      
      final position = await Geolocator.getCurrentPosition();
      final cameraUpdate = NCameraUpdate.withParams(
        target: NLatLng(position.latitude, position.longitude),
        zoom: 15,
      );
      
      await _controller.updateCamera(cameraUpdate);
      
      // Add current location marker
      final currentLocationMarker = NMarker(
        id: 'current_location',
        position: NLatLng(position.latitude, position.longitude),
      );
      
      final icon = await NOverlayImage.fromAssetImage(
        'assets/icons/current_location.png',
      );
      currentLocationMarker.setIcon(icon);
      
      await _controller.addOverlay(currentLocationMarker);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get current location: $e')),
      );
    }
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
