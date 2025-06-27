import 'dart:io';
import '../entities/report.dart';

class ReportCreateRequest {
  final String title;
  final String content;
  final ReportCategory category;
  final double? latitude;
  final double? longitude;
  final List<File> images;
  final String? signature;

  const ReportCreateRequest({
    required this.title,
    required this.content,
    required this.category,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.signature,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category.name,
      'latitude': latitude,
      'longitude': longitude,
      'signature': signature,
      // 이미지는 multipart로 별도 처리
    };
  }
}
