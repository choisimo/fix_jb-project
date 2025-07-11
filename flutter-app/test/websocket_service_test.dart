import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_report_app/app/api/websocket_service.dart';

void main() {
  test('WebSocket 알림 송수신', () async {
    final ws = WebSocketService('ws://localhost:8080/ws');
    ws.send('hello');
    await expectLater(ws.stream, emits('hello'));
    ws.dispose();
  });
}
