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
            final fuelLevel = (vehicle['fuelLevel'] as num?)?.toDouble() ?? 0;
            final waterLevel = (vehicle['waterLevel'] as num?)?.toDouble() ?? 0;
            final propaneLevel = (vehicle['propaneLevel'] as num?)?.toDouble() ?? 0;
            final batteryCharge = (vehicle['batteryCharge'] as num?)?.toDouble() ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.directions_car, size: 80, color: AppColors.neon),
                  const SizedBox(height: 24),
                  Text(name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  _buildProgressBar('⛽ Топливо', fuelLevel),
                  _buildProgressBar('💧 Вода', waterLevel),
                  _buildProgressBar('🔥 Пропан', propaneLevel),
                  _buildProgressBar('🔋 Батарея', batteryCharge),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await authService.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Выйти'),
                    ),
                  ),
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

  Widget _buildProgressBar(String label, double value) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
