import 'dart:math';

class ReportLocation {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  ReportLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ReportLocation.fromJson(Map<String, dynamic> json) {
    return ReportLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class ReportManager {
  static final ReportManager _instance = ReportManager._internal();
  factory ReportManager() => _instance;
  ReportManager._internal();

  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'title': '쓰레기 발견 신고',
      'category': '안전',
      'status': '처리중',
      'date': '2024-01-15',
      'location': ReportLocation(
        latitude: 37.5665,
        longitude: 126.9780,
        address: '서울시 중구 태평로1가 31',
        timestamp: DateTime.now(),
      ).toJson(),
    },
    {
      'id': '2',
      'title': '손상된 도로 신고',
      'category': '안전',
      'status': '완료',
      'date': '2024-01-14',
      'location': ReportLocation(
        latitude: 37.4979,
        longitude: 127.0276,
        address: '서울시 서초구 서초대로 396',
        timestamp: DateTime.now(),
      ).toJson(),
    },
  ];

  List<Map<String, dynamic>> get reports => List.unmodifiable(_reports);

  void addReport(Map<String, dynamic> report) {
    _reports.insert(0, report); // 맨 앞에 추가
  }

  void updateReport(String id, Map<String, dynamic> updatedReport) {
    final index = _reports.indexWhere((report) => report['id'] == id);
    if (index != -1) {
      _reports[index] = updatedReport;
    }
  }

  void removeReport(String id) {
    _reports.removeWhere((report) => report['id'] == id);
  }

  String generateNextId() {
    final maxId = _reports.fold<int>(0, (max, report) {
      final id = int.tryParse(report['id']?.toString() ?? '0') ?? 0;
      return id > max ? id : max;
    });
    return '${maxId + 1}';
  }

  /// 위치 정보와 함께 신고서 생성
  void addReportWithLocation({
    required String title,
    required String category,
    required String description,
    required ReportLocation location,
    List<String>? imagePaths,
    Map<String, dynamic>? additionalData,
  }) {
    final report = {
      'id': generateNextId(),
      'title': title,
      'category': category,
      'description': description,
      'status': '접수',
      'date': DateTime.now().toIso8601String().split('T')[0],
      'location': location.toJson(),
      'images': imagePaths ?? [],
      'createdAt': DateTime.now().toIso8601String(),
      ...?additionalData,
    };

    _reports.insert(0, report);
  }

  /// 신고서 목록을 위치별로 필터링
  List<Map<String, dynamic>> getReportsByLocation({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) {
    return _reports.where((report) {
      final locationData = report['location'] as Map<String, dynamic>?;
      if (locationData == null) return false;

      final location = ReportLocation.fromJson(locationData);
      final distance = _calculateDistance(
        centerLat,
        centerLng,
        location.latitude,
        location.longitude,
      );

      return distance <= radiusKm;
    }).toList();
  }

  /// 두 지점 간의 거리 계산 (km 단위)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // 지구 반지름 (km)
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double lat1Rad = _toRadians(lat1);
    final double lat2Rad = _toRadians(lat2);
    final double a =
        pow(sin(dLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// 신고서의 위치 정보 가져오기
  ReportLocation? getReportLocation(String reportId) {
    final report = _reports.firstWhere(
      (r) => r['id'] == reportId,
      orElse: () => {},
    );

    if (report.isEmpty || report['location'] == null) return null;

    return ReportLocation.fromJson(report['location'] as Map<String, dynamic>);
  }

  /// 모든 신고서의 위치 정보 목록
  List<ReportLocation> getAllReportLocations() {
    return _reports
        .where((report) => report['location'] != null)
        .map(
          (report) => ReportLocation.fromJson(
            report['location'] as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
