import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/analytics_dashboard_entity.dart';

/// Card yang menampilkan distribusi mood per zona dalam bentuk bar horizontal.
class MoodChartCard extends StatelessWidget {
  final MoodData mood;

  const MoodChartCard({super.key, required this.mood});

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
              AppStrings.moodAnalysis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            const _MoodLegend(),
            const SizedBox(height: AppDimensions.spacingM),
            _ZoneMoodRow(label: 'Entry', items: mood.entry),
            const SizedBox(height: AppDimensions.spacingS),
            _ZoneMoodRow(label: 'Exit', items: mood.exit),
            const SizedBox(height: AppDimensions.spacingS),
            _ZoneMoodRow(label: 'Kasir', items: mood.cashier),
            const SizedBox(height: AppDimensions.spacingS),
            _ZoneMoodRow(label: 'Lantai', items: mood.floor),
          ],
        ),
      ),
    );
  }
}

class _MoodLegend extends StatelessWidget {
  static const _moodColors = [
    (label: 'Senang', color: AppColors.success),
    (label: 'Netral', color: AppColors.chartBlue),
    (label: 'Sedih', color: AppColors.chartPurple),
    (label: 'Marah', color: AppColors.error),
    (label: 'Terkejut', color: AppColors.chartOrange),
  ];

  const _MoodLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingM,
      runSpacing: AppDimensions.spacingXs,
      children: _moodColors
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppDimensions.spacingM,
                  height: AppDimensions.spacingM,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _ZoneMoodRow extends StatelessWidget {
  final String label;
  final List<MoodItem> items;

  const _ZoneMoodRow({required this.label, required this.items});

  Color _colorForMood(String mood) {
    return switch (mood) {
      'happy' => AppColors.success,
      'neutral' => AppColors.chartBlue,
      'sad' => AppColors.chartPurple,
      'angry' => AppColors.error,
      'surprised' => AppColors.chartOrange,
      _ => AppColors.surfaceVariant,
    };
  }

  double _happyPercentage() {
    try {
      return items.firstWhere((i) => i.mood == 'happy').percentage;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Expanded(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusCircle),
            child: SizedBox(
              height: 16,
              child: Row(
                children: items
                    .where((i) => i.percentage > 0)
                    .map(
                      (i) => Flexible(
                        flex: (i.percentage * 100).round(),
                        child: Container(color: _colorForMood(i.mood)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        SizedBox(
          width: 52,
          child: Text(
            '${_happyPercentage().toStringAsFixed(0)}% 😊',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
