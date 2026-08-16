import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/network/api_client.dart';

final chefServiceProvider = Provider<ChefService>((ref) {
  final authService = ref.read(authServiceProvider);
  final apiClient = ApiClient(authService);
  return ChefService(apiClient);
});

class ChefService {
  final ApiClient _apiClient;
  ChefService(this._apiClient);

  static const String _baseUrl = 'https://breakaway-api.duckdns.org';

  Future<List<dynamic>> getRidersStatus() async {
    final response = await _apiClient.get('$_baseUrl/chef/riders-status');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Ошибка загрузки райдеров: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> generateMealPlan() async {
    final response = await _apiClient.post(
      '$_baseUrl/chef/meal-plan',
      body: {'stageId': ''},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Ошибка генерации меню: ${response.statusCode}');
    }
  }
}
