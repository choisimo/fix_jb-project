import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OCRService {
  static final OCRService _instance = OCRService._internal();
  static OCRService get instance => _instance;
  OCRService._internal();

  /// OCR 서비스 초기화
  Future<void> init() async {
    // Google ML Kit 초기화는 실제 구현에서 사용
    debugPrint('OCR Service initialized');
  }

  /// 이미지에서 텍스트 추출
  Future<OCRResult> extractText(File imageFile) async {
    try {
      // 개발 모드에서는 목업 데이터 반환
      return _getMockOCRResult(imageFile);
    } catch (e) {
      debugPrint('OCR processing error: $e');
      return OCRResult(
        imagePath: imageFile.path,
        fullText: '',
        textBlocks: [],
        extractedInfo: ExtractedInfo(),
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

  /// 개발 모드용 목업 데이터
  OCRResult _getMockOCRResult(File imageFile) {
    const mockTexts = [
      '전북 전주시 완산구 효자동\n효자 마트\n영업시간: 08:00 - 22:00\n전화: 063-123-4567',
      '도로 파손 주의\n우회 도로 이용 바랍니다\n전북 군산시 나운동',
      '㈜전북건설\n공사 기간: 2025.6.1 ~ 2025.8.31\n문의: 063-987-6543',
    ];

    final random = DateTime.now().millisecond;
    final selectedText = mockTexts[random % mockTexts.length];

    return OCRResult(
      imagePath: imageFile.path,
      fullText: selectedText,
      textBlocks: [
        TextBlock(
          text: selectedText,
          confidence: 0.92,
          boundingBox: const Rect.fromLTRB(50, 50, 350, 250),
        ),
      ],
      extractedInfo: _extractKeyInformation(selectedText),
    );
  }

  /// 리소스 정리
  void dispose() {
    debugPrint('OCR Service disposed');
  }
}

/// OCR 결과 클래스
class OCRResult {
  final String imagePath;
  final String fullText;
  final List<TextBlock> textBlocks;
  final ExtractedInfo extractedInfo;

  OCRResult({
    required this.imagePath,
    required this.fullText,
    required this.textBlocks,
    required this.extractedInfo,
  });

  bool get hasText => fullText.isNotEmpty;

  String get summary {
    if (!hasText) return '추출된 텍스트 없음';

    final wordCount = fullText.split(' ').length;
    return '텍스트 ${wordCount}단어 추출됨';
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
}
