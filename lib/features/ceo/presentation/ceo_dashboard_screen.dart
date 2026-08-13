import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neon),
                  )
                : const Icon(Icons.refresh),
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
          return Column(
            children: [
              // Карта
              SizedBox(
                height: 220,
                width: double.infinity,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(45.0, 6.0),
                    initialZoom: 11.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.breakaway.app',
                    ),
                  ],
                ),
              ),
              // Список автодомов с прогресс-барами
              Expanded(
                child: ListView.builder(
                  itemCount: vehicles.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    final name = vehicle['name'] ?? '—';
                    final type = vehicle['type'] ?? '—';
                    final fuel = (vehicle['fuelLevel'] as num?)?.toDouble() ?? 0;
                    final water = (vehicle['waterLevel'] as num?)?.toDouble() ?? 0;
                    final propane = (vehicle['propaneLevel'] as num?)?.toDouble() ?? 0;
                    final battery = (vehicle['batteryCharge'] as num?)?.toDouble() ?? 0;

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
                                Icon(Icons.directions_car, color: AppColors.neon),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Тип: $type', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            _buildProgressBar('⛽ Топливо', fuel),
                            _buildProgressBar('💧 Вода', water),
                            _buildProgressBar('🔥 Пропан', propane),
                            _buildProgressBar('🔋 Батарея', battery),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка загрузки: $error')),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text('${value.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
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
