import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/mood_log_entity.dart';
import '../../domain/entities/visit_entity.dart';
import '../../domain/entities/visitor_entity.dart';
import '../cubit/visitor_detail_cubit.dart';
import '../cubit/visitor_detail_state.dart';

/// Halaman detail visitor yang menampilkan info, riwayat kunjungan,
/// dan mood timeline.
class VisitorDetailPage extends StatefulWidget {
  /// ID visitor yang akan ditampilkan detailnya.
  final int visitorId;

  const VisitorDetailPage({super.key, required this.visitorId});

  @override
  State<VisitorDetailPage> createState() => _VisitorDetailPageState();
}

class _VisitorDetailPageState extends State<VisitorDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<VisitorDetailCubit>().loadVisitorDetail(widget.visitorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text(AppStrings.visitorDetail),
        elevation: AppDimensions.cardElevation,
      ),
      body: BlocBuilder<VisitorDetailCubit, VisitorDetailState>(
        builder: (context, state) {
          return switch (state) {
            VisitorDetailInitial() => const SizedBox.shrink(),
            VisitorDetailLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            VisitorDetailLoaded() => _VisitorDetailContent(state: state),
            VisitorDetailError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context
                  .read<VisitorDetailCubit>()
                  .loadVisitorDetail(widget.visitorId),
            ),
          };
        },
      ),
    );
  }
}

class _VisitorDetailContent extends StatelessWidget {
  final VisitorDetailLoaded state;

  const _VisitorDetailContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VisitorInfoCard(visitor: state.visitor),
          const SizedBox(height: AppDimensions.spacingM),
          _VisitHistorySection(
            visits: state.visits,
            selectedVisitId: state.selectedVisitId,
          ),
          if (state.selectedVisitId != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            _MoodTimelineSection(
              isLoading: state.isMoodTimelineLoading,
              moodTimeline: state.moodTimeline,
              errorMessage: state.moodTimelineError,
            ),
          ],
        ],
      ),
    );
  }
}

class _VisitorInfoCard extends StatelessWidget {
  final VisitorEntity visitor;

  const _VisitorInfoCard({required this.visitor});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: AppDimensions.avatarRadiusL,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    visitor.personUid.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (visitor.label != null)
                        Text(
                          visitor.label!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.onSurface,
                          ),
                        ),
                      Text(
                        visitor.personUid,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusCircle,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${visitor.totalVisits}',
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        AppStrings.totalVisits,
                        style: TextStyle(
                          color: AppColors.accentLight,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const Divider(color: AppColors.divider),
            const SizedBox(height: AppDimensions.spacingS),
            _InfoRow(
              icon: Icons.calendar_today,
              label: AppStrings.firstSeen,
              value: dateFormat.format(visitor.firstSeenAt.toLocal()),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _InfoRow(
              icon: Icons.update,
              label: AppStrings.lastSeen,
              value: dateFormat.format(visitor.lastSeenAt.toLocal()),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconM, color: AppColors.primary),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _VisitHistorySection extends StatelessWidget {
  final List<VisitEntity> visits;
  final int? selectedVisitId;

  const _VisitHistorySection({
    required this.visits,
    required this.selectedVisitId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.visitHistory,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        if (visits.isEmpty)
          Card(
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
          )
        else
          ...visits.map(
            (visit) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
              child: _VisitCard(
                visit: visit,
                isSelected: visit.id == selectedVisitId,
              ),
            ),
          ),
      ],
    );
  }
}

class _VisitCard extends StatelessWidget {
  final VisitEntity visit;
  final bool isSelected;

  const _VisitCard({required this.visit, required this.isSelected});

  String _formatDwell(int seconds) {
    if (seconds < 60) return '$seconds detik';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes menit';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}j ${remainingMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Card(
      elevation: isSelected ? AppDimensions.cardElevationHigh : AppDimensions.cardElevation,
      color: isSelected ? AppColors.primary : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        side: isSelected
            ? BorderSide.none
            : const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        onTap: () {
          context
              .read<VisitorDetailCubit>()
              .selectVisitAndLoadMoodTimeline(visit.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Row(
            children: [
              Icon(
                Icons.store,
                color: isSelected ? AppColors.accentLight : AppColors.primary,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(visit.entryAt.toLocal()),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.surface
                            : AppColors.onSurface,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      _formatDwell(visit.dwellSeconds),
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.accentLight
                            : AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: AppDimensions.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentDark
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusCircle,
                  ),
                ),
                child: Text(
                  AppStrings.moodTimeline,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodTimelineSection extends StatelessWidget {
  final bool isLoading;
  final List<MoodLogEntity>? moodTimeline;
  final String? errorMessage;

  const _MoodTimelineSection({
    required this.isLoading,
    required this.moodTimeline,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.moodTimeline,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacingL),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (errorMessage != null)
          Card(
            elevation: AppDimensions.cardElevation,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (moodTimeline == null || moodTimeline!.isEmpty)
          Card(
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
          )
        else
          Card(
            elevation: AppDimensions.cardElevation,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingS,
              ),
              itemCount: moodTimeline!.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.divider,
                height: 1,
                indent: AppDimensions.spacingXl,
              ),
              itemBuilder: (context, index) {
                return _MoodLogTile(log: moodTimeline![index]);
              },
            ),
          ),
      ],
    );
  }
}

class _MoodLogTile extends StatelessWidget {
  final MoodLogEntity log;

  const _MoodLogTile({required this.log});

  Color _moodColor(String mood) {
    return switch (mood.toLowerCase()) {
      'happy' => AppColors.success,
      'sad' => AppColors.info,
      'angry' => AppColors.error,
      'neutral' => AppColors.onSurfaceVariant,
      _ => AppColors.chartPurple,
    };
  }

  IconData _moodIcon(String mood) {
    return switch (mood.toLowerCase()) {
      'happy' => Icons.sentiment_very_satisfied,
      'sad' => Icons.sentiment_dissatisfied,
      'angry' => Icons.sentiment_very_dissatisfied,
      'neutral' => Icons.sentiment_neutral,
      _ => Icons.face,
    };
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm:ss');
    final color = _moodColor(log.mood);
    final confidencePct = (log.confidence * 100).toStringAsFixed(1);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(_moodIcon(log.mood), color: color, size: AppDimensions.iconM),
      ),
      title: Text(
        log.mood.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        timeFormat.format(log.timestamp.toLocal()),
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '$confidencePct%',
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
