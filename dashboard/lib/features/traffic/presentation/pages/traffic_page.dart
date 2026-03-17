import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/traffic_entity.dart';
import '../cubit/traffic_cubit.dart';
import '../cubit/traffic_state.dart';

/// Halaman ringkasan traffic dan data realtime.
class TrafficPage extends StatefulWidget {
  final int storeId;

  const TrafficPage({super.key, required this.storeId});

  @override
  State<TrafficPage> createState() => _TrafficPageState();
}

class _TrafficPageState extends State<TrafficPage> {
  @override
  void initState() {
    super.initState();
    context.read<TrafficCubit>().loadTraffic(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.traffic),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<TrafficCubit>().loadTraffic(widget.storeId),
          ),
        ],
      ),
      body: BlocBuilder<TrafficCubit, TrafficState>(
        builder: (context, state) {
          return switch (state) {
            TrafficInitial() => const _EmptyBody(),
            TrafficLoading() => const _LoadingBody(),
            TrafficError(:final message) => _ErrorBody(
                message: message,
                onRetry: () =>
                    context.read<TrafficCubit>().loadTraffic(widget.storeId),
              ),
            TrafficLoaded(:final summary, :final realtime) => _LoadedBody(
                storeId: widget.storeId,
                summary: summary,
                realtime: realtime,
              ),
            TrafficRealtimeRefreshing(:final summary, :final previousRealtime) =>
              _LoadedBody(
                storeId: widget.storeId,
                summary: summary,
                realtime: previousRealtime,
                isRealtimeRefreshing: true,
              ),
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
  final int storeId;
  final TrafficSummaryEntity summary;
  final RealtimeTrafficEntity? realtime;
  final bool isRealtimeRefreshing;

  const _LoadedBody({
    required this.storeId,
    required this.summary,
    this.realtime,
    this.isRealtimeRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<TrafficCubit>().loadTraffic(storeId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RealtimeCard(
              realtime: realtime,
              isRefreshing: isRealtimeRefreshing,
              onRefresh: () =>
                  context.read<TrafficCubit>().refreshRealtime(storeId),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            _SummaryCard(summary: summary),
            const SizedBox(height: AppDimensions.spacingM),
            _SnapshotListCard(snapshots: summary.snapshots),
            const SizedBox(height: AppDimensions.spacingXl),
          ],
        ),
      ),
    );
  }
}

// ── Realtime card ─────────────────────────────────────────────────────────────

class _RealtimeCard extends StatelessWidget {
  final RealtimeTrafficEntity? realtime;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const _RealtimeCard({
    required this.realtime,
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = realtime?.currentVisitorCount;
    final timestamp = realtime?.timestamp;
    final fmt = DateFormat('HH:mm:ss', 'id_ID');

    return Card(
      elevation: AppDimensions.cardElevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.currentVisitors,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.surface.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.refresh,
                  icon: isRefreshing
                      ? const SizedBox(
                          width: AppDimensions.iconM,
                          height: AppDimensions.iconM,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : const Icon(Icons.refresh, color: AppColors.surface),
                  onPressed: isRefreshing ? null : onRefresh,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              count != null ? '$count' : '—',
              style: textTheme.displayMedium?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: AppDimensions.iconS,
                    color: AppColors.accentLight,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Text(
                    'Diperbarui ${fmt.format(timestamp.toLocal())}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.accentLight,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final TrafficSummaryEntity summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fmt = DateFormat('dd MMM yyyy', 'id_ID');
    final avgDwellMin =
        (summary.avgDwellSeconds / 60.0).toStringAsFixed(1);

    final periodText =
        '${fmt.format(summary.periodStart)} – ${fmt.format(summary.periodEnd)}';

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
              AppStrings.trafficSummary,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Row(
              children: [
                const Icon(Icons.date_range,
                    size: AppDimensions.iconS,
                    color: AppColors.onSurfaceVariant),
                const SizedBox(width: AppDimensions.spacingXs),
                Text(
                  periodText,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const Divider(color: AppColors.divider, thickness: AppDimensions.dividerThickness),
            const SizedBox(height: AppDimensions.spacingM),
            _StatRow(
              icon: Icons.people,
              iconColor: AppColors.primary,
              label: AppStrings.totalVisitors,
              value: '${summary.totalVisitors}',
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _StatRow(
              icon: Icons.timer_outlined,
              iconColor: AppColors.chartTeal,
              label: AppStrings.avgDwellTime,
              value: '$avgDwellMin mnt',
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _StatRow(
              icon: Icons.trending_up,
              iconColor: AppColors.warning,
              label: AppStrings.peakVisitors,
              value: '${summary.peakVisitorCount}',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingXs),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, size: AppDimensions.iconS, color: iconColor),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

// ── Snapshot list ─────────────────────────────────────────────────────────────

class _SnapshotListCard extends StatelessWidget {
  final List<TrafficSnapshotEntity> snapshots;

  const _SnapshotListCard({required this.snapshots});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (snapshots.isEmpty) {
      return Card(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Center(
            child: Text(
              AppStrings.noData,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

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
              'Riwayat Snapshot',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshots.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.divider,
                thickness: AppDimensions.dividerThickness,
                height: AppDimensions.spacingM,
              ),
              itemBuilder: (context, index) {
                return _SnapshotTile(snapshot: snapshots[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  final TrafficSnapshotEntity snapshot;

  const _SnapshotTile({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fmt = DateFormat('dd MMM HH:mm', 'id_ID');
    final avgDwellMin = (snapshot.avgDwellSeconds / 60.0).toStringAsFixed(1);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingXs),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: const Icon(
            Icons.timeline,
            size: AppDimensions.iconS,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fmt.format(snapshot.timestamp.toLocal()),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Dwell avg $avgDwellMin mnt · Puncak ${snapshot.peakCount}',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${snapshot.visitorCount}',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Text(
          'org',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
