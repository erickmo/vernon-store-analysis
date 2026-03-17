import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/behavior_entity.dart';
import '../../domain/entities/kpi_entity.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';
import '../widgets/kpi_card_widget.dart';

/// Halaman statistik yang menampilkan KPI dan customer behavior suatu toko.
class StatisticsPage extends StatefulWidget {
  /// ID toko yang akan ditampilkan statistiknya.
  final int storeId;

  const StatisticsPage({super.key, required this.storeId});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsCubit>().loadAll(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text(AppStrings.statistics),
        elevation: AppDimensions.cardElevation,
        actions: [
          IconButton(
            onPressed: () {
              context.read<StatisticsCubit>().loadAll(widget.storeId);
            },
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.refresh,
          ),
        ],
      ),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          return switch (state) {
            StatisticsInitial() => const SizedBox.shrink(),
            StatisticsAllLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            StatisticsKpiLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            StatisticsBehaviorLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            StatisticsLoaded(:final kpi, :final behavior) =>
              _StatisticsContent(kpi: kpi, behavior: behavior),
            StatisticsError(:final message) => _ErrorView(
              message: message,
              onRetry: () =>
                  context.read<StatisticsCubit>().loadAll(widget.storeId),
            ),
          };
        },
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  final KpiEntity? kpi;
  final BehaviorEntity? behavior;

  const _StatisticsContent({required this.kpi, required this.behavior});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kpi != null) ...[
            _SectionTitle(title: AppStrings.kpi),
            const SizedBox(height: AppDimensions.spacingS),
            _KpiSection(kpi: kpi!),
            const SizedBox(height: AppDimensions.spacingL),
          ],
          if (behavior != null) ...[
            _SectionTitle(title: AppStrings.customerJourney),
            const SizedBox(height: AppDimensions.spacingS),
            _ZoneFlowSection(zoneFlow: behavior!.zoneFlow),
            const SizedBox(height: AppDimensions.spacingL),
            _SectionTitle(title: AppStrings.zoneHeatmap),
            const SizedBox(height: AppDimensions.spacingS),
            _ZoneHeatmapSection(heatmap: behavior!.zoneHeatmap),
            const SizedBox(height: AppDimensions.spacingL),
            _SectionTitle(title: AppStrings.peakHours),
            const SizedBox(height: AppDimensions.spacingS),
            _PeakHoursSection(peakHours: behavior!.peakHours),
            const SizedBox(height: AppDimensions.spacingL),
            _SectionTitle(title: AppStrings.moodShift),
            const SizedBox(height: AppDimensions.spacingS),
            _MoodShiftSection(moodShift: behavior!.moodShift),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: AppColors.onSurface,
      ),
    );
  }
}

class _KpiSection extends StatelessWidget {
  final KpiEntity kpi;

  const _KpiSection({required this.kpi});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth > 600 ? 3 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppDimensions.spacingS,
          mainAxisSpacing: AppDimensions.spacingS,
          childAspectRatio: 1.3,
          children: [
            KpiCardWidget(
              label: AppStrings.totalVisitors,
              value: NumberFormat.compact().format(kpi.totalVisitors),
              icon: Icons.people,
              accentColor: AppColors.chartBlue,
            ),
            KpiCardWidget(
              label: AppStrings.conversionRate,
              value: '${kpi.conversionRate.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              accentColor: AppColors.success,
            ),
            KpiCardWidget(
              label: AppStrings.bounceRate,
              value: '${kpi.bounceRate.toStringAsFixed(1)}%',
              icon: Icons.trending_down,
              accentColor: AppColors.error,
            ),
            KpiCardWidget(
              label: AppStrings.returnVisitorRate,
              value: '${kpi.returnVisitorRate.toStringAsFixed(1)}%',
              icon: Icons.replay,
              accentColor: AppColors.chartPurple,
            ),
            KpiCardWidget(
              label: AppStrings.satisfactionScore,
              value: kpi.satisfactionScore.toStringAsFixed(1),
              icon: Icons.star,
              accentColor: AppColors.warning,
              subtitle: '/ 10',
            ),
            KpiCardWidget(
              label: AppStrings.moodShift,
              value:
                  '+${kpi.moodShiftSummary.improved.toStringAsFixed(1)}%',
              icon: Icons.mood,
              accentColor: AppColors.chartTeal,
            ),
          ],
        );
      },
    );
  }
}

