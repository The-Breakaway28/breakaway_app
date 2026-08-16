// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'video_player_screen.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/weather_provider.dart';
import '../providers/telemetry_provider.dart';
import '../providers/media_provider.dart';
import '../providers/live_telemetry_provider.dart';

class RiderDashboardScreen extends ConsumerStatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  ConsumerState<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends ConsumerState<RiderDashboardScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(45.0, 6.0);
  double _currentZoom = 11.0;

  void _zoomIn() => _mapController.move(_currentCenter, _currentZoom + 1);
  void _zoomOut() => _mapController.move(_currentCenter, _currentZoom - 1);
  void _locate() => _mapController.move(_currentCenter, 13);

  void _openVideo(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final weatherAsync = ref.watch(currentWeatherProvider(const (lat: 45.0, lng: 6.0)));
    const riderId = '4dad9c5c-f171-462b-8d4a-112eb3c49a83';
    final telemetryAsync = ref.watch(riderTelemetryProvider(riderId));
    final mediaAsync = ref.watch(mediaClipsProvider);
    final liveTelemetry = ref.watch(liveTelemetryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: _currentZoom,
                    onPositionChanged: (position, hasGesture) {
                      _currentCenter = position.center;
                      _currentZoom = position.zoom;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.breakaway.app',
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  bottom: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'rider_zoom_in',
                        mini: true,
                        onPressed: _zoomIn,
                        backgroundColor: AppColors.emeraldSurface,
                        child: const Icon(Icons.add, color: AppColors.neon),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'rider_zoom_out',
                        mini: true,
                        onPressed: _zoomOut,
                        backgroundColor: AppColors.emeraldSurface,
                        child: const Icon(Icons.remove, color: AppColors.neon),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'rider_locate',
                        mini: true,
                        onPressed: _locate,
                        backgroundColor: AppColors.emeraldSurface,
                        child: const Icon(Icons.my_location, color: AppColors.neon),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_bike, size: 56, color: AppColors.neon),
                  const SizedBox(height: 16),
                  Text('Добро пожаловать, Райдер!', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),

                  // Live телеметрия
                  if (liveTelemetry != null)
                    Card(
                      color: AppColors.emeraldSurface,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Live: ${liveTelemetry['metricName']}', style: Theme.of(context).textTheme.bodyLarge),
                            Text('${liveTelemetry['metricValue']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.neon)),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

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

                  // Последняя телеметрия из REST
                  Text('Последняя телеметрия', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  telemetryAsync.when(
                    data: (telemetryList) {
                      if (telemetryList.isEmpty) {
                        return const EmptyState(
                          icon: Icons.monitor_heart_outlined,
                          title: 'Нет телеметрии',
                          subtitle: 'Данные появятся после первого этапа',
                        );
                      }
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
                      if (clips.isEmpty) {
                        return const EmptyState(
                          icon: Icons.video_library_outlined,
                          title: 'Видео пока нет',
                          subtitle: 'Ваши хайлайты появятся здесь после обработки',
                        );
                      }
                      return Column(
                        children: clips.map((clip) {
                          final url = clip['result_url'] ?? '';
                          return Card(
                            color: AppColors.emeraldSurface,
                            child: ListTile(
                              title: Text('Хайлайт ${clip['createdAt']}'),
                              subtitle: Text(url),
                              trailing: const Icon(Icons.play_circle, color: AppColors.neon),
                              onTap: () => _openVideo(url),
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
                      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Выйти'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
