import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/analytics_dashboard_entity.dart';

/// Card yang menampilkan distribusi gender dalam bentuk bar horizontal.
class GenderChartCard extends StatelessWidget {
  final GenderDistribution gender;

  const GenderChartCard({super.key, required this.gender});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            _GenderBar(
              label: 'Pria',
              count: gender.male.count,
              percentage: gender.male.percentage,
              color: AppColors.chartBlue,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _GenderBar(
              label: 'Wanita',
              count: gender.female.count,
              percentage: gender.female.percentage,
              color: AppColors.chartPink,
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
