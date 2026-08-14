import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/weather_provider.dart';
import '../providers/telemetry_provider.dart';
import '../providers/media_provider.dart';
import '../../../core/widgets/empty_state.dart';

class RiderDashboardScreen extends ConsumerWidget {
  const RiderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final weatherAsync = ref.watch(currentWeatherProvider(const (lat: 45.0, lng: 6.0)));
    const riderId = '4dad9c5c-f171-462b-8d4a-112eb3c49a83';
    final telemetryAsync = ref.watch(riderTelemetryProvider(riderId));
    final mediaAsync = ref.watch(mediaClipsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_bike, size: 80, color: AppColors.neon),
              const SizedBox(height: 24),
              Text('Добро пожаловать, Райдер!', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),

              // Погода
              weatherAsync.when(
                data: (weather) => Card(
                  color: AppColors.emeraldSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('🌡 ${weather['temperature']}°C, ${weather['description']}', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text('💨 Ветер: ${weather['windSpeed']} м/с', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text('💧 Влажность: ${weather['humidity']}%', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Ошибка погоды: $e'),
              ),
              const SizedBox(height: 24),

              // Телеметрия
              Text('Последняя телеметрия', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              telemetryAsync.when(
                data: (telemetryList) {
                  if (telemetryList.isEmpty) return const EmptyState(icon: Icons.monitor_heart_outlined, title: 'Нет телеметрии', subtitle: 'Данные появятся после первого этапа');
                  final last = telemetryList.first;
                  return Card(
                    color: AppColors.emeraldSurface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (last['metricName'] != null) Text('${last['metricName']}: ${last['metricValue']}'),
                          Text('Время: ${DateTime.parse(last['time']).toLocal()}'),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Ошибка телеметрии: $e'),
              ),
              const SizedBox(height: 24),

              // Мои видео
              Text('Мои видео', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              mediaAsync.when(
                data: (clips) {
                  if (clips.isEmpty) return const EmptyState(icon: Icons.video_library_outlined, title: 'Видео пока нет', subtitle: 'Ваши хайлайты появятся здесь после обработки');
                  return Column(
                    children: clips.map((clip) {
                      return Card(
                        color: AppColors.emeraldSurface,
                        child: ListTile(
                          title: Text('Хайлайт ${clip['createdAt']}'),
                          subtitle: Text(clip['result_url'] ?? ''),
                          trailing: const Icon(Icons.play_circle, color: AppColors.neon),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Ошибка видео: $e'),
              ),
              const SizedBox(height: 24),

              // SOS-кнопка
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.emeraldSurface,
                        title: const Text('Отправить SOS?'),
                        content: const Text('Будет отправлен сигнал тревоги.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS отправлен')));
                            },
                            child: const Text('SOS'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('⚠️ SOS'),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await authService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Выйти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
