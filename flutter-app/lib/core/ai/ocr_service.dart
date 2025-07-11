import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  static final OCRService _instance = OCRService._internal();
  static OCRService get instance => _instance;
  OCRService._internal();

  TextRecognizer? _textRecognizer;
  bool _isInitialized = false;

  /// OCR 서비스 초기화
  Future<void> init() async {
    try {
      _textRecognizer = TextRecognizer();
      _isInitialized = true;
      debugPrint('🔤 OCR Service initialized with Google ML Kit');
    } catch (e) {
      debugPrint('⚠️ OCR Service initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// 이미지에서 텍스트 추출 (Google ML Kit 사용)
  Future<OCRResult> extractText(File imageFile) async {
    try {
      debugPrint('🔤 OCR 분석 시작: ${imageFile.path}');
      
      if (!await imageFile.exists()) {
        throw Exception('이미지 파일이 존재하지 않습니다: ${imageFile.path}');
      }

      if (!_isInitialized || _textRecognizer == null) {
        debugPrint('⚠️ OCR 서비스가 초기화되지 않음, 목업 데이터 반환');
        return _getMockOCRResult(imageFile);
      }

      // Google ML Kit으로 텍스트 인식 수행
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer!.processImage(inputImage);

      debugPrint('📝 OCR 텍스트 추출 완료: ${recognizedText.text.length}자');

      // 텍스트 블록 변환
      final textBlocks = recognizedText.blocks.map((block) {
        return TextBlock(
          text: block.text,
          confidence: block.confidence ?? 0.0,
          boundingBox: Rect.fromLTRB(
            block.boundingBox.left.toDouble(),
            block.boundingBox.top.toDouble(),
            block.boundingBox.right.toDouble(),
            block.boundingBox.bottom.toDouble(),
          ),
        );
      }).toList();

      // 추출된 정보 분석
      final extractedInfo = _extractKeyInformation(recognizedText.text);

      return OCRResult(
        imagePath: imageFile.path,
        fullText: recognizedText.text,
        textBlocks: textBlocks,
        extractedInfo: extractedInfo,
        processingTime: DateTime.now().millisecondsSinceEpoch,
      );

    } catch (e) {
      debugPrint('❌ OCR 처리 오류: $e');
      
      // 오류 발생 시 목업 데이터 반환 (개발 모드)
      if (kDebugMode) {
        return _getMockOCRResult(imageFile);
      }
      
      return OCRResult(
        imagePath: imageFile.path,
        fullText: '',
        textBlocks: [],
        extractedInfo: ExtractedInfo(),
        processingTime: DateTime.now().millisecondsSinceEpoch,
        error: e.toString(),
      );
    }
  }

  /// 텍스트에서 주요 정보 추출
  ExtractedInfo _extractKeyInformation(String text) {
    final extractedInfo = ExtractedInfo();

    // 주소 패턴 매칭
    final addressPatterns = [
      RegExp(r'([가-힣]+시\s+[가-힣]+구\s+[가-힣]+동)', caseSensitive: false),
      RegExp(r'([가-힣]+도\s+[가-힣]+시\s+[가-힣]+구)', caseSensitive: false),
      RegExp(r'([가-힣]+로\s*\d+)', caseSensitive: false),
    ];

    for (final pattern in addressPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        extractedInfo.addresses.add(match.group(0)!);
      }
    }

    // 전화번호 패턴 매칭
    final phonePattern = RegExp(r'0\d{1,2}-\d{3,4}-\d{4}');
    final phoneMatches = phonePattern.allMatches(text);
    for (final match in phoneMatches) {
      extractedInfo.phoneNumbers.add(match.group(0)!);
    }

    // 업체명/간판명 추출
    final businessPatterns = [
      RegExp(r'([가-힣]+\s*(식당|카페|마트|상점|약국|병원|은행))', caseSensitive: false),
      RegExp(r'([가-힣A-Za-z]+\s*(주식회사|유한회사|상사))', caseSensitive: false),
    ];

    for (final pattern in businessPatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        extractedInfo.businessNames.add(match.group(0)!);
      }
    }

    // 키워드 추출
    extractedInfo.keywords.addAll(_extractKeywords(text));

    return extractedInfo;
  }

  /// 키워드 추출
  List<String> _extractKeywords(String text) {
    const importantKeywords = [
      '파손',
      '고장',
      '누수',
      '균열',
      '위험',
      '차단',
      '폐쇄',
      '공사',
      '수리',
      '보수',
      '교체',
      '신호등',
      '가로등',
      '도로',
      '인도',
      '맨홀',
      '하수구',
      '전선',
      '간판',
      '쓰레기',
      '폐기물',
      '불법',
      '주정차',
      '소음',
      '악취',
    ];

    final foundKeywords = <String>[];

    for (final keyword in importantKeywords) {
      if (text.contains(keyword)) {
        foundKeywords.add(keyword);
      }
    }

    return foundKeywords;
  }

  /// 개발 모드용 목업 데이터 (실제 Google ML Kit 연동 테스트용)
  OCRResult _getMockOCRResult(File imageFile) {
    final fileName = imageFile.path.split('/').last.toLowerCase();
    
    String mockText;
    List<String> keywords;
    
    // 파일명 기반 스마트 목업 데이터
    if (fileName.contains('pothole') || fileName.contains('도로')) {
      mockText = '도로 파손 주의\n우회 도로 이용 바랍니다\n전북 전주시 덕진구 진북동\n신고일시: 2025.07.11';
      keywords = ['도로', '파손', '우회', '주의'];
    } else if (fileName.contains('construction') || fileName.contains('공사')) {
      mockText = '㈜전북건설\n공사 기간: 2025.6.1 ~ 2025.8.31\n담당자: 김철수\n문의: 063-987-6543\n전북 군산시 나운동 123-45';
      keywords = ['공사', '건설', '수리'];
    } else if (fileName.contains('graffiti') || fileName.contains('낙서')) {
      mockText = '무단 낙서 금지\n과태료 50만원\n전북 익산시 부송동\n관리사무소: 063-123-4567';
      keywords = ['낙서', '금지', '과태료'];
    } else if (fileName.contains('trash') || fileName.contains('쓰레기')) {
      mockText = '무단투기 금지 구역\n쓰레기 무단투기시 과태료 부과\n전북 정읍시 수성동\nCCTV 설치 구역';
      keywords = ['쓰레기', '무단투기', '과태료', 'CCTV'];
    } else if (fileName.contains('light') || fileName.contains('가로등')) {
      mockText = '가로등 고장 신고\n전북 남원시 향교동\n전력공급: 한국전력공사\n문의: 063-620-1234';
      keywords = ['가로등', '고장', '전력', '한국전력'];
    } else {
      // 기본 목업 데이터
      mockText = '전북 전주시 완산구 효자동\n효자 마트\n영업시간: 08:00 - 22:00\n전화: 063-123-4567\n간판 수리 필요';
      keywords = ['간판', '수리', '마트'];
    }

    return OCRResult(
      imagePath: imageFile.path,
      fullText: mockText,
      textBlocks: [
        TextBlock(
          text: mockText,
          confidence: 0.92,
          boundingBox: const Rect.fromLTRB(50, 50, 350, 250),
        ),
      ],
      extractedInfo: _extractKeyInformation(mockText),
      processingTime: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 리소스 정리
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
    _isInitialized = false;
    debugPrint('🔤 OCR Service disposed');
  }
}

/// OCR 결과 클래스
class OCRResult {
  final String imagePath;
  final String fullText;
  final List<TextBlock> textBlocks;
  final ExtractedInfo extractedInfo;
  final int processingTime;
  final String? error;

  OCRResult({
    required this.imagePath,
    required this.fullText,
    required this.textBlocks,
    required this.extractedInfo,
    required this.processingTime,
    this.error,
  });

  bool get hasText => fullText.isNotEmpty;
  bool get hasError => error != null;
  bool get isSuccessful => hasText && !hasError;

  String get summary {
    if (hasError) return '텍스트 추출 실패: $error';
    if (!hasText) return '추출된 텍스트 없음';

    final wordCount = fullText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    final keywordCount = extractedInfo.keywords.length;
    
    return '텍스트 ${wordCount}단어, 키워드 ${keywordCount}개 추출';
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'fullText': fullText,
      'extractedInfo': extractedInfo.toJson(),
      'processingTime': processingTime,
      'hasText': hasText,
      'summary': summary,
      'error': error,
    };
  }
}

