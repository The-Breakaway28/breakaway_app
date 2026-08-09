import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService());

final currentWeatherProvider = FutureProvider.family<Map<String, dynamic>, ({double lat, double lng})>(
  (ref, coords) async {
    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final weatherService = ref.read(weatherServiceProvider);
    return weatherService.getCurrentWeather(coords.lat, coords.lng, token);
  },
);
