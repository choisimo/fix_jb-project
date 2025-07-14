import 'dart:io';

class WebhookPayload {
  final String eventType;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final String? userId;
  final String? sessionId;
  
  WebhookPayload({
    required this.eventType,
    required this.timestamp,
    required this.data,
    this.userId,
    this.sessionId,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'userId': userId,
      'sessionId': sessionId,
      'source': 'flutter_app',
      'version': '1.0',
    };
  }
  
  factory WebhookPayload.fromJson(Map<String, dynamic> json) {
    return WebhookPayload(
      eventType: json['eventType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>,
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
    );
  }
}

class ImageAnalysisWebhookPayload extends WebhookPayload {
  ImageAnalysisWebhookPayload({
    required String imageId,
    required String imagePath,
    required int fileSize,
    required String mimeType,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) : super(
    eventType: 'image_analysis_started',
    timestamp: DateTime.now(),
    data: {
      'imageId': imageId,
      'imagePath': imagePath,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'metadata': metadata ?? {},
    },
    userId: userId,
    sessionId: sessionId,
  );
  
  factory ImageAnalysisWebhookPayload.completed({
    required String imageId,
    required Map<String, dynamic> analysisResult,
    String? userId,
    String? sessionId,
  }) {
    return ImageAnalysisWebhookPayload._internal(
      eventType: 'image_analysis_completed',
      timestamp: DateTime.now(),
      data: {
        'imageId': imageId,
        'analysisResult': analysisResult,
        'processingTime': DateTime.now().millisecondsSinceEpoch,
      },
      userId: userId,
      sessionId: sessionId,
    );
  }
  
  factory ImageAnalysisWebhookPayload.failed({
    required String imageId,
    required String error,
    String? userId,
    String? sessionId,
  }) {
    return ImageAnalysisWebhookPayload._internal(
      eventType: 'image_analysis_failed',
      timestamp: DateTime.now(),
      data: {
        'imageId': imageId,
        'error': error,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      userId: userId,
      sessionId: sessionId,
    );
  }
  
  ImageAnalysisWebhookPayload._internal({
    required String eventType,
    required DateTime timestamp,
    required Map<String, dynamic> data,
    String? userId,
    String? sessionId,
  }) : super(
    eventType: eventType,
    timestamp: timestamp,
    data: data,
    userId: userId,
    sessionId: sessionId,
  );
}

class ReportWebhookPayload extends WebhookPayload {
  ReportWebhookPayload.created({
    required String reportId,
    required Map<String, dynamic> reportData,
    String? userId,
    String? sessionId,
  }) : super(
    eventType: 'report_created',
    timestamp: DateTime.now(),
    data: {
      'reportId': reportId,
      'reportData': reportData,
    },
    userId: userId,
    sessionId: sessionId,
  );
  
  ReportWebhookPayload.updated({
    required String reportId,
    required Map<String, dynamic> updatedFields,
    String? userId,
    String? sessionId,
  }) : super(
    eventType: 'report_updated',
    timestamp: DateTime.now(),
    data: {
      'reportId': reportId,
      'updatedFields': updatedFields,
    },
    userId: userId,
    sessionId: sessionId,
  );
}