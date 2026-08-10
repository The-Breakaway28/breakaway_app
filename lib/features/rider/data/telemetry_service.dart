import 'dart:convert';
import 'package:http/http.dart' as http;

class TelemetryService {
  static const String _baseUrl = 'https://breakaway-api.duckdns.org';

  Future<List<dynamic>> getRiderTelemetry(String riderId, String token) async {
    final uri = Uri.parse('$_baseUrl/riders/$riderId/telemetry');
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
      throw Exception('Ошибка загрузки телеметрии: ${response.statusCode}');
    }
  }
}
