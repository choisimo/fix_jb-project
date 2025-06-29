import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// 위치 서비스 클래스
/// GPS 위치 정보 및 주소 변환 기능 제공
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// 위치 권한 요청
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException('위치 서비스가 비활성화되어 있습니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionDeniedException('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
    }

    return true;
  }

  /// 현재 위치 가져오기 (개선된 버전)
  Future<Position> getCurrentPosition() async {
    try {
      print('🔍 위치 서비스 시작...');
      
      // 디버깅 정보 출력
      await debugLocationService();
      
      await requestLocationPermission();
      print('✅ 위치 권한 확인 완료');

      // 여러 정확도 레벨로 시도
      List<LocationAccuracy> accuracyLevels = [
        LocationAccuracy.best,
        LocationAccuracy.high,
        LocationAccuracy.medium,
        LocationAccuracy.low,
      ];
      
      for (LocationAccuracy accuracy in accuracyLevels) {
        try {
          print('🎯 정확도 레벨 시도: $accuracy');
          
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: accuracy,
            timeLimit: Duration(seconds: 15),
          );
          
          print('✅ 위치 획득 성공: ${position.latitude}, ${position.longitude}');
          print('📊 정확도: ${position.accuracy}m, 시간: ${position.timestamp}');
          
          // 한국 범위 확인
          bool isInKorea = _isPositionInKorea(position);
          print('🏠 위치 확인: ${isInKorea ? "한국 내" : "해외"}');
          
          if (!isInKorea) {
            print('⚠️ 해외 위치 감지. 에뮬레이터 GPS 설정 확인 필요');
            _printLocationTroubleshooting();
          }
          
          return position;
        } catch (e) {
          print('❌ 정확도 $accuracy 실패: $e');
          continue;
        }
      }
      
      // 모든 정확도 레벨 실패시 마지막 위치 시도
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        print('📍 마지막 알려진 위치 사용: ${lastPosition.latitude}, ${lastPosition.longitude}');
        
        bool isInKorea = _isPositionInKorea(lastPosition);
        if (!isInKorea) {
          print('⚠️ 마지막 위치도 해외. 기본 위치 사용');
          return _getDefaultSeoulPosition();
        }
        return lastPosition;
      }
      
      throw Exception('모든 위치 가져오기 방법 실패');
      
    } catch (e) {
      print('❌ 위치 가져오기 최종 실패: $e');
      print('🔧 기본 위치(서울) 사용');
      
      return _getDefaultSeoulPosition();
    }
  }

  /// 한국 영역 확인 (더 정확한 좌표)
  bool _isPositionInKorea(Position position) {
    return position.latitude >= 33.0 && position.latitude <= 43.0 &&
           position.longitude >= 124.0 && position.longitude <= 132.0;
  }

  /// 기본 서울 위치 반환
  Position _getDefaultSeoulPosition() {
    print('🏙️ 기본 위치(서울) 적용: 37.5665, 126.9780');
    return Position(
      longitude: 126.9780,  // 서울 경도
      latitude: 37.5665,    // 서울 위도
      timestamp: DateTime.now(),
      accuracy: 100.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  /// 위치 문제 해결 가이드 출력
  void _printLocationTroubleshooting() {
    print('');
    print('🔧 위치 문제 해결 가이드:');
    print('');
    print('📱 에뮬레이터 사용 시:');
    print('1. Extended Controls > Location');
    print('2. 한국 좌표 설정: 37.5665, 126.9780');
    print('3. Send 버튼 클릭');
    print('');
    print('🏠 실제 기기 사용 시:');
    print('1. 설정 > 위치 > 위치 서비스 켜기');
    print('2. 설정 > 위치 > 높은 정확도 선택');
    print('3. 야외에서 GPS 신호 수신 확인');
    print('');
  }

  /// 좌표를 주소로 변환
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.administrativeArea ?? ''} ${place.locality ?? ''} ${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}'
            .trim()
            .replaceAll(RegExp(r'\s+'), ' ');
      }
      return '주소를 찾을 수 없습니다';
    } catch (e) {
      print('주소 변환 오류: $e');
      return '주소 변환 실패';
    }
  }

  /// 주소를 좌표로 변환
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations[0];
        return Position(
          longitude: location.longitude,
          latitude: location.latitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      print('좌표 변환 오류: $e');
      return null;
    }
  }

  /// 두 지점 간의 거리 계산 (미터 단위)
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

  /// 위치 스트림 (실시간 위치 추적)
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터마다 업데이트
      ),
    );
  }

  /// 위치 서비스 상태 전체 확인
  Future<Map<String, dynamic>> getLocationServiceStatus() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      
      print('📡 위치 서비스 활성화: $serviceEnabled');
      print('🔐 위치 권한: $permission');
      
      Map<String, dynamic> status = {
        'serviceEnabled': serviceEnabled,
        'permission': permission.toString(),
        'canGetLocation': serviceEnabled && 
                        (permission == LocationPermission.always || 
                         permission == LocationPermission.whileInUse),
      };
      
      if (!serviceEnabled) {
        print('⚠️ 위치 서비스가 비활성화되어 있습니다.');
        print('💡 해결방법: 기기 설정 > 위치 > 위치 서비스 켜기');
      }
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        print('⚠️ 위치 권한이 거부되었습니다.');
        print('💡 해결방법: 앱 설정 > 권한 > 위치 권한 허용');
      }
      
      return status;
    } catch (e) {
      print('❌ 위치 서비스 상태 확인 실패: $e');
      return {
        'error': e.toString(),
        'canGetLocation': false,
      };
    }
  }

  /// 위치 서비스 디버깅 정보 출력
  Future<void> debugLocationService() async {
    try {
      print('🔧 위치 서비스 디버깅 시작');
      
      // 1. 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('📡 위치 서비스: ${serviceEnabled ? "활성화" : "비활성화"}');
      
      // 2. 권한 상태 확인
      LocationPermission permission = await Geolocator.checkPermission();
      print('🔐 위치 권한: $permission');
      
      // 3. 마지막 알려진 위치 확인
      try {
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          print('📍 마지막 위치: ${lastPosition.latitude}, ${lastPosition.longitude}');
          print('⏰ 마지막 위치 시간: ${lastPosition.timestamp}');
        } else {
          print('📍 마지막 위치: 없음');
        }
      } catch (e) {
        print('❌ 마지막 위치 확인 실패: $e');
      }
      
      print('🔧 위치 서비스 디버깅 완료');
    } catch (e) {
      print('❌ 디버깅 정보 확인 실패: $e');
    }
  }

  /// 위치 제공자별 정보 확인
  Future<void> checkLocationProviders() async {
    try {
      print('🔍 위치 제공자 확인 시작');
      
      // 네트워크 기반 위치
      try {
        Position networkPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        );
        print('📶 네트워크 위치: ${networkPosition.latitude}, ${networkPosition.longitude}');
        print('📊 네트워크 정확도: ${networkPosition.accuracy}m');
      } catch (e) {
        print('❌ 네트워크 위치 실패: $e');
      }
      
      // GPS 기반 위치
      try {
        Position gpsPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        );
        print('🛰️ GPS 위치: ${gpsPosition.latitude}, ${gpsPosition.longitude}');
        print('📊 GPS 정확도: ${gpsPosition.accuracy}m');
      } catch (e) {
        print('❌ GPS 위치 실패: $e');
      }
      
    } catch (e) {
      print('❌ 위치 제공자 확인 실패: $e');
    }
  }
}

/// 위치 서비스 예외 클래스들
class LocationServiceDisabledException implements Exception {
  final String message;
  const LocationServiceDisabledException(this.message);

  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}
