import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';

/// 지도 선택 위젯
/// 사용자가 지도에서 위치를 선택할 수 있는 기능 제공
class MapSelector extends StatefulWidget {
  final NLatLng? initialPosition;
  final Function(NLatLng position, String address)? onLocationSelected;
  final bool showCurrentLocationButton;
  final bool allowLocationSelection;
  final double height;

  const MapSelector({
    Key? key,
    this.initialPosition,
    this.onLocationSelected,
    this.showCurrentLocationButton = true,
    this.allowLocationSelection = true,
    this.height = 300,
  }) : super(key: key);

  @override
  State<MapSelector> createState() => _MapSelectorState();
}

class _MapSelectorState extends State<MapSelector> {
  NaverMapController? _mapController;
  final LocationService _locationService = LocationService();
  final Set<NMarker> _markers = {};
  NLatLng? _selectedPosition;
  String _selectedAddress = '';
  bool _isLoading = false;

  // 기본 위치 (서울시청)
  static const NLatLng _defaultPosition = NLatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _selectedPosition = widget.initialPosition;
      _updateMarker(_selectedPosition!);
      _updateAddress(_selectedPosition!);
    } else {
      _setCurrentLocationOnInit();
    }
  }

  void _setCurrentLocationOnInit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      final nLatLng = NLatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPosition = nLatLng;
      });
      _updateMarker(nLatLng);
      await _updateAddress(nLatLng);
      _mapController?.updateCamera(
        NCameraUpdate.withParams(target: nLatLng, zoom: 16.0),
      );
      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(nLatLng, _selectedAddress);
      }
    } catch (e) {
      // 위치 못 가져오면 기본 위치로 설정
      setState(() {
        _selectedPosition = _defaultPosition;
      });
      _updateMarker(_defaultPosition);
      await _updateAddress(_defaultPosition);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (_selectedPosition != null)
              NaverMap(
                options: NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: _selectedPosition!,
                    zoom: 15.0,
                  ),
                  locationButtonEnable: false,
                  consumeSymbolTapEvents: false,
                ),
                onMapReady: _onMapReady,
                onMapTapped: widget.allowLocationSelection
                    ? _onMapTapped
                    : null,
              )
            else
              const Center(child: CircularProgressIndicator()),

            // 현재 위치 버튼
            if (widget.showCurrentLocationButton)
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: Colors.blue),
                ),
              ),

            // 주소 정보 표시
            if (_selectedAddress.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '선택된 위치',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedPosition != null)
                        Text(
                          '위도: ${_selectedPosition!.latitude.toStringAsFixed(6)}, '
                          '경도: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    if (_markers.isNotEmpty) {
      _mapController!.addOverlayAll(_markers);
    }
  }

  void _onMapTapped(NPoint point, NLatLng nLatLng) {
    setState(() {
      _selectedPosition = nLatLng;
    });
    _updateMarker(nLatLng);
    _updateAddress(nLatLng);

    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(nLatLng, _selectedAddress);
    }
  }

  void _updateMarker(NLatLng position) {
    final marker = NMarker(id: 'selected_location', position: position);

    if (mounted) {
      _mapController?.clearOverlays();
      _mapController?.addOverlay(marker);
      setState(() {
        _markers.clear();
        _markers.add(marker);
      });
    }
  }

  Future<void> _updateAddress(NLatLng position) async {
    try {
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (mounted) {
        setState(() {
          _selectedAddress = address;
        });
      }
    } catch (e) {
      print('주소 업데이트 오류: $e');
      if (mounted) {
        setState(() {
          _selectedAddress = '주소를 가져올 수 없습니다';
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final nLatLng = NLatLng(position.latitude, position.longitude);

      setState(() {
        _selectedPosition = nLatLng;
      });

      final cameraUpdate = NCameraUpdate.withParams(
        target: nLatLng,
        zoom: 16.0,
      );
      _mapController?.updateCamera(cameraUpdate);

      _updateMarker(nLatLng);
      await _updateAddress(nLatLng);

      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(nLatLng, _selectedAddress);
      }
    } catch (e) {
      _showErrorSnackBar('현재 위치를 가져올 수 없습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
