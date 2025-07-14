import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

/// 알림 모델 (WebSocket용)
@freezed
class Alert with _$Alert {
  const factory Alert({
    required String id,
    required String title,
    required String message,
    required String type,
    required DateTime timestamp,
    @Default(false) bool isRead,
    String? userId,
    String? data,
  }) = _Alert;

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
}