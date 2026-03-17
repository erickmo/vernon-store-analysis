import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/analytics_dashboard_entity.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';
import '../widgets/gender_chart_card.dart';
import '../widgets/kpi_summary_card.dart';
import '../widgets/mood_chart_card.dart';

/// Halaman utama dashboard analitik.
class AnalyticsDashboardPage extends StatefulWidget {
  final int storeId;

  const AnalyticsDashboardPage({super.key, required this.storeId});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsCubit>().loadDashboard(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.analyticsDashboard),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AnalyticsCubit>().loadDashboard(widget.storeId),
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          return switch (state) {
            AnalyticsInitial() => const _EmptyBody(),
            AnalyticsLoading() => const _LoadingBody(),
            AnalyticsError(:final message) => _ErrorBody(
                message: message,
                onRetry: () =>
                    context.read<AnalyticsCubit>().loadDashboard(widget.storeId),
              ),
            AnalyticsLoaded(:final dashboard) => _LoadedBody(dashboard: dashboard),
          };
        },
      ),
    );
  }
}

// ── Loading / empty / error ────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.noData,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: AppDimensions.iconXl, color: AppColors.error),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loaded body ───────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  final AnalyticsDashboardEntity dashboard;

  const _LoadedBody({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<AnalyticsCubit>().loadDashboard(dashboard.storeId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeriodHeader(dashboard: dashboard),
            const SizedBox(height: AppDimensions.spacingM),
            _KpiGrid(dashboard: dashboard),
            const SizedBox(height: AppDimensions.spacingM),
            GenderChartCard(gender: dashboard.gender),
            const SizedBox(height: AppDimensions.spacingM),
            _AgeGroupCard(ageGroups: dashboard.ageGroups),
            const SizedBox(height: AppDimensions.spacingM),
            MoodChartCard(mood: dashboard.mood),
            const SizedBox(height: AppDimensions.spacingM),
            _DwellTimeCard(
              dwellTime: dashboard.dwellTime,
              distribution: dashboard.dwellDistribution,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            _HourlyTrafficCard(hourlyTraffic: dashboard.hourlyTraffic),
            const SizedBox(height: AppDimensions.spacingXl),
          ],
        ),
      ),
    );
  }
}

// ── Period header ─────────────────────────────────────────────────────────────

class _PeriodHeader extends StatelessWidget {
  final AnalyticsDashboardEntity dashboard;

