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
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<DiveProvider>(
      builder: (context, diveProvider, child) {
        final stats = diveProvider.statistics;
        final recentDives = diveProvider.recentDives;
        final isLoading = diveProvider.isLoading;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => _refreshData(context),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(context, isDark),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuickActions(context, colorScheme),
                        const SizedBox(height: AppSpacing.xl),
                        _buildStatsSection(context, stats, colorScheme, theme),
                        const SizedBox(height: AppSpacing.xl),
                        _buildRecentDivesSection(
                            context, recentDives, theme, colorScheme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final userName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Buceador';

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? DarkModeColors.abyssalGradient
                : LightModeColors.oceanGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Icon(
                  Icons.scuba_diving,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, $userName!',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      '¿Listo para tu próxima inmersión?',
                      style: Theme.of(context).textTheme.bodyLarge?.withColor(
                            Colors.white.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: AppSpacing.horizontalLg,
      child: Row(
        children: [
          Expanded(
            child: QuickActionCard(
              icon: Icons.add_circle,
              title: 'Nueva Inmersión',
              color: colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddEditDiveScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: QuickActionCard(
              icon: Icons.list_alt,
              title: 'Ver Todas',
              color: colorScheme.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DiveListScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, Map<String, dynamic> stats,
      ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.horizontalLg,
          child: Text(
            'Estadísticas',
            style: theme.textTheme.titleLarge?.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.horizontalLg,
            children: [
              SizedBox(
                width: 160,
                child: StatCard(
                  icon: Icons.water,
                  value: '${stats['totalDives'] ?? 0}',
                  label: 'Inmersiones',
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 160,
                child: StatCard(
                  icon: Icons.schedule,
                  value: '${(stats['totalDiveTime'] ?? 0).toStringAsFixed(0)}m',
                  label: 'Tiempo Total',
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 160,
                child: StatCard(
                  icon: Icons.arrow_downward,
                  value: '${(stats['deepestDive'] ?? 0).toStringAsFixed(1)}m',
                  label: 'Máx Prof.',
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDivesSection(BuildContext context, List recentDives,
      ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.horizontalLg,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inmersiones Recientes',
                style: theme.textTheme.titleLarge?.semiBold,
              ),
              if (recentDives.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DiveListScreen()),
                    );
                  },
                  child: const Text('Ver todas'),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
                  MaterialPageRoute(
                      builder: (context) => const AddEditDiveScreen()),
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
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final dive = recentDives[index];
              return DiveCard(
                dive: dive,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditDiveScreen(existingDive: dive),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
