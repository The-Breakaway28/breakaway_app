import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: vehicleAsync.when(
          data: (vehicle) {
            final name = vehicle['name'] ?? '—';
            final type = vehicle['type'] ?? '—';
            final fuelLevel = (vehicle['fuelLevel'] as num?)?.toDouble();
            final waterLevel = (vehicle['waterLevel'] as num?)?.toDouble();
            final propaneLevel = (vehicle['propaneLevel'] as num?)?.toDouble();
            final batteryCharge = (vehicle['batteryCharge'] as num?)?.toDouble();
            final solarPower = (vehicle['solarPower'] as num?)?.toDouble();
            final gpsLat = (vehicle['gpsLat'] as num?)?.toDouble();
            final gpsLng = (vehicle['gpsLng'] as num?)?.toDouble();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car, size: 80, color: AppColors.neon),
                  const SizedBox(height: 24),
                  Text(name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Тип: $type', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 32),
                  Card(
                    color: AppColors.emeraldSurface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProgressBar('⛽ Топливо', fuelLevel),
                          const SizedBox(height: 16),
                          _buildProgressBar('💧 Вода', waterLevel),
                          const SizedBox(height: 16),
                          _buildProgressBar('🔥 Пропан', propaneLevel),
                          const SizedBox(height: 16),
                          _buildProgressBar('🔋 Батарея', batteryCharge),
                          const SizedBox(height: 16),
                          _buildProgressBar('☀️ Солнечные панели', solarPower),
                        ],
                      ),
                    ),
                  ),
                  if (gpsLat != null && gpsLng != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      '📍 GPS: ${gpsLat.toStringAsFixed(4)}, ${gpsLng.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Ошибка загрузки: $error'),
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double? value) {
    final percentage = value ?? 0;
    final isCritical = percentage < 20;
    final isWarning = percentage >= 20 && percentage < 40;

    Color barColor;
    if (isCritical) {
      barColor = AppColors.error;
    } else if (isWarning) {
      barColor = Colors.orange;
    } else {
      barColor = AppColors.neon;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text(
              value != null ? '${percentage.toStringAsFixed(0)}%' : '—',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: value != null ? barColor : AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value != null ? percentage / 100 : 0,
            backgroundColor: AppColors.emeraldLine,
            color: barColor,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