  const _PeriodHeader({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'id_ID');
    final periodText =
        '${fmt.format(dashboard.periodStart)} – ${fmt.format(dashboard.periodEnd)}';

    return Row(
      children: [
        const Icon(Icons.date_range,
            size: AppDimensions.iconM, color: AppColors.onSurfaceVariant),
        const SizedBox(width: AppDimensions.spacingXs),
        Text(
          periodText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

// ── KPI grid ──────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final AnalyticsDashboardEntity dashboard;

  const _KpiGrid({required this.dashboard});

  GenderItem? _findGender(String key) {
    try {
      return dashboard.gender.firstWhere((g) => g.gender == key);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = dashboard.summary;
    final male = _findGender('male');
    final female = _findGender('female');

    final items = [
      (
        icon: Icons.people,
        label: AppStrings.totalVisitors,
        value: summary.totalVisitors.toString(),
        subtitle: null,
        color: AppColors.primary,
      ),
      (
        icon: Icons.timer_outlined,
        label: AppStrings.avgDwellTime,
        value: '${summary.avgDwellMinutes.toStringAsFixed(1)} mnt',
        subtitle: null,
        color: AppColors.chartTeal,
      ),
      (
        icon: Icons.male,
        label: 'Pengunjung Pria',
        value: male?.count.toString() ?? '-',
        subtitle: male != null
            ? '${male.percentage.toStringAsFixed(1)}%'
            : null,
        color: AppColors.chartBlue,
      ),
      (
        icon: Icons.female,
        label: 'Pengunjung Wanita',
        value: female?.count.toString() ?? '-',
        subtitle: female != null
            ? '${female.percentage.toStringAsFixed(1)}%'
            : null,
        color: AppColors.chartPink,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 600 ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            mainAxisSpacing: AppDimensions.spacingM,
            crossAxisSpacing: AppDimensions.spacingM,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return KpiSummaryCard(
              icon: item.icon,
              label: item.label,
              value: item.value,
              subtitle: item.subtitle,
              iconColor: item.color,
            );
          },
        );
      },
    );
  }
}

// ── Age group card ────────────────────────────────────────────────────────────

class _AgeGroupCard extends StatelessWidget {
  final List<AgeGroupItem> ageGroups;

  const _AgeGroupCard({required this.ageGroups});

  static const _colorMap = {
    0: AppColors.chartPurple,
    1: AppColors.chartBlue,
    2: AppColors.chartTeal,
    3: AppColors.chartOrange,
    4: AppColors.chartPink,
  };

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
              AppStrings.ageDistribution,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ...ageGroups.asMap().entries.map(
              (entry) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.spacingS),
                child: _AgeBar(
                  label: entry.value.ageGroup,
                  count: entry.value.count,
                  percentage: entry.value.percentage,
                  color: _colorMap[entry.key % _colorMap.length] ??
                      AppColors.chartBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeBar extends StatelessWidget {
  final String label;
  final int count;
  final double percentage;
  final Color color;

  const _AgeBar({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Expanded(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusCircle),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              minHeight: 10,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        SizedBox(
          width: 80,
          child: Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            textAlign: TextAlign.right,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dwell time card ───────────────────────────────────────────────────────────

class _DwellTimeCard extends StatelessWidget {
  final DwellTimeData dwellTime;
  final List<DwellBucket> distribution;

  const _DwellTimeCard({
    required this.dwellTime,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final maxCount = distribution.isEmpty
        ? 1
        : distribution.map((b) => b.count).reduce((a, b) => a > b ? a : b);

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
              AppStrings.dwellTimeDistribution,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                _DwellStatChip(
                  label: 'Rata-rata',
                  value: '${dwellTime.avgDwellMinutes.toStringAsFixed(1)} mnt',
                ),
                const SizedBox(width: AppDimensions.spacingM),
                _DwellStatChip(
                  label: 'Total Kunjungan',
                  value: '${dwellTime.totalVisits}',
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ...distribution.map(
              (b) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.spacingS),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        b.bucket,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusCircle),
                        child: LinearProgressIndicator(
                          value: maxCount > 0 ? b.count / maxCount : 0,
                          minHeight: 10,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${b.count}',
                        textAlign: TextAlign.right,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DwellStatChip extends StatelessWidget {
  final String label;
  final String value;

  const _DwellStatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hourly traffic card ───────────────────────────────────────────────────────

class _HourlyTrafficCard extends StatelessWidget {
  final List<HourlyTrafficPoint> hourlyTraffic;

  const _HourlyTrafficCard({required this.hourlyTraffic});

  String _formatHour(String hour) {
    try {
      final dt = DateTime.parse(hour);
      return '${dt.hour.toString().padLeft(2, '0')}';
    } catch (_) {
      return hour;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (hourlyTraffic.isEmpty) return const SizedBox.shrink();

    final maxCount = hourlyTraffic
        .map((p) => p.visitorCount)
        .reduce((a, b) => a > b ? a : b);

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
              AppStrings.hourlyTraffic,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SizedBox(
              height: AppDimensions.chartHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const barSpacing = 4.0;
                  final barWidth =
                      (constraints.maxWidth - barSpacing * hourlyTraffic.length) /
                          hourlyTraffic.length;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: hourlyTraffic.map((point) {
                      final ratio =
                          maxCount > 0 ? point.visitorCount / maxCount : 0.0;
                      return Padding(
                        padding:
                            const EdgeInsets.only(right: barSpacing),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              point.visitorCount.toString(),
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: barWidth,
                              height: (constraints.maxHeight - 36) * ratio,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppDimensions.radiusS),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatHour(point.hour),
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Center(
              child: Text(
                'Jam (00–23)',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
