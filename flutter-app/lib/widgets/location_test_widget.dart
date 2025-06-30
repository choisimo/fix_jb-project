import 'package:flutter/material.dart';
import '../core/services/location_service.dart';

/// 위치 서비스 테스트 위젯
/// 개발/디버깅 시 위치 기능을 테스트하기 위한 위젯
class LocationTestWidget extends StatefulWidget {
  const LocationTestWidget({Key? key}) : super(key: key);

  @override
  State<LocationTestWidget> createState() => _LocationTestWidgetState();
}

class _LocationTestWidgetState extends State<LocationTestWidget> {
  final LocationService _locationService = LocationService();
  String _locationInfo = '위치 정보 없음';
  String _statusInfo = '상태 확인 필요';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await _locationService.getLocationServiceStatus();
      setState(() {
        _statusInfo =
            '서비스: ${status['serviceEnabled'] ? "활성화" : "비활성화"}\n'
            '권한: ${status['permission']}\n'
            '사용가능: ${status['canGetLocation'] ? "예" : "아니오"}';
      });
    } catch (e) {
      setState(() {
        _statusInfo = '상태 확인 실패: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationInfo = '위치 확인 중...';
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _locationInfo =
            '📍 위치 정보:\n'
            '위도: ${position.latitude.toStringAsFixed(6)}\n'
            '경도: ${position.longitude.toStringAsFixed(6)}\n'
            '정확도: ${position.accuracy.toStringAsFixed(1)}m\n'
            '주소: $address\n'
            '시간: ${position.timestamp.toString().substring(0, 19)}';
      });
    } catch (e) {
      setState(() {
        _locationInfo = '위치 오류: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testLocationProviders() async {
    setState(() {
      _isLoading = true;
    });

    // 콘솔에 상세 디버깅 정보 출력 (개발자 도구에서 확인)
    await _locationService.checkLocationProviders();

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('콘솔에서 위치 제공자 정보를 확인하세요'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 서비스 테스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상태 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔧 서비스 상태',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_statusInfo, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 위치 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📍 위치 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_locationInfo, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 테스트 버튼들
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: _checkLocationStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('상태 새로고침'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _testCurrentLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('현재 위치 가져오기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _testLocationProviders,
                icon: const Icon(Icons.developer_mode),
                label: const Text('위치 제공자 테스트'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 안내 텍스트
            const Card(
              color: Colors.lightBlue,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 테스트 팁',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 에뮬레이터: Extended Controls > Location에서 한국 좌표 설정\n'
                      '• 실제 기기: 야외에서 GPS 신호가 잘 잡히는 곳에서 테스트\n'
                      '• 콘솔 로그에서 상세한 디버깅 정보 확인 가능',
                      style: TextStyle(fontSize: 14, color: Colors.white),
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
}
