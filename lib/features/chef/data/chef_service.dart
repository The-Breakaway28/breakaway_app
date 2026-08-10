import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chefServiceProvider = Provider<ChefService>((ref) {
  final authService = ref.read(authServiceProvider);
  final apiClient = ApiClient(authService);
  return ChefService(apiClient);
});

class ChefService {
  final ApiClient _apiClient;
  ChefService(this._apiClient);
  static const String _baseUrl = 'http://178.104.120.91:3000';

  Future<List<dynamic>> getRidersStatus() async {
    final response = await _apiClient.get('$_baseUrl/chef/riders-status');
    if (response.statusCode != 200) {
      throw Exception('Failed to load riders status');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }
}
