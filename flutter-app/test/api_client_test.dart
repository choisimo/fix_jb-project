import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_report_app/app/api/api_client.dart';

void main() {
  final api = ApiClient('http://localhost:8080');

  test('회원가입/로그인/프로필/리포트 API 연동', () async {
    final regRes = await api.register({
      'email': 'flutteruser@example.com',
      'password': 'flutterpass',
      'name': '플러터유저',
      'phone': '010-9999-8888',
      'department': '플러터팀',
    });
    expect(regRes.statusCode, anyOf(200, 201, 400));
    final loginRes = await api.login('flutteruser@example.com', 'flutterpass');
    expect(loginRes.statusCode, 200);
    final token = loginRes.body.contains('data') ? loginRes.body.split('"data":"')[1].split('"')[0] : '';
    expect(token.isNotEmpty, true);
    final profileRes = await api.getProfile('dummy-uuid', token);
    expect(profileRes.statusCode, anyOf(200, 404));
    final reportRes = await api.createReport({'title': '플러터 리포트', 'content': '내용'}, token);
    expect(reportRes.statusCode, anyOf(200, 201, 400));
    final reportsRes = await api.getReports(token);
    expect(reportsRes.statusCode, 200);
  });
}
