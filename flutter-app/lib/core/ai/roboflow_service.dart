import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'roboflow_config.dart';

class RoboflowService {
  static final RoboflowService _instance = RoboflowService._internal();
  static RoboflowService get instance => _instance;
  RoboflowService._internal();

  // Roboflow API 설정 - 이제 RoboflowConfig에서 동적으로 가져옴
  static const String _apiUrl = 'https://detect.roboflow.com';

  // 백엔드 서버 설정 (선택사항 - 백엔드를 통한 분석)
  static const String _backendUrl = 'http://localhost:8080/api/v1/ai';

  // 설정에서 동적으로 모델 엔드포인트 생성
  static Future<String> get _modelEndpoint async {
    final config = RoboflowConfig.instance;
    final workspace = await config.getWorkspace();
    final project = await config.getProject();
    final version = await config.getVersion();
    return '$workspace/$project/$version';
  }

  // 설정에서 API 키 가져오기
  static Future<String> get _apiKey async {
    final config = RoboflowConfig.instance;
    final apiKey = await config.getApiKey();
    return apiKey ?? '';
  }

  // 백엔드 사용 여부 확인
  static Future<bool> get _useBackend async {
    final config = RoboflowConfig.instance;
    return await config.getUseBackend();
  }

  // API 키 설정
  static Future<bool> setApiKey(String apiKey) async {
    try {
      final config = RoboflowConfig.instance;
      final success = await config.setApiKey(apiKey);
      if (success) {
        debugPrint('🔑 API 키 설정 성공: ${_maskApiKey(apiKey)}');
      } else {
        debugPrint('❌ API 키 설정 실패');
      }
      return success;
    } catch (e) {
      debugPrint('❌ API 키 설정 오류: $e');
      return false;
    }
  }

  // Workspace 설정
  static Future<bool> setWorkspace(String workspace) async {
    try {
      final config = RoboflowConfig.instance;
      final success = await config.setWorkspace(workspace);
      if (success) {
        debugPrint('🏢 Workspace 설정 성공: $workspace');
      } else {
        debugPrint('❌ Workspace 설정 실패');
      }
      return success;
    } catch (e) {
      debugPrint('❌ Workspace 설정 오류: $e');
      return false;
    }
  }

  // Project 설정
  static Future<bool> setProject(String project) async {
    try {
      final config = RoboflowConfig.instance;
      final success = await config.setProject(project);
      if (success) {
        debugPrint('📁 Project 설정 성공: $project');
      } else {
        debugPrint('❌ Project 설정 실패');
      }
      return success;
    } catch (e) {
      debugPrint('❌ Project 설정 오류: $e');
      return false;
    }
  }

  // 모든 설정을 한 번에 저장
  static Future<bool> saveAllSettings({
    required String apiKey,
    required String workspace,
    required String project,
  }) async {
    try {
      final config = RoboflowConfig.instance;
      await config.initialize(); // 초기화 확인

      // 모든 설정 저장
      final apiKeySuccess = await config.setApiKey(apiKey);
      final workspaceSuccess = await config.setWorkspace(workspace);
      final projectSuccess = await config.setProject(project);

      final allSuccess = apiKeySuccess && workspaceSuccess && projectSuccess;

      if (allSuccess) {
        debugPrint('✅ 모든 설정 저장 완료');
        debugPrint('🔑 API Key: ${_maskApiKey(apiKey)}');
        debugPrint('🏢 Workspace: $workspace');
        debugPrint('📁 Project: $project');
      } else {
        debugPrint('❌ 일부 설정 저장 실패');
      }

      return allSuccess;
    } catch (e) {
      debugPrint('❌ 설정 저장 중 오류 발생: $e');
      return false;
    }
  }

  // API 키 마스킹 유틸리티
  static String _maskApiKey(String apiKey) {
    if (apiKey.length <= 8) return '****';
    return '${apiKey.substring(0, 4)}****${apiKey.substring(apiKey.length - 4)}';
  }

  // API 키가 설정되었는지 확인
  static Future<bool> get hasValidApiKey async {
    final apiKey = await _apiKey;
    final isValid =
        apiKey.isNotEmpty &&
        apiKey != 'your-roboflow-api-key' &&
        apiKey.length > 10; // 최소 길이 확인
    debugPrint('🔍 API 키 유효성: $isValid');
    return isValid;
  }

  // 현재 API 키 정보 (마스킹)
  static Future<String> get apiKeyInfo async {
    final valid = await hasValidApiKey;
    if (!valid) return '❌ 미설정';
    final apiKey = await _apiKey;
    if (apiKey.length < 8) return '⚠️ 너무 짧음';
    return '✅ ${_maskApiKey(apiKey)}';
  }

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
    final startTime = DateTime.now();

