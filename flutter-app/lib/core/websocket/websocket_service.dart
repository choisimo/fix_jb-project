import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jb_report_app/core/constants/api_constants.dart';
import 'package:jb_report_app/core/utils/token_manager.dart';
import 'package:jb_report_app/features/notification/domain/models/alert_model.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Alert>? _alertController;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  String? _userId;
  
  Stream<Alert> get alertStream => _alertController!.stream;
  bool get isConnected => _isConnected;
  
  Future<void> connect(String userId) async {
    _userId = userId;
    await _connectWebSocket();
  }
  
  Future<void> _connectWebSocket() async {
    try {
      final token = await TokenManager.getAccessToken();
      if (token == null || _userId == null) return;
      
      _alertController ??= StreamController<Alert>.broadcast();
      
      final wsUrl = Uri.parse('${ApiConstants.wsUrl}/ws/alerts?userId=$_userId');
      _channel = WebSocketChannel.connect(wsUrl);
      
      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _scheduleReconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          _scheduleReconnect();
        },
      );
      
      _isConnected = true;
      _sendPing();
      
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      _scheduleReconnect();
    }
  }
  
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data);
      final type = message['type'];
      
      switch (type) {
        case 'ALERT':
          final alert = Alert.fromJson(message['data']);
          _alertController?.add(alert);
          break;
        case 'PONG':
          // Handle pong response
          break;
        case 'CONNECTION':
          print('WebSocket connected: ${message['message']}');
          break;
        default:
          print('Unknown message type: $type');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }
  
  void _sendPing() {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'PING',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
      
      // Schedule next ping
      Future.delayed(const Duration(seconds: 30), () {
        if (_isConnected) _sendPing();
      });
    }
  }
  
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && _userId != null) {
        _connectWebSocket();
      }
    });
  }
  
  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  void disconnect() {
    _isConnected = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _alertController?.close();
    _alertController = null;
  }
}