class _ZoneFlowSection extends StatelessWidget {
  final List<ZoneFlowEntity> zoneFlow;

  const _ZoneFlowSection({required this.zoneFlow});

  @override
  Widget build(BuildContext context) {
    if (zoneFlow.isEmpty) {
      return _EmptyCard();
    }

    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
        itemCount: zoneFlow.length,
        separatorBuilder: (_, __) => const Divider(
          color: AppColors.divider,
          height: 1,
          indent: AppDimensions.spacingM,
        ),
        itemBuilder: (context, index) {
          final flow = zoneFlow[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight.withOpacity(0.15),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              flow.pattern,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurface,
              ),
            ),
            subtitle: Text(
              '${flow.count} pengunjung',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            trailing: _PercentageBadge(percentage: flow.percentage),
          );
        },
      ),
    );
  }
}

class _ZoneHeatmapSection extends StatelessWidget {
  final List<ZoneHeatmapEntity> heatmap;

  const _ZoneHeatmapSection({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    if (heatmap.isEmpty) {
      return _EmptyCard();
    }

    final maxCount = heatmap
        .map((z) => z.visitCount)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          children: heatmap.map((zone) {
            final ratio = maxCount > 0 ? zone.visitCount / maxCount : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        zone.zone.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        '${zone.trafficShare.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusCircle,
                    ),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    '${NumberFormat.compact().format(zone.visitCount)} kunjungan',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PeakHoursSection extends StatelessWidget {
  final List<PeakHourEntity> peakHours;

  const _PeakHoursSection({required this.peakHours});

  @override
  Widget build(BuildContext context) {
    if (peakHours.isEmpty) {
      return _EmptyCard();
    }

    final maxAvg = peakHours
        .map((p) => p.avgVisitors)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: SizedBox(
          height: AppDimensions.chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: peakHours.map((hour) {
              final ratio = maxAvg > 0 ? hour.avgVisitors / maxAvg : 0.0;
              final barHeight =
                  (AppDimensions.chartHeight - 48) * ratio;
              final isPeak = hour.avgVisitors == maxAvg;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXs / 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        hour.avgVisitors.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 9,
                          color: isPeak
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          fontWeight: isPeak
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Container(
                        height: barHeight < 4 ? 4 : barHeight,
                        decoration: BoxDecoration(
                          color: isPeak
                              ? AppColors.primary
                              : AppColors.primaryLight.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppDimensions.radiusS),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        hour.label,
                        style: TextStyle(
                          fontSize: 9,
                          color: isPeak
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          fontWeight: isPeak
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _MoodShiftSection extends StatelessWidget {
  final MoodShiftEntity moodShift;

  const _MoodShiftSection({required this.moodShift});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          children: [
            _MoodShiftRow(
              label: 'Mood Membaik',
              value: moodShift.improvedRate,
              color: AppColors.success,
              icon: Icons.trending_up,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MoodShiftRow(
              label: 'Mood Memburuk',
              value: moodShift.worsenedRate,
              color: AppColors.error,
              icon: Icons.trending_down,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const Divider(color: AppColors.divider),
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.warning,
                  size: AppDimensions.iconM,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  '${AppStrings.satisfactionScore}: ${moodShift.satisfactionScore.toStringAsFixed(1)} / 10',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodShiftRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _MoodShiftRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppDimensions.iconM),
        const SizedBox(width: AppDimensions.spacingS),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _PercentageBadge extends StatelessWidget {
  final double percentage;

  const _PercentageBadge({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
      ),
      child: Text(
        '${percentage.toStringAsFixed(1)}%',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingM),
        child: Center(
          child: Text(
            AppStrings.noData,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.iconXl,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                minimumSize: const Size(
                  double.infinity,
                  AppDimensions.buttonHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