    try {
      debugPrint('🤖 AI 분석 시작: ${imageFile.path}');
      debugPrint('📄 파일 크기: ${await imageFile.length()} bytes');

      // 파일 존재 여부 확인
      if (!await imageFile.exists()) {
        throw Exception('이미지 파일이 존재하지 않습니다: ${imageFile.path}');
      }

      // 백엔드 사용 모드인 경우
      final useBackend = await _useBackend;
      if (useBackend) {
        debugPrint('🌐 백엔드 서버를 통한 분석...');
        return await _analyzeViaBackend(imageFile);
      }

      // 유효한 API 키가 없는 경우 목업 데이터 반환
      final validApiKey = await hasValidApiKey;
      if (!validApiKey) {
        debugPrint('📝 목업 모드로 분석 중... (API 키 없음)');
        final result = _getMockDetectionResult(imageFile);
        debugPrint('✅ 목업 분석 완료: ${result.detections.length}개 객체 감지');
        for (final detection in result.detections) {
          debugPrint(
            '   - ${detection.koreanName}: ${detection.confidencePercent}',
          );
        }
        return result;
      }

      // 개발 모드에서는 목업 데이터 사용 (실제 API 비용 절약)
      if (kDebugMode) {
        debugPrint('📝 목업 모드로 분석 중... (개발 모드)');
        final result = _getMockDetectionResult(imageFile);
        debugPrint('✅ 목업 분석 완료: ${result.detections.length}개 객체 감지');
        for (final detection in result.detections) {
          debugPrint(
            '   - ${detection.koreanName}: ${detection.confidencePercent}',
          );
        }
        return result;
      }

      debugPrint('🌐 실제 API 호출 중...');

      // 이미지 전처리 (크기 조정 및 압축)
      debugPrint('🔧 이미지 전처리 중...');
      final processedImage = await _preprocessImage(imageFile);
      debugPrint('✅ 전처리 완료: ${processedImage.length} bytes');

      // Roboflow API 호출
      final response = await _callRoboflowAPI(processedImage);

      if (response.statusCode == 200) {
        debugPrint('✅ API 호출 성공');
        try {
          final jsonResponse =
              json.decode(response.body) as Map<String, dynamic>;
          final result = _parseDetectionResponse(jsonResponse, imageFile);

          final processingTime = DateTime.now()
              .difference(startTime)
              .inMilliseconds;
          debugPrint('🎯 전체 처리 시간: ${processingTime}ms');

          return result;
        } catch (e) {
          debugPrint('❌ JSON 파싱 오류: $e');
          debugPrint('📄 원본 응답: ${response.body}');
          throw Exception('API 응답 파싱 실패: $e');
        }
      } else {
        debugPrint('❌ API 호출 실패: ${response.statusCode}');
        debugPrint('📄 오류 응답: ${response.body}');
        throw Exception('API 호출 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      final processingTime = DateTime.now()
          .difference(startTime)
          .inMilliseconds;
      debugPrint('❌ Object detection error (${processingTime}ms): $e');

      // 에러 발생 시에도 기본 결과 반환 (사용자 경험 향상)
      return ObjectDetectionResult(
        imagePath: imageFile.path,
        detections: [],
        confidence: 0.0,
        processingTime: processingTime,
      );
    }
  }

  /// 백엔드 서버를 통한 이미지 분석
  Future<ObjectDetectionResult> _analyzeViaBackend(File imageFile) async {
    try {
      final uri = Uri.parse('$_backendUrl/analyze');
      final request = http.MultipartRequest('POST', uri);

      // 이미지 파일 추가
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // 추가 파라미터
      request.fields['confidence'] = '50';
      request.fields['overlap'] = '30';

      debugPrint('📤 백엔드 요청: $uri');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        return _parseBackendResponse(jsonResponse, imageFile);
      } else {
        throw Exception('백엔드 API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 백엔드 분석 오류: $e');
      // 백엔드 실패 시 목업 데이터로 대체
      return _getMockDetectionResult(imageFile);
    }
  }

  /// 백엔드 응답 파싱
  ObjectDetectionResult _parseBackendResponse(
    Map<String, dynamic> jsonResponse,
    File originalImage,
  ) {
    try {
      debugPrint('🔍 백엔드 응답 파싱: $jsonResponse');

      final detections = <DetectedObject>[];
      final predictions = jsonResponse['detections'] as List? ?? [];

      for (final prediction in predictions) {
        try {
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

          if (detection.confidence >= 0.5) {
            detections.add(detection);
            debugPrint(
              '✅ 백엔드 감지: ${detection.className} (${detection.confidencePercent})',
            );
          }
        } catch (e) {
          debugPrint('❌ 백엔드 예측 파싱 오류: $e');
        }
      }

      return ObjectDetectionResult(
        imagePath: originalImage.path,
        detections: detections,
        confidence: detections.isNotEmpty
            ? detections.map((d) => d.confidence).reduce((a, b) => a + b) /
                  detections.length
            : 0.0,
        processingTime: jsonResponse['processing_time'] as int? ?? 0,
      );
    } catch (e) {
      debugPrint('❌ 백엔드 응답 파싱 오류: $e');
      return ObjectDetectionResult(
        imagePath: originalImage.path,
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
    try {
      final apiKey = await _apiKey;
      final modelEndpoint = await _modelEndpoint;
      final uri = Uri.parse('$_apiUrl/$modelEndpoint?api_key=$apiKey');

      debugPrint('🌐 Roboflow API 호출: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Roboflow API는 api_key를 쿼리 파라미터로 사용
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image.jpg',
          // MIME 타입 명시
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // 추가 헤더 설정
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      debugPrint('📤 요청 크기: ${imageBytes.length} bytes');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 응답 상태: ${response.statusCode}');
      debugPrint('📥 응답 헤더: ${response.headers}');
      debugPrint('📥 응답 본문: ${response.body}');

      return response;
    } catch (e) {
      debugPrint('❌ API 호출 오류: $e');
      rethrow;
    }
  }

  /// API 응답 파싱
  ObjectDetectionResult _parseDetectionResponse(
    Map<String, dynamic> jsonResponse,
    File originalImage,
  ) {
    try {
      debugPrint('🔍 응답 파싱 시작: $jsonResponse');

      final predictions = jsonResponse['predictions'] as List? ?? [];
      final detections = <DetectedObject>[];

      debugPrint('📊 감지된 예측 수: ${predictions.length}');

      for (final prediction in predictions) {
        try {
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
            debugPrint(
              '✅ 감지된 객체: ${detection.className} (${detection.confidencePercent})',
            );
          } else {
            debugPrint(
              '⚠️ 낮은 신뢰도로 제외: ${detection.className} (${detection.confidencePercent})',
            );
          }
        } catch (e) {
          debugPrint('❌ 예측 파싱 오류: $e, 데이터: $prediction');
        }
      }

      final avgConfidence = detections.isNotEmpty
          ? detections.map((d) => d.confidence).reduce((a, b) => a + b) /
                detections.length
          : 0.0;

      final result = ObjectDetectionResult(
        imagePath: originalImage.path,
        detections: detections,
        confidence: avgConfidence,
        processingTime: jsonResponse['inference_time'] as int? ?? 0,
      );

      debugPrint(
        '🎯 최종 결과: ${detections.length}개 객체, 평균 신뢰도: ${(avgConfidence * 100).toInt()}%',
      );

      return result;
    } catch (e) {
      debugPrint('❌ 응답 파싱 전체 오류: $e');
      return ObjectDetectionResult(
        imagePath: originalImage.path,
        detections: [],
        confidence: 0.0,
        processingTime: 0,
      );
    }
  }

  /// 개발 모드용 목업 데이터
  ObjectDetectionResult _getMockDetectionResult(File imageFile) {
    // 파일명 기반으로 시드 생성하여 일관된 결과 제공
    final fileName = imageFile.path.split('/').last;
    final seed = fileName.hashCode % 1000;
    final random = DateTime.now().millisecond + seed;

    // 이미지 타입에 따라 다른 감지 결과 생성
    List<String> possibleClasses;
    int maxDetections;

    if (fileName.contains('road') || fileName.contains('도로')) {
      possibleClasses = ['road_damage', 'pothole', 'traffic_sign_damage'];
      maxDetections = 2;
    } else if (fileName.contains('environment') || fileName.contains('환경')) {
      possibleClasses = ['illegal_dumping', 'graffiti'];
      maxDetections = 2;
    } else if (fileName.contains('facility') || fileName.contains('시설')) {
      possibleClasses = ['broken_sign', 'broken_fence', 'street_light_out'];
      maxDetections = 3;
    } else {
      // 일반적인 랜덤 감지
      possibleClasses = supportedClasses;
      maxDetections = 3;
    }

    final numDetections = (random % maxDetections) + 1;
    final detections = <DetectedObject>[];

    // 중복 없이 클래스 선택
    final selectedClasses = <String>[];
    for (int i = 0; i < numDetections; i++) {
      String className;
      do {
        className = possibleClasses[(random + i) % possibleClasses.length];
      } while (selectedClasses.contains(className) &&
          selectedClasses.length < possibleClasses.length);

      selectedClasses.add(className);

      detections.add(
        DetectedObject(
          className: className,
          confidence: 0.65 + ((random + i * 7) % 30) / 100, // 0.65 ~ 0.95
          boundingBox: BoundingBox(
            x: 100.0 + (i * 80) + ((random + i) % 50),
            y: 100.0 + (i * 60) + ((random + i * 3) % 40),
            width: 100.0 + ((random + i * 5) % 80), // 100 ~ 180
            height: 80.0 + ((random + i * 7) % 60), // 80 ~ 140
          ),
        ),
      );
    }

    // 높은 신뢰도의 감지가 있을 때 더 높은 전체 신뢰도
    final avgConfidence = detections.isNotEmpty
        ? detections.map((d) => d.confidence).reduce((a, b) => a + b) /
              detections.length
        : 0.0;

    return ObjectDetectionResult(
      imagePath: imageFile.path,
      detections: detections,
      confidence: avgConfidence,
      processingTime: 200 + (random % 150), // 200-350ms 시뮬레이션
    );
  }

  /// API 연결 테스트 (디버깅 정보 포함)
  static Future<bool> testApiConnection() async {
    try {
      final valid = await hasValidApiKey;
      if (!valid) {
        debugPrint('❌ API 키가 설정되지 않음');
        return false;
      }

      debugPrint('🔍 API 연결 테스트 시작...');

      final config = RoboflowConfig.instance;
      final apiKey = await config.getApiKey();
      final workspace = await config.getWorkspace();
      final project = await config.getProject();
      final version = await config.getVersion();

      debugPrint('🔑 API 키: ${apiKey?.substring(0, 8) ?? 'null'}...');
      debugPrint('🏢 Workspace: $workspace');
      debugPrint('📁 Project: $project');
      debugPrint('🔢 Version: $version');

      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('❌ API 키가 null 또는 빈 문자열');
        return false;
      }

      // 테스트용 더미 이미지 생성 (1x1 픽셀)
      final testImage = img.Image(width: 1, height: 1);
      img.fill(testImage, color: img.ColorRgb8(255, 255, 255));
      final testBytes = Uint8List.fromList(img.encodeJpg(testImage));

      final modelEndpoint = '$workspace/$project/$version';
      final uri = Uri.parse('$_apiUrl/$modelEndpoint?api_key=$apiKey');

      debugPrint('🌐 테스트 URL: $uri');

      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          testBytes,
          filename: 'test.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('🔍 테스트 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);
          debugPrint('✅ API 연결 성공: $jsonResponse');
          return true;
        } catch (e) {
          debugPrint('❌ 응답 파싱 실패: $e');
          return false;
        }
      } else {
        debugPrint('❌ API 연결 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ API 테스트 오류: $e');
      return false;
    }
  }

