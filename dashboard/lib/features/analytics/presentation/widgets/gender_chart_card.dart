import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/analytics_dashboard_entity.dart';

/// Card yang menampilkan distribusi gender dalam bentuk bar horizontal.
class GenderChartCard extends StatelessWidget {
  final List<GenderItem> gender;

  const GenderChartCard({super.key, required this.gender});

  GenderItem? _find(String key) {
    try {
      return gender.firstWhere((g) => g.gender == key);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final male = _find('male');
    final female = _find('female');

    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.genderDistribution,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            if (male != null)
              _GenderBar(
                label: 'Pria',
                count: male.count,
                percentage: male.percentage,
                color: AppColors.chartBlue,
              ),
            if (male != null) const SizedBox(height: AppDimensions.spacingS),
            if (female != null)
              _GenderBar(
                label: 'Wanita',
                count: female.count,
                percentage: female.percentage,
                color: AppColors.chartPink,
              ),
            if (gender.isNotEmpty &&
                male == null &&
                female == null)
              ...gender.map(
                (g) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.spacingS),
                  child: _GenderBar(
                    label: g.gender,
                    count: g.count,
                    percentage: g.percentage,
                    color: AppColors.chartBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GenderBar extends StatelessWidget {
  final String label;
  final int count;
  final double percentage;
  final Color color;

  const _GenderBar({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          child: LinearProgressIndicator(
            value: percentage / 100.0,
            minHeight: 10,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
