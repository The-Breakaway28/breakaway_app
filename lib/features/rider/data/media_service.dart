import 'dart:convert';
import 'package:http/http.dart' as http;

class MediaService {
  static const String _baseUrl = 'https://breakaway-api.duckdns.org';

  Future<List<dynamic>> getMediaClips(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/media'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка загрузки видео: ${response.statusCode}');
    }
  }
}
