import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ceoServiceProvider = Provider<CeoService>((ref) {
  final authService = ref.read(authServiceProvider);
  final apiClient = ApiClient(authService);
  return CeoService(apiClient);
});

class CeoService {
  final ApiClient _apiClient;
  CeoService(this._apiClient);
  static const String _baseUrl = 'https://breakaway-api.duckdns.org';

  Future<List<dynamic>> getAllVehicles() async {
    final response = await _apiClient.get('$_baseUrl/vehicles');
    if (response.statusCode != 200) {
      throw Exception('Failed to load vehicles');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }
}
