import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../features/auth/data/auth_service.dart';

class ApiClient {
  final AuthService _authService;

  ApiClient(this._authService);

  Future<http.Response> get(String url) async {
    final token = await _authService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> post(String url, {dynamic body}) async {
    final token = await _authService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return http.post(
      Uri.parse(url),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
}
