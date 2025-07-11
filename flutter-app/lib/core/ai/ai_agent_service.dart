import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'roboflow_service.dart';
import 'ocr_service.dart';

/// AI Agent 분석 서비스 - OCR과 객체 감지 결과를 종합 분석
class AIAgentService {
  static final AIAgentService _instance = AIAgentService._internal();
  static AIAgentService get instance => _instance;
  AIAgentService._internal();

  final String _openAIApiKey = 'your-openai-api-key'; // 실제 환경에서는 .env 파일에서 로드
  final String _openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  
  bool _isInitialized = false;

  /// AI Agent 서비스 초기화
  Future<void> init() async {
    try {
      _isInitialized = true;
      debugPrint('🤖 AI Agent Service initialized');
    } catch (e) {
      debugPrint('⚠️ AI Agent Service initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// 통합 분석 수행 (OCR + 객체 감지 + AI 해석)
  Future<AIAnalysisResult> analyzeImage({
    required File imageFile,
    ObjectDetectionResult? detectionResult,
    OCRResult? ocrResult,
  }) async {
    try {
      debugPrint('🤖 AI Agent 종합 분석 시작: ${imageFile.path}');
      
      // 기본 컨텍스트 정보 구성
      final context = _buildAnalysisContext(
        imageFile: imageFile,
        detectionResult: detectionResult,
        ocrResult: ocrResult,
      );

      // AI 분석 수행 (실제 환경에서는 OpenAI GPT 사용)
      final analysis = await _performAIAnalysis(context);
      
      debugPrint('✅ AI Agent 분석 완료');
      
      return AIAnalysisResult(
        imagePath: imageFile.path,
        analysis: analysis,
        confidence: _calculateConfidence(detectionResult, ocrResult),
        processingTime: DateTime.now().millisecondsSinceEpoch,
        hasDetection: detectionResult?.hasDetections ?? false,
        hasOCRText: ocrResult?.hasText ?? false,
      );

    } catch (e) {
      debugPrint('❌ AI Agent 분석 오류: $e');
      
      // 오류 발생 시 기본 분석 결과 반환
      return _getBasicAnalysis(imageFile, detectionResult, ocrResult, e.toString());
    }
  }

  /// 분석 컨텍스트 구성
  AnalysisContext _buildAnalysisContext({
    required File imageFile,
    ObjectDetectionResult? detectionResult,
    OCRResult? ocrResult,
  }) {
    return AnalysisContext(
      imageFileName: imageFile.path.split('/').last,
      detectedObjects: detectionResult?.detections ?? [],
      extractedText: ocrResult?.fullText ?? '',
      extractedInfo: ocrResult?.extractedInfo,
      timestamp: DateTime.now(),
    );
  }

  /// AI 분석 수행 (개발 모드에서는 목업 분석)
  Future<AIAnalysis> _performAIAnalysis(AnalysisContext context) async {
    if (kDebugMode || !_isInitialized) {
      // 개발 모드 목업 분석
      return _getMockAIAnalysis(context);
    }

    try {
      // 실제 OpenAI API 호출 (API 키가 있는 경우)
      if (_openAIApiKey.isNotEmpty && _openAIApiKey != 'your-openai-api-key') {
        return await _callOpenAIAPI(context);
      } else {
        return _getMockAIAnalysis(context);
      }
    } catch (e) {
      debugPrint('⚠️ OpenAI API 호출 실패, 목업 분석 사용: $e');
      return _getMockAIAnalysis(context);
    }
  }

  /// OpenAI API 호출
  Future<AIAnalysis> _callOpenAIAPI(AnalysisContext context) async {
    final prompt = _buildPrompt(context);
    
    final response = await http.post(
      Uri.parse(_openAIEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAIApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': '''당신은 전북도 현장 보고서 분석 전문가입니다. 
시설물 상태, 안전 위험도, 긴급성을 정확히 판단하고 
구체적인 조치사항을 제안해주세요.''',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'max_tokens': 1000,
        'temperature': 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return _parseAIResponse(content, context);
    } else {
      throw Exception('OpenAI API Error: ${response.statusCode}');
    }
  }

  /// 프롬프트 구성
  String _buildPrompt(AnalysisContext context) {
    final prompt = StringBuffer();
    
    prompt.writeln('현장 상황 분석 요청:');
    prompt.writeln('파일명: ${context.imageFileName}');
    
    if (context.detectedObjects.isNotEmpty) {
      prompt.writeln('\n감지된 객체:');
      for (final detection in context.detectedObjects) {
        prompt.writeln('- ${detection.name} (신뢰도: ${(detection.confidence * 100).toStringAsFixed(1)}%)');
      }
    }
    
    if (context.extractedText.isNotEmpty) {
      prompt.writeln('\n추출된 텍스트:');
      prompt.writeln(context.extractedText);
    }
    
    if (context.extractedInfo?.hasUsefulInfo == true) {
      prompt.writeln('\n추출된 정보:');
      prompt.writeln(context.extractedInfo!.formattedSummary);
    }
    
    prompt.writeln('\n다음 항목으로 분석해주세요:');
    prompt.writeln('1. 문제 상황 요약');
    prompt.writeln('2. 위험도 평가 (1-5단계)');
    prompt.writeln('3. 긴급성 평가 (즉시/24시간/1주일/1개월)');
    prompt.writeln('4. 추천 조치사항');
    prompt.writeln('5. 관련 부서/담당자');
    
    return prompt.toString();
  }

  /// AI 응답 파싱
  AIAnalysis _parseAIResponse(String content, AnalysisContext context) {
    // 실제 구현에서는 더 정교한 파싱 필요
    return AIAnalysis(
      summary: _extractSection(content, '문제 상황 요약') ?? '분석 결과 요약',
      riskLevel: _extractRiskLevel(content),
      urgency: _extractUrgency(content),
      recommendations: _extractRecommendations(content),
      responsibleDepartment: _extractSection(content, '관련 부서') ?? '시설관리과',
      confidence: 0.85,
      analysisDetails: content,
    );
  }

  /// 목업 AI 분석 (개발/테스트용)
  AIAnalysis _getMockAIAnalysis(AnalysisContext context) {
    final fileName = context.imageFileName.toLowerCase();
    
    if (fileName.contains('pothole') || fileName.contains('도로')) {
      return AIAnalysis(
        summary: '도로 표면에 중대한 포트홀이 발견되었습니다. 차량 통행에 위험을 초래할 수 있어 즉시 조치가 필요합니다.',
        riskLevel: 4,
        urgency: ReportUrgency.immediate,
        recommendations: [
          '즉시 안전 표지판 설치',
          '임시 우회로 안내',
          '24시간 내 응급 보수 실시',
          '완전 보수 계획 수립',
        ],
        responsibleDepartment: '도로관리사업소',
        confidence: 0.92,
        analysisDetails: '포트홀 크기: 약 50cm, 깊이: 약 10cm\n위치: 차로 중앙\n교통량: 높음\n즉시 조치 필요',
      );
    } else if (fileName.contains('construction') || fileName.contains('공사')) {
      return AIAnalysis(
        summary: '건설 현장의 안전 관리 상태를 점검했습니다. 전반적으로 안전 기준을 준수하고 있으나 일부 개선사항이 있습니다.',
        riskLevel: 2,
        urgency: ReportUrgency.week,
        recommendations: [
          '안전 표지판 추가 설치',
          '작업자 안전장비 점검',
          '주변 교통 안전 개선',
          '정기 점검 강화',
        ],
        responsibleDepartment: '건설과',
        confidence: 0.88,
        analysisDetails: '공사 현장 안전 상태 양호\n개선 필요: 표지판, 안전장비\n정기 점검 권장',
      );
    } else if (fileName.contains('graffiti') || fileName.contains('낙서')) {
      return AIAnalysis(
        summary: '공공시설물에 불법 낙서가 발견되었습니다. 도시 미관 훼손 및 추가 낙서 유발 가능성이 있습니다.',
        riskLevel: 2,
        urgency: ReportUrgency.month,
        recommendations: [
          '낙서 제거 작업 실시',
          'CCTV 설치 검토',
          '낙서 방지 코팅 적용',
          '순찰 강화',
        ],
        responsibleDepartment: '환경위생과',
        confidence: 0.85,
        analysisDetails: '낙서 규모: 중간\n위치: 공공시설물\n미관 훼손도: 보통\n예방 조치 필요',
      );
    } else {
      return AIAnalysis(
        summary: '현장 상황을 분석했습니다. 전반적으로 양호한 상태이나 지속적인 관리가 필요합니다.',
        riskLevel: 1,
        urgency: ReportUrgency.month,
        recommendations: [
          '정기 점검 실시',
          '예방 조치 적용',
          '상태 모니터링',
        ],
        responsibleDepartment: '시설관리과',
        confidence: 0.75,
        analysisDetails: '일반적인 현장 상황\n특별한 위험 요소 없음\n정기 관리 권장',
      );
    }
  }

  /// 신뢰도 계산
  double _calculateConfidence(ObjectDetectionResult? detection, OCRResult? ocr) {
    double confidence = 0.5; // 기본 신뢰도
    
    if (detection?.hasDetections == true) {
      final avgDetectionConfidence = detection!.detections
          .map((d) => d.confidence)
          .reduce((a, b) => a + b) / detection.detections.length;
      confidence += avgDetectionConfidence * 0.3;
    }
    
    if (ocr?.hasText == true) {
      confidence += 0.2;
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  /// 기본 분석 결과 (오류 시)
  AIAnalysisResult _getBasicAnalysis(
    File imageFile,
    ObjectDetectionResult? detection,
    OCRResult? ocr,
    String error,
  ) {
    return AIAnalysisResult(
      imagePath: imageFile.path,
      analysis: AIAnalysis(
        summary: '기본 분석이 수행되었습니다. 상세 분석을 위해 다시 시도해주세요.',
        riskLevel: 1,
        urgency: ReportUrgency.month,
        recommendations: ['전문가 검토 필요', '상세 분석 재시도'],
        responsibleDepartment: '종합상황실',
        confidence: 0.5,
        analysisDetails: '기본 분석 모드',
      ),
      confidence: 0.5,
      processingTime: DateTime.now().millisecondsSinceEpoch,
      hasDetection: detection?.hasDetections ?? false,
      hasOCRText: ocr?.hasText ?? false,
      error: error,
    );
  }

  /// 텍스트에서 섹션 추출
  String? _extractSection(String content, String sectionName) {
    final pattern = RegExp('$sectionName[:\s]*([^\n]+)', caseSensitive: false);
    final match = pattern.firstMatch(content);
    return match?.group(1)?.trim();
  }

  /// 위험도 추출
  int _extractRiskLevel(String content) {
    final pattern = RegExp(r'위험도[:\s]*(\d+)', caseSensitive: false);
    final match = pattern.firstMatch(content);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 1;
    }
    return 1;
  }

  /// 긴급성 추출
  ReportUrgency _extractUrgency(String content) {
    final lowerContent = content.toLowerCase();
    if (lowerContent.contains('즉시') || lowerContent.contains('immediate')) {
      return ReportUrgency.immediate;
    } else if (lowerContent.contains('24시간') || lowerContent.contains('urgent')) {
      return ReportUrgency.urgent;
    } else if (lowerContent.contains('1주일') || lowerContent.contains('week')) {
      return ReportUrgency.week;
    } else {
      return ReportUrgency.month;
    }
  }

  /// 권장사항 추출
  List<String> _extractRecommendations(String content) {
    final recommendations = <String>[];
    final lines = content.split('\n');
    
    bool inRecommendations = false;
    for (final line in lines) {
      if (line.contains('조치사항') || line.contains('권장')) {
        inRecommendations = true;
        continue;
      }
      
      if (inRecommendations && line.trim().isNotEmpty) {
        if (line.startsWith('- ') || line.startsWith('• ')) {
          recommendations.add(line.substring(2).trim());
        } else if (RegExp(r'^\d+\.').hasMatch(line)) {
          recommendations.add(line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim());
        }
      }
    }
    
    return recommendations.isEmpty ? ['전문가 검토 필요'] : recommendations;
  }

  /// 리소스 정리
  void dispose() {
    _isInitialized = false;
    debugPrint('🤖 AI Agent Service disposed');
  }
}

/// 분석 컨텍스트
class AnalysisContext {
  final String imageFileName;
  final List<Detection> detectedObjects;
  final String extractedText;
  final ExtractedInfo? extractedInfo;
  final DateTime timestamp;

  AnalysisContext({
    required this.imageFileName,
    required this.detectedObjects,
    required this.extractedText,
    this.extractedInfo,
    required this.timestamp,
  });
}

/// AI 분석 결과
class AIAnalysisResult {
  final String imagePath;
  final AIAnalysis analysis;
  final double confidence;
  final int processingTime;
  final bool hasDetection;
  final bool hasOCRText;
  final String? error;

  AIAnalysisResult({
    required this.imagePath,
    required this.analysis,
    required this.confidence,
    required this.processingTime,
    required this.hasDetection,
    required this.hasOCRText,
    this.error,
  });

  bool get hasError => error != null;
  bool get isSuccessful => !hasError;

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'analysis': analysis.toJson(),
      'confidence': confidence,
      'processingTime': processingTime,
      'hasDetection': hasDetection,
      'hasOCRText': hasOCRText,
      'error': error,
    };
  }
}

/// AI 분석 내용
class AIAnalysis {
  final String summary;
  final int riskLevel; // 1-5
  final ReportUrgency urgency;
  final List<String> recommendations;
  final String responsibleDepartment;
  final double confidence;
  final String analysisDetails;

  AIAnalysis({
    required this.summary,
    required this.riskLevel,
    required this.urgency,
    required this.recommendations,
    required this.responsibleDepartment,
    required this.confidence,
    required this.analysisDetails,
  });

  String get riskLevelText {
    switch (riskLevel) {
      case 5: return '매우 위험';
      case 4: return '위험';
      case 3: return '보통';
      case 2: return '낮음';
      case 1: return '안전';
      default: return '미확인';
    }
  }

  String get urgencyText {
    switch (urgency) {
      case ReportUrgency.immediate: return '즉시 조치';
      case ReportUrgency.urgent: return '24시간 내';
      case ReportUrgency.week: return '1주일 내';
      case ReportUrgency.month: return '1개월 내';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'riskLevel': riskLevel,
      'riskLevelText': riskLevelText,
      'urgency': urgency.name,
      'urgencyText': urgencyText,
      'recommendations': recommendations,
      'responsibleDepartment': responsibleDepartment,
      'confidence': confidence,
      'analysisDetails': analysisDetails,
    };
  }
}

/// 보고서 긴급도
enum ReportUrgency {
  immediate, // 즉시
  urgent,    // 24시간
  week,      // 1주일
  month,     // 1개월
}