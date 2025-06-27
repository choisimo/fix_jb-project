import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class RoboflowService {
  static final RoboflowService _instance = RoboflowService._internal();
  static RoboflowService get instance => _instance;
  RoboflowService._internal();

  // Roboflow API 설정 (실제 프로젝트에서는 환경변수로 관리)
  static const String _apiUrl = 'https://detect.roboflow.com';
  static const String _modelEndpoint = 'jeonbuk-objects-detection/1';
  static const String _apiKey = 'your-roboflow-api-key'; // 실제 API 키로 교체 필요

  // 감지 가능한 객체 클래스 (16개)
  static const List<String> supportedClasses = [
    'road_damage', // 도로 파손
    'pothole', // 포트홀
    'illegal_dumping', // 무단 투기
    'graffiti', // 낙서
    'broken_sign', // 간판 파손
    'broken_fence', // 펜스 파손
    'street_light_out', // 가로등 고장
    'manhole_damage', // 맨홀 손상
    'sidewalk_crack', // 인도 균열
    'tree_damage', // 나무 손상
    'construction_issue', // 공사 문제
    'traffic_sign_damage', // 교통 표지판 손상
    'building_damage', // 건물 손상
    'water_leak', // 누수
    'electrical_hazard', // 전기 위험
    'other_public_issue', // 기타 공공 문제
  ];

  /// 이미지에서 객체를 감지합니다
  Future<ObjectDetectionResult> detectObjects(File imageFile) async {
    try {
      // 개발 모드에서는 목업 데이터 반환
      if (kDebugMode) {
        return _getMockDetectionResult(imageFile);
      }

      // 이미지 전처리 (크기 조정 및 압축)
      final processedImage = await _preprocessImage(imageFile);

      // Roboflow API 호출
      final response = await _callRoboflowAPI(processedImage);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return _parseDetectionResponse(jsonResponse, imageFile);
      } else {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Object detection error: $e');
      // 에러 발생 시 빈 결과 반환
      return ObjectDetectionResult(
        imagePath: imageFile.path,
        detections: [],
        confidence: 0.0,
        processingTime: 0,
      );
    }
  }

  /// 이미지 전처리 (크기 조정 및 최적화)
  Future<Uint8List> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('이미지 디코딩 실패');

    // 최대 크기 1024x1024로 조정
    final resized = img.copyResize(
      image,
      width: image.width > 1024 ? 1024 : null,
      height: image.height > 1024 ? 1024 : null,
    );

    // JPEG로 압축 (품질 85%)
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  /// Roboflow API 호출
  Future<http.Response> _callRoboflowAPI(Uint8List imageBytes) async {
    final uri = Uri.parse('$_apiUrl/$_modelEndpoint');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $_apiKey';

    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: 'image.jpg'),
    );

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  /// API 응답 파싱
  ObjectDetectionResult _parseDetectionResponse(
    Map<String, dynamic> jsonResponse,
    File originalImage,
  ) {
    final predictions = jsonResponse['predictions'] as List? ?? [];
    final detections = <DetectedObject>[];

    for (final prediction in predictions) {
      final detection = DetectedObject(
        className: prediction['class'] as String,
        confidence: (prediction['confidence'] as num).toDouble(),
        boundingBox: BoundingBox(
          x: (prediction['x'] as num).toDouble(),
          y: (prediction['y'] as num).toDouble(),
          width: (prediction['width'] as num).toDouble(),
          height: (prediction['height'] as num).toDouble(),
        ),
      );

      // 신뢰도 50% 이상만 포함
      if (detection.confidence >= 0.5) {
        detections.add(detection);
      }
    }

    return ObjectDetectionResult(
      imagePath: originalImage.path,
      detections: detections,
      confidence: detections.isNotEmpty
          ? detections.map((d) => d.confidence).reduce((a, b) => a + b) /
                detections.length
          : 0.0,
      processingTime: jsonResponse['inference_time'] as int? ?? 0,
    );
  }

  /// 개발 모드용 목업 데이터
  ObjectDetectionResult _getMockDetectionResult(File imageFile) {
    // 랜덤하게 1-3개의 객체 감지 시뮬레이션
    final random = DateTime.now().millisecond;
    final numDetections = (random % 3) + 1;

    final detections = <DetectedObject>[];
    final classes = ['road_damage', 'pothole', 'illegal_dumping'];

    for (int i = 0; i < numDetections; i++) {
      detections.add(
        DetectedObject(
          className: classes[i % classes.length],
          confidence: 0.75 + (random % 20) / 100, // 0.75 ~ 0.95
          boundingBox: BoundingBox(
            x: 100.0 + (i * 50),
            y: 100.0 + (i * 30),
            width: 120.0,
            height: 80.0,
          ),
        ),
      );
    }

    return ObjectDetectionResult(
      imagePath: imageFile.path,
      detections: detections,
      confidence: detections.isNotEmpty ? 0.83 : 0.0,
      processingTime: 250, // 250ms 시뮬레이션
    );
  }

  /// 클래스명을 한국어로 변환
  static String getKoreanClassName(String className) {
    const classNameMap = {
      'road_damage': '도로 파손',
      'pothole': '포트홀',
      'illegal_dumping': '무단 투기',
      'graffiti': '낙서',
      'broken_sign': '간판 파손',
      'broken_fence': '펜스 파손',
      'street_light_out': '가로등 고장',
      'manhole_damage': '맨홀 손상',
      'sidewalk_crack': '인도 균열',
      'tree_damage': '나무 손상',
      'construction_issue': '공사 문제',
      'traffic_sign_damage': '교통 표지판 손상',
      'building_damage': '건물 손상',
      'water_leak': '누수',
      'electrical_hazard': '전기 위험',
      'other_public_issue': '기타 공공 문제',
    };
    return classNameMap[className] ?? className;
  }

  /// 감지된 객체에 따른 신고 카테고리 추천
  static String recommendCategory(List<DetectedObject> detections) {
    if (detections.isEmpty) return '기타';

    final mostConfidentDetection = detections.reduce(
      (a, b) => a.confidence > b.confidence ? a : b,
    );

    const categoryMap = {
      'road_damage': '도로/교통',
      'pothole': '도로/교통',
      'traffic_sign_damage': '도로/교통',
      'illegal_dumping': '환경/위생',
      'graffiti': '환경/위생',
      'water_leak': '상하수도',
      'street_light_out': '전기/조명',
      'electrical_hazard': '전기/조명',
      'building_damage': '건축물',
      'broken_sign': '건축물',
      'broken_fence': '공원/시설물',
      'manhole_damage': '공원/시설물',
      'sidewalk_crack': '공원/시설물',
      'tree_damage': '공원/시설물',
      'construction_issue': '공사/안전',
    };

    return categoryMap[mostConfidentDetection.className] ?? '기타';
  }

  /// 감지된 객체에 따른 우선순위 추천
  static String recommendPriority(List<DetectedObject> detections) {
    if (detections.isEmpty) return '보통';

    const highPriorityClasses = {
      'electrical_hazard',
      'water_leak',
      'construction_issue',
      'pothole',
    };

    final hasHighPriority = detections.any(
      (d) => highPriorityClasses.contains(d.className),
    );

    if (hasHighPriority) return '긴급';

    final avgConfidence =
        detections.map((d) => d.confidence).reduce((a, b) => a + b) /
        detections.length;

    return avgConfidence > 0.85 ? '높음' : '보통';
  }
}

/// 객체 감지 결과 클래스
class ObjectDetectionResult {
  final String imagePath;
  final List<DetectedObject> detections;
  final double confidence;
  final int processingTime;

  ObjectDetectionResult({
    required this.imagePath,
    required this.detections,
    required this.confidence,
    required this.processingTime,
  });

  bool get hasDetections => detections.isNotEmpty;

  String get summary {
    if (detections.isEmpty) return '감지된 객체 없음';

    final classNames = detections
        .map((d) => RoboflowService.getKoreanClassName(d.className))
        .toSet()
        .join(', ');

    return '감지된 객체: $classNames (${detections.length}개)';
  }
}

/// 감지된 객체 정보
class DetectedObject {
  final String className;
  final double confidence;
  final BoundingBox boundingBox;

  DetectedObject({
    required this.className,
    required this.confidence,
    required this.boundingBox,
  });

  String get koreanName => RoboflowService.getKoreanClassName(className);
  String get confidencePercent => '${(confidence * 100).toInt()}%';
}

/// 바운딩 박스 정보
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get left => x - (width / 2);
  double get top => y - (height / 2);
  double get right => x + (width / 2);
  double get bottom => y + (height / 2);
}
