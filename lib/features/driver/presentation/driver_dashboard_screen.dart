import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/vehicle_provider.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final vehicleAsync = ref.watch(vehicleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
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
      body: Center(
        child: vehicleAsync.when(
          data: (vehicle) {
            final name = vehicle['name'] ?? '—';
            final fuelLevel = (vehicle['fuelLevel'] as num?)?.toDouble() ?? 0;
            final waterLevel = (vehicle['waterLevel'] as num?)?.toDouble() ?? 0;
            final propaneLevel = (vehicle['propaneLevel'] as num?)?.toDouble() ?? 0;
            final batteryCharge = (vehicle['batteryCharge'] as num?)?.toDouble() ?? 0;
            final gpsLat = (vehicle['gpsLat'] as num?)?.toDouble();
            final gpsLng = (vehicle['gpsLng'] as num?)?.toDouble();

            return Column(
              children: [
                // Карта с маркером автодома
                if (gpsLat != null && gpsLng != null)
                  SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(gpsLat, gpsLng),
                        initialZoom: 12,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.breakaway.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(gpsLat, gpsLng),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.directions_car, color: AppColors.neon, size: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(
                    height: 200,
                    child: Center(child: Text('Нет координат автодома')),
                  ),
                // Прогресс-бары
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.directions_car, size: 64, color: AppColors.neon),
                        const SizedBox(height: 16),
                        Text(name, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 24),
                        _buildAnimatedProgressBar('⛽ Топливо', fuelLevel),
                        _buildAnimatedProgressBar('💧 Вода', waterLevel),
                        _buildAnimatedProgressBar('🔥 Пропан', propaneLevel),
                        _buildAnimatedProgressBar('🔋 Батарея', batteryCharge),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Ошибка загрузки: $error'),
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressBar(String label, double value) {
    Color color;
    if (value > 50) {
      color = AppColors.neon;
    } else if (value > 20) {
      color = Colors.orange;
    } else {
      color = AppColors.error;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              Text('${value.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value / 100),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 10,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
