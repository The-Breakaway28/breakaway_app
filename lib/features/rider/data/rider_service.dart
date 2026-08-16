import 'dart:convert';
import 'package:http/http.dart' as http;

class RiderService {
  static const String _baseUrl = 'https://breakaway-api.duckdns.org';

  Future<Map<String, dynamic>> getMyProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/riders/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Ошибка загрузки профиля: ${response.statusCode}');
    }
  }
}
