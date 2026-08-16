import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/network/api_client.dart';

final stageServiceProvider = Provider<StageService>((ref) {
  final authService = ref.read(authServiceProvider);
  return StageService(ApiClient(authService));
});

class StageService {
  final ApiClient _apiClient;
  StageService(this._apiClient);

  static const String _baseUrl = 'https://breakaway-api.duckdns.org';

  Future<List<dynamic>> getStages() async {
    final response = await _apiClient.get('$_baseUrl/stages');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Ошибка загрузки этапов: ${response.statusCode}');
    }
  }
}