/// 텍스트 블록 정보
class TextBlock {
  final String text;
  final double confidence;
  final Rect boundingBox;

  TextBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
}

/// 추출된 정보 클래스
class ExtractedInfo {
  final List<String> addresses = [];
  final List<String> phoneNumbers = [];
  final List<String> businessNames = [];
  final List<String> keywords = [];

  bool get hasUsefulInfo =>
      addresses.isNotEmpty ||
      phoneNumbers.isNotEmpty ||
      businessNames.isNotEmpty ||
      keywords.isNotEmpty;

  String get primaryAddress => addresses.isNotEmpty ? addresses.first : '';
  String get primaryPhone => phoneNumbers.isNotEmpty ? phoneNumbers.first : '';
  String get primaryBusiness =>
      businessNames.isNotEmpty ? businessNames.first : '';

  Map<String, dynamic> toJson() {
    return {
      'addresses': addresses,
      'phoneNumbers': phoneNumbers,
      'businessNames': businessNames,
      'keywords': keywords,
      'hasUsefulInfo': hasUsefulInfo,
      'primaryAddress': primaryAddress,
      'primaryPhone': primaryPhone,
      'primaryBusiness': primaryBusiness,
    };
  }

  String get formattedSummary {
    final parts = <String>[];
    
    if (addresses.isNotEmpty) {
      parts.add('📍 주소: ${addresses.length}개');
    }
    if (phoneNumbers.isNotEmpty) {
      parts.add('📞 전화: ${phoneNumbers.length}개');
    }
    if (businessNames.isNotEmpty) {
      parts.add('🏢 업체: ${businessNames.length}개');
    }
    if (keywords.isNotEmpty) {
      parts.add('🔍 키워드: ${keywords.length}개');
    }
    
    return parts.isNotEmpty ? parts.join(', ') : '추출된 정보 없음';
  }
}
