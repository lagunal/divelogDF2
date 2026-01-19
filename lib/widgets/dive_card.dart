import 'package:flutter/material.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/theme.dart';
import 'package:intl/intl.dart';

class DiveCard extends StatelessWidget {
  final DiveSession dive;
  final VoidCallback onTap;

  const DiveCard({
    super.key,
    required this.dive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Hero(
      tag: 'dive_card_${dive.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [AppEffects.softShadow],
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, colorScheme, theme),
                const SizedBox(height: AppSpacing.md),
                _buildDetails(context, colorScheme, theme, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    final dateStr = DateFormat('dd MMM yyyy').format(dive.horaEntrada);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: LightModeColors.oceanGradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.scuba_diving,
            size: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dive.lugarBuceo,
                style: theme.textTheme.titleMedium?.semiBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                dateStr,
                style: theme.textTheme.bodySmall?.withColor(
                  colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, ColorScheme colorScheme,
      ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem(
          Icons.arrow_downward,
          '${dive.maximaProfundidad}m',
          'Profundidad',
          colorScheme.primary,
          theme,
        ),
        _buildInfoItem(
          Icons.timer_outlined,
          '${dive.tiempoFondo.toStringAsFixed(0)}min',
          'Tiempo',
          colorScheme.secondary,
          theme,
        ),
        _buildInfoItem(
          Icons.water_drop_outlined,
          dive.tipoAgua,
          'Agua',
          LightModeColors.turquoise,
          theme,
        ),
      ],
    );
  }

  Widget _buildInfoItem(
      IconData icon, String value, String label, Color color, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.semiBold,
            ),
          ],
        ),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            letterSpacing: 0.5,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
