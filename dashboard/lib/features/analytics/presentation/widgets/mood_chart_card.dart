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
            _MoodLegend(),
            const SizedBox(height: AppDimensions.spacingM),
            _ZoneMoodRow(label: 'Entry', snapshot: mood.entry),
            const SizedBox(height: AppDimensions.spacingS),
            _ZoneMoodRow(label: 'Exit', snapshot: mood.exit),
            const SizedBox(height: AppDimensions.spacingS),
            _ZoneMoodRow(label: 'Kasir', snapshot: mood.cashier),
            const SizedBox(height: AppDimensions.spacingS),
            _ZoneMoodRow(label: 'Lantai', snapshot: mood.floor),
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
  final MoodSnapshot snapshot;

  const _ZoneMoodRow({required this.label, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total =
        snapshot.happy + snapshot.neutral + snapshot.sad + snapshot.angry + snapshot.surprised;

    final segments = [
      (value: snapshot.happy, color: AppColors.success),
      (value: snapshot.neutral, color: AppColors.chartBlue),
      (value: snapshot.sad, color: AppColors.chartPurple),
      (value: snapshot.angry, color: AppColors.error),
      (value: snapshot.surprised, color: AppColors.chartOrange),
    ];

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
                children: segments
                    .where((s) => s.value > 0)
                    .map(
                      (s) => Flexible(
                        flex: (s.value * 100).round(),
                        child: Container(color: s.color),
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
            '${snapshot.happy.toStringAsFixed(0)}% 😊',
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
