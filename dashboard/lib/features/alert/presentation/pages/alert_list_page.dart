import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/alert_entity.dart';
import '../cubit/alert_cubit.dart';
import '../cubit/alert_state.dart';

/// Halaman daftar shoplifting alert.
class AlertListPage extends StatefulWidget {
  final int storeId;

  const AlertListPage({super.key, required this.storeId});

  @override
  State<AlertListPage> createState() => _AlertListPageState();
}

class _AlertListPageState extends State<AlertListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AlertCubit>().loadAlerts(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text(AppStrings.alertList),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.refresh,
            onPressed: () =>
                context.read<AlertCubit>().loadAlerts(widget.storeId),
          ),
        ],
      ),
      body: BlocBuilder<AlertCubit, AlertState>(
        builder: (context, state) {
          return switch (state) {
            AlertInitial() => const SizedBox.shrink(),
            AlertLoading() => const Center(child: CircularProgressIndicator()),
            AlertResolving() => const Center(child: CircularProgressIndicator()),
            AlertResolved() => const Center(child: CircularProgressIndicator()),
            AlertError(:final message) => _ErrorView(
              message: message,
              onRetry: () =>
                  context.read<AlertCubit>().loadAlerts(widget.storeId),
            ),
            AlertLoaded(:final alerts) => alerts.isEmpty
                ? const _EmptyView()
                : _AlertListView(
                    alerts: alerts,
                    storeId: widget.storeId,
                  ),
          };
        },
      ),
    );
  }
}

class _AlertListView extends StatelessWidget {
  final List<AlertEntity> alerts;
  final int storeId;

  const _AlertListView({required this.alerts, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      itemCount: alerts.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spacingS),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _AlertCard(alert: alert, storeId: storeId);
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertEntity alert;
  final int storeId;

  const _AlertCard({required this.alert, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (alert.confidence * 100).toStringAsFixed(0);
    final confidenceColor = alert.confidence >= 0.8
        ? AppColors.alertHigh
        : alert.confidence >= 0.6
            ? AppColors.alertMedium
            : AppColors.alertLow;

    return Card(
      color: AppColors.surface,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        side: BorderSide(
          color: alert.resolved ? AppColors.divider : confidenceColor,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: alert.resolved
                      ? AppColors.onSurfaceVariant
                      : confidenceColor,
                  size: AppDimensions.iconM,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Text(
                    AppStrings.shopliftingAlert,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: alert.resolved
                              ? AppColors.onSurfaceVariant
                              : AppColors.onSurface,
                        ),
                  ),
                ),
                _StatusBadge(resolved: alert.resolved),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _InfoRow(
              label: AppStrings.confidence,
              value: '$confidencePercent%',
              valueColor: confidenceColor,
            ),
            _InfoRow(
              label: 'Kamera ID',
              value: alert.cameraId.toString(),
            ),
            _InfoRow(
              label: 'Waktu',
              value: _formatDateTime(alert.timestamp),
            ),
            if (alert.snapshotPath != null)
              _InfoRow(
                label: AppStrings.snapshot,
                value: alert.snapshotPath!,
              ),
            if (alert.resolved && alert.resolvedNote != null) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Text(
                  alert.resolvedNote!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
            if (!alert.resolved) ...[
              const SizedBox(height: AppDimensions.spacingM),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showResolveDialog(context, alert, storeId),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(AppStrings.resolve),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.surface,
                    minimumSize: const Size(0, AppDimensions.buttonHeightS),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showResolveDialog(
    BuildContext context,
    AlertEntity alert,
    int storeId,
  ) {
    final noteController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.resolveAlert),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: AppStrings.resolveNote,
            hintText: 'Masukkan catatan penyelesaian...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final note = noteController.text.trim();
              if (note.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                context
                    .read<AlertCubit>()
                    .resolveAlert(storeId, alert.id, note);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.surface,
            ),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final bool resolved;

  const _StatusBadge({required this.resolved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: resolved ? AppColors.success : AppColors.alertHigh,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
      ),
      child: Text(
        resolved ? AppStrings.alertResolved : AppStrings.alertUnresolved,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: valueColor ?? AppColors.onSurface,
                    fontWeight: valueColor != null ? FontWeight.bold : null,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: AppDimensions.iconXl,
            color: AppColors.success,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            AppStrings.noData,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
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
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppDimensions.iconXl,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
              style: ElevatedButton.styleFrom(
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
