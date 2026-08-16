import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/all_vehicles_provider.dart';
import '../providers/stages_provider.dart';

class CEODashboardScreen extends ConsumerStatefulWidget {
  const CEODashboardScreen({super.key});

  @override
  ConsumerState<CEODashboardScreen> createState() => _CEODashboardScreenState();
}

class _CEODashboardScreenState extends ConsumerState<CEODashboardScreen> {
  bool _isRefreshing = false;
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(45.05, 6.08);
  double _currentZoom = 11.0;

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    ref.invalidate(allVehiclesProvider);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _zoomIn() => _mapController.move(_currentCenter, _currentZoom + 1);
  void _zoomOut() => _mapController.move(_currentCenter, _currentZoom - 1);
  void _locate() => _mapController.move(_currentCenter, 13);

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final vehiclesAsync = ref.watch(allVehiclesProvider);
    final stagesAsync = ref.watch(stagesProvider);

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
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(child: Text('Нет данных об автодомах'));
          }
          final markers = <Marker>[];
          for (final v in vehicles) {
            final lat = (v['gpsLat'] as num?)?.toDouble();
            final lng = (v['gpsLng'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              markers.add(
                Marker(
                  point: LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.directions_car, color: AppColors.neon, size: 32),
                ),
              );
            }
          }

          return Column(
            children: [
              Expanded(
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
                        if (markers.isNotEmpty) MarkerLayer(markers: markers),
                        if (stagesAsync.hasValue && stagesAsync.value!.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _buildRoutePoints(stagesAsync.value!.first['routeGeoJSON']),
                                strokeWidth: 4,
                                color: AppColors.neon,
                              ),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      right: 12,
                      bottom: 24,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'zoom_in',
                            mini: true,
                            onPressed: _zoomIn,
                            backgroundColor: AppColors.emeraldSurface,
                            child: const Icon(Icons.add, color: AppColors.neon),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'zoom_out',
                            mini: true,
                            onPressed: _zoomOut,
                            backgroundColor: AppColors.emeraldSurface,
                            child: const Icon(Icons.remove, color: AppColors.neon),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'locate',
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
                                const Icon(Icons.directions_car, color: AppColors.neon),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Тип: $type', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            _buildAnimatedProgressBar('⛽ Топливо', fuel),
                            _buildAnimatedProgressBar('💧 Вода', water),
                            _buildAnimatedProgressBar('🔥 Пропан', propane),
                            _buildAnimatedProgressBar('🔋 Батарея', battery),
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

  List<LatLng> _buildRoutePoints(dynamic geoJson) {
    final points = <LatLng>[];
    if (geoJson == null) return points;
    final coords = geoJson['coordinates'] as List?;
    if (coords == null) return points;
    for (final coord in coords) {
      if (coord is List && coord.length >= 2) {
        points.add(LatLng(coord[1] as double, coord[0] as double));
      }
    }
    return points;
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
