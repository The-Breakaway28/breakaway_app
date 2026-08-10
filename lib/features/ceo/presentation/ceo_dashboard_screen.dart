import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/all_vehicles_provider.dart';

class CEODashboardScreen extends ConsumerStatefulWidget {
  const CEODashboardScreen({super.key});

  @override
  ConsumerState<CEODashboardScreen> createState() => _CEODashboardScreenState();
}

class _CEODashboardScreenState extends ConsumerState<CEODashboardScreen> {
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    ref.invalidate(allVehiclesProvider);
    // Ждём завершения обновления провайдера
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final vehiclesAsync = ref.watch(allVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CEO Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: _isRefreshing ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neon),
            ) : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(child: Text('Нет данных об автодомах'));
          }
          return ListView.builder(
            itemCount: vehicles.length + 1,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Card(
                  color: AppColors.emeraldSurface,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🌅 Утренний брифинг', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Погода, ветер, рекомендации — здесь появится сводка перед стартом этапа.',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              }

              final vehicle = vehicles[index - 1];
              final name = vehicle['name'] ?? '—';
              final type = vehicle['type'] ?? '—';
              final fuel = (vehicle['fuelLevel'] as num?)?.toDouble();
              final water = (vehicle['waterLevel'] as num?)?.toDouble();
              final propane = (vehicle['propaneLevel'] as num?)?.toDouble();
              final battery = (vehicle['batteryCharge'] as num?)?.toDouble();
              final gpsLat = (vehicle['gpsLat'] as num?)?.toDouble();
              final gpsLng = (vehicle['gpsLng'] as num?)?.toDouble();

              return Card(
                color: AppColors.emeraldSurface,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name, style: Theme.of(context).textTheme.titleMedium),
                          Icon(Icons.directions_car, color: _getStatusColor(fuel, water)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Тип: $type', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      if (fuel != null || water != null || propane != null || battery != null)
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            if (fuel != null) _buildBadge('⛽', '${fuel.toStringAsFixed(0)}%'),
                            if (water != null) _buildBadge('💧', '${water.toStringAsFixed(0)}%'),
                            if (propane != null) _buildBadge('🔥', '${propane.toStringAsFixed(0)}%'),
                            if (battery != null) _buildBadge('🔋', '${battery.toStringAsFixed(0)}%'),
                          ],
                        ),
                      if (gpsLat != null && gpsLng != null) ...[
                        const SizedBox(height: 8),
                        Text('📍 ${gpsLat.toStringAsFixed(4)}, ${gpsLng.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка загрузки: $error')),
      ),
    );
  }

  Widget _buildBadge(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.emeraldLine,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$emoji $text', style: const TextStyle(fontSize: 12)),
    );
  }

  Color _getStatusColor(double? fuel, double? water) {
    if ((fuel ?? 100) < 15 || (water ?? 100) < 20) return AppColors.error;
    if ((fuel ?? 100) < 30 || (water ?? 100) < 40) return Colors.orange;
    return AppColors.neon;
  }
}
