import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:divelogtest/providers/dive_provider.dart';
import 'package:divelogtest/theme.dart';
import 'package:divelogtest/widgets/quick_action_card.dart';
import 'package:divelogtest/widgets/stat_card.dart';
import 'package:divelogtest/widgets/dive_card.dart';
import 'package:divelogtest/widgets/empty_state_card.dart';
import 'package:divelogtest/screens/dive_list_screen.dart';
import 'package:divelogtest/screens/add_edit_dive_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _refreshData(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await context.read<DiveProvider>().refreshData(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<DiveProvider>(
      builder: (context, diveProvider, child) {
        final stats = diveProvider.statistics;
        final recentDives = diveProvider.recentDives;
        final isLoading = diveProvider.isLoading;

        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshData(context),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                      // Quick Actions
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: QuickActionCard(
                                    icon: Icons.add_circle,
                                    title: 'Nueva Inmersión',
                                    color: colorScheme.primary,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AddEditDiveScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: QuickActionCard(
                                    icon: Icons.list_alt,
                                    title: 'Ver Todas',
                                    color: colorScheme.secondary,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const DiveListScreen()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Statistics Section
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Text(
                          'Estadísticas',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.water,
                                value: '${stats['totalDives'] ?? 0}',
                                label: 'Inmersiones',
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.schedule,
                                value: '${(stats['totalDiveTime'] ?? 0).toStringAsFixed(0)}m',
                                label: 'Tiempo Total',
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.arrow_downward,
                                value: '${(stats['deepestDive'] ?? 0).toStringAsFixed(1)}m',
                                label: 'Profundidad Máx',
                                color: colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.water_drop,
                                value: '${(stats['averageDepth'] ?? 0).toStringAsFixed(1)}m',
                                label: 'Prof. Promedio',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Recent Dives Section
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Inmersiones Recientes',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (recentDives.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const DiveListScreen()),
                                  );
                                },
                                child: const Text('Ver todas'),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (recentDives.isEmpty)
                        Padding(
                          padding: AppSpacing.paddingLg,
                          child: EmptyStateCard(
                            icon: Icons.scuba_diving,
                            title: 'No hay inmersiones',
                            subtitle: 'Registra tu primera inmersión para comenzar',
                            actionLabel: 'Agregar Inmersión',
                            onAction: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddEditDiveScreen()),
                              );
                            },
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: AppSpacing.horizontalLg,
                          itemCount: recentDives.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final dive = recentDives[index];
                            return DiveCard(
                              dive: dive,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditDiveScreen(existingDive: dive),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
