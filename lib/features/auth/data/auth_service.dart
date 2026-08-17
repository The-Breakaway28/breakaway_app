import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String? currentToken;
  static String? currentRole;
  static const String _baseUrl = 'https://breakaway-api.duckdns.org';
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _saveCredentials(String token, String role) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
    currentToken = token;
    currentRole = role;
  }

  Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  Future<String?> getRole() async => await _storage.read(key: _roleKey);

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    currentToken = null;
    currentRole = null;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = data['access_token'] as String;
      final role = data['user']['role'] as String? ?? 'rider';
      await _saveCredentials(token, role);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Ошибка регистрации');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['access_token'] as String;
        final role = data['user']['role'] as String;
        await _saveCredentials(token, role);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Ошибка входа');
      }
    } catch (e) {
      debugPrint('ERROR: $e');
      rethrow;
    }
  }
}
