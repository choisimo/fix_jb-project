import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);

  Future<http.Response> login(String email, String password) {
    return http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> register(Map<String, dynamic> data) {
    return http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  Future<http.Response> getProfile(String userId, String token) {
    return http.get(
      Uri.parse('$baseUrl/users/profile?userId=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> createReport(Map<String, dynamic> data, String token) {
    return http.post(
      Uri.parse('$baseUrl/reports'),
      headers: {'Authorization': 'Bearer $token'},
      body: data,
    );
  }

  Future<http.Response> getReports(String token) {
    return http.get(
      Uri.parse('$baseUrl/reports'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
