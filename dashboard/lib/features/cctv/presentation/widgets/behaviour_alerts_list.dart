import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/behaviour_alert_entity.dart';
import '../cubit/streaming_cubit.dart';

/// Widget untuk menampilkan list behaviour/shoplifting alerts.
class BehaviourAlertsList extends StatefulWidget {
  /// List dari behaviour alerts yang ditampilkan.
  final List<BehaviourAlertEntity> alerts;

  /// Cubit untuk handle dismiss action.
  final StreamingCubit cubit;

  const BehaviourAlertsList({
    super.key,
    required this.alerts,
    required this.cubit,
  });

  @override
  State<BehaviourAlertsList> createState() => _BehaviourAlertsListState();
}

class _BehaviourAlertsListState extends State<BehaviourAlertsList> {
  late List<BehaviourAlertEntity> _displayedAlerts;

  @override
  void initState() {
    super.initState();
    _displayedAlerts = List.from(widget.alerts);
  }

  @override
  void didUpdateWidget(BehaviourAlertsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alerts != widget.alerts) {
      setState(() {
        _displayedAlerts = List.from(widget.alerts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        const SizedBox(height: AppDimensions.spacingM),
        if (_displayedAlerts.isEmpty)
          _buildEmptyState(context)
        else
          _buildAlertsList(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
    child: Row(
      children: [
        const Icon(
          Icons.warning_rounded,
          color: AppColors.warning,
          size: AppDimensions.iconM,
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(
          AppStrings.alerts,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Text(
          '${_displayedAlerts.length}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      vertical: AppDimensions.spacingL,
      horizontal: AppDimensions.spacingM,
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
            size: AppDimensions.iconXl,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            AppStrings.noData,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    ),
  );

  Widget _buildAlertsList(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: 300),
    child: ListView.builder(
      shrinkWrap: true,
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      itemCount: _displayedAlerts.length,
      itemBuilder: (context, index) =>
          _buildAlertItem(context, _displayedAlerts[index], index),
    ),
  );

  Widget _buildAlertItem(
    BuildContext context,
    BehaviourAlertEntity alert,
    int index,
  ) {
    final confidenceColor = _getConfidenceColor(alert.confidence);
    final confidencePercent = (alert.confidence * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Card(
        color: AppColors.primaryDark,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${AppStrings.shopliftingAlert} #${alert.id}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.surface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingS),
                            _buildConfidenceBadge(
                              context,
                              confidencePercent,
                              confidenceColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          'Kamera ${alert.cameraId}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _displayedAlerts.removeAt(index);
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: AppColors.onSurfaceVariant,
                      size: AppDimensions.iconS,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                _formatTimestamp(alert.timestamp),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(
    BuildContext context,
    String confidencePercent,
    Color color,
  ) =>
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingS,
          vertical: AppDimensions.spacingXs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color, width: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Text(
          '$confidencePercent%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      );

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.alertHigh;
    if (confidence >= 0.6) return AppColors.alertMedium;
    return AppColors.alertLow;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m lalu';
    if (difference.inHours < 24) return '${difference.inHours}j lalu';

    return '${timestamp.day.toString().padLeft(2, '0')}/'
        '${timestamp.month.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
