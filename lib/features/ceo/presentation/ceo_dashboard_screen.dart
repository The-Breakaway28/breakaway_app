import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/all_vehicles_provider.dart';

class CEODashboardScreen extends ConsumerWidget {
  const CEODashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final vehiclesAsync = ref.watch(allVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CEO Dashboard'),
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
        child: vehiclesAsync.when(
          data: (vehicles) {
            if (vehicles.isEmpty) {
              return const Text('Нет данных об автодомах');
            }
            return ListView.builder(
              itemCount: vehicles.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                final name = vehicle['name'] ?? '—';
                final type = vehicle['type'] ?? '—';
                final fuel = (vehicle['fuelLevel'] as num?)?.toDouble();
                final water = (vehicle['waterLevel'] as num?)?.toDouble();

                return Card(
                  color: AppColors.emeraldSurface,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(name, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text('Тип: $type | Топливо: ${fuel?.toStringAsFixed(0) ?? '—'}% | Вода: ${water?.toStringAsFixed(0) ?? '—'}%'),
                    trailing: const Icon(Icons.directions_car, color: AppColors.neon),
                  ),
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Ошибка загрузки: $error'),
        ),
      ),
    );
  }
}
