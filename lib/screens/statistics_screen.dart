import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/providers/dive_provider.dart';
import 'package:divelogtest/services/user_service.dart';
import 'package:divelogtest/theme.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  final UserService? userService;

  const StatisticsScreen({super.key, this.userService});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final UserService _userService;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? UserService();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await _userService.initialize();
    _userId = _userService.getCurrentUserId();
  }

  Future<void> _refreshStatistics() async {
    if (_userId != null) {
      await context.read<DiveProvider>().refreshData(_userId!);
    }
  }

  Map<String, int> _getLocationStats(List<DiveSession> allDives) {
    final Map<String, int> locationCount = {};
    for (var dive in allDives) {
      locationCount[dive.lugarBuceo] = (locationCount[dive.lugarBuceo] ?? 0) + 1;
    }
    return Map.fromEntries(
      locationCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Map<String, int> _getDiveTypeStats(List<DiveSession> allDives) {
    final Map<String, int> typeCount = {};
    for (var dive in allDives) {
      typeCount[dive.tipoBuceo] = (typeCount[dive.tipoBuceo] ?? 0) + 1;
    }
    return typeCount;
  }

  List<DiveSession> _getRecentDives(List<DiveSession> allDives) => allDives.take(5).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<DiveProvider>(
      builder: (context, diveProvider, child) {
        final stats = diveProvider.statistics;
        final allDives = diveProvider.allDives;
        final isLoading = diveProvider.isLoading;

        return Scaffold(
          body: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshStatistics,
                    child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: AppSpacing.paddingLg,
                        child: Text(
                          'Estadísticas',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),

                      // Overview Stats
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.water,
                                    value: '${stats['totalDives'] ?? 0}',
                                    label: 'Total Inmersiones',
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.schedule,
                                    value: '${(stats['totalDiveTime'] ?? 0).toStringAsFixed(0)}m',
                                    label: 'Tiempo Total',
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.arrow_downward,
                                    value: '${(stats['deepestDive'] ?? 0).toStringAsFixed(1)}m',
                                    label: 'Profundidad Máxima',
                                    color: colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.water_drop,
                                    value: '${(stats['averageDepth'] ?? 0).toStringAsFixed(1)}m',
                                    label: 'Prof. Promedio',
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Location Stats
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Text(
                          'Lugares Más Visitados',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: _LocationStatsCard(locations: _getLocationStats(allDives)),
                      ),

                      const SizedBox(height: 32),

                      // Dive Type Stats
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Text(
                          'Tipos de Buceo',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: _DiveTypeStatsCard(diveTypes: _getDiveTypeStats(allDives)),
                      ),

                      const SizedBox(height: 32),

                      // Recent Activity
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Text(
                          'Actividad Reciente',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: _RecentActivityCard(recentDives: _getRecentDives(allDives)),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LocationStatsCard extends StatelessWidget {
  final Map<String, int> locations;

  const _LocationStatsCard({required this.locations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (locations.isEmpty) {
      return Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Center(
          child: Text(
            'No hay datos disponibles',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: locations.entries.take(5).map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.value}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DiveTypeStatsCard extends StatelessWidget {
  final Map<String, int> diveTypes;

  const _DiveTypeStatsCard({required this.diveTypes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (diveTypes.isEmpty) {
      return Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Center(
          child: Text(
            'No hay datos disponibles',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: diveTypes.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.scuba_diving,
                      color: colorScheme.secondary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.value}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final List<DiveSession> recentDives;

  const _RecentActivityCard({required this.recentDives});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (recentDives.isEmpty) {
      return Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Center(
          child: Text(
            'No hay actividad reciente',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: recentDives.map((dive) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.water,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dive.lugarBuceo,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd/MM/yyyy').format(dive.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${dive.maximaProfundidad}m',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
