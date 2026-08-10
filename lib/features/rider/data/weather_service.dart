import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://breakaway-api.duckdns.org';

  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lng, String token) async {
    final uri = Uri.parse('$_baseUrl/weather/current?lat=$lat&lng=$lng');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка загрузки погоды: ${response.statusCode}');
    }
  }
}
