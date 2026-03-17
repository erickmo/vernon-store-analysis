import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/behaviour_alert_entity.dart';
import '../cubit/streaming_cubit.dart';

/// Widget untuk menampilkan list behaviour alerts dengan dismiss capability.
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
        _buildHeader(),
        const SizedBox(height: AppDimensions.spacingM),
        if (_displayedAlerts.isEmpty)
          _buildEmptyState()
        else
          _buildAlertsList(),
      ],
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
    child: Row(
      children: [
        const Icon(
          Icons.warning_rounded,
          color: Colors.orange,
          size: 20,
        ),
        const SizedBox(width: AppDimensions.spacingS),
        const Text(
          'Recent Alerts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          '${_displayedAlerts.length}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => Padding(
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
            color: AppColors.textSecondary.withOpacity(0.5),
            size: 40,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          const Text(
            'No alerts detected',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildAlertsList() => ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: 300),
    child: ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      itemCount: _displayedAlerts.length,
      itemBuilder: (context, index) =>
          _buildAlertItem(_displayedAlerts[index], index),
    ),
  );

  Widget _buildAlertItem(BehaviourAlertEntity alert, int index) {
    final confidenceColor = _getConfidenceColor(alert.confidence);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Card(
        color: AppColors.cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert type and confidence
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatAlertType(alert.type),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingS),
                            _buildConfidenceBadge(alert.confidence, confidenceColor),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingS),
                        Text(
                          alert.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  // Dismiss button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _displayedAlerts.removeAt(index);
                      });
                      widget.cubit.dismissAlert();
                    },
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),
              // Timestamp
              Text(
                _formatTimestamp(alert.timestamp),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence, Color color) {
    final confidencePercent = (confidence * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$confidencePercent%',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.red;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.yellow;
  }

  String _formatAlertType(BehaviourType type) {
    return type.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }
}