  // API 키 형식 검증 (실시간)
  Future<bool> validateApiKeyFormat(String apiKey) async {
    try {
      // 기본 형식 검증
      if (apiKey.isEmpty || apiKey.length < 15) return false;

      // Roboflow API 키는 일반적으로 영숫자와 특수문자로 구성
      final RegExp apiKeyPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
      if (!apiKeyPattern.hasMatch(apiKey)) return false;

      // 추가 검증: 일반적인 잘못된 값들 제외
      const invalidKeys = [
        'your-roboflow-api-key',
        'your-private-api-key',
        'api-key-here',
        'test-key',
      ];

      if (invalidKeys.contains(apiKey.toLowerCase())) return false;

      return true;
    } catch (e) {
      debugPrint('❌ API 키 형식 검증 오류: $e');
      return false;
    }
  }

  // 연결 테스트 메서드
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Roboflow API 연결 테스트 시작...');

      // API 키 유효성 검사
      final hasValidKey = await hasValidApiKey;
      if (!hasValidKey) {
        debugPrint('❌ 유효하지 않은 API 키');
        return false;
      }

      // 간단한 API 호출로 연결 테스트
      final apiKey = await _apiKey;
      final modelEndpoint = await _modelEndpoint;

      final testUrl = '$_apiUrl/$modelEndpoint';
      final response = await http
          .get(
            Uri.parse('$testUrl?api_key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      final success =
          response.statusCode == 200 ||
          response.statusCode == 400; // 400은 파라미터 부족으로 인한 것으로 연결은 성공

      debugPrint(
        success ? '✅ 연결 테스트 성공' : '❌ 연결 테스트 실패: ${response.statusCode}',
      );
      return success;
    } catch (e) {
      debugPrint('❌ 연결 테스트 오류: $e');
      return false;
    }
  }

  /// 영어 클래스명을 한국어로 변환
  static String getKoreanClassName(String englishClassName) {
    const Map<String, String> classNameMap = {
      'trash': '쓰레기',
      'garbage': '쓰레기',
      'waste': '폐기물',
      'damage': '손상',
      'crack': '균열',
      'pothole': '움푹 패인 곳',
      'debris': '잔해',
      'litter': '쓰레기',
      'recycling': '재활용품',
      'hazard': '위험물',
      'construction': '공사',
      'maintenance': '유지보수',
      'safety': '안전',
      'other': '기타',
    };

    return classNameMap[englishClassName.toLowerCase()] ?? englishClassName;
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
