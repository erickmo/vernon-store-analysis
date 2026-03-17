import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/cctv_entity.dart';

/// Widget untuk menampilkan informasi detail CCTV.
class CCTVInfoPanel extends StatelessWidget {
  /// CCTV entity yang ditampilkan.
  final CCTVEntity cctv;

  const CCTVInfoPanel({
    super.key,
    required this.cctv,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.spacingM),
          _buildLocation(),
          const SizedBox(height: AppDimensions.spacingM),
          _buildSpecsRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cctv.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      const SizedBox(width: AppDimensions.spacingM),
      _buildStatusBadge(),
    ],
  );

  Widget _buildStatusBadge() {
    final (statusText, statusColor) = switch (cctv.status) {
      CCTVStatus.online => ('Online', Colors.green),
      CCTVStatus.offline => ('Offline', Colors.red),
      CCTVStatus.alert => ('Alert', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLocation() => Row(
    children: [
      const Icon(
        Icons.location_on,
        color: AppColors.textSecondary,
        size: 16,
      ),
      const SizedBox(width: AppDimensions.spacingS),
      Expanded(
        child: Text(
          cctv.location,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _buildSpecsRow() => Wrap(
    spacing: AppDimensions.spacingS,
    runSpacing: AppDimensions.spacingS,
    children: [
      _buildSpecChip('Resolution', '${cctv.resolution.toInt()}p'),
      _buildSpecChip('FPS', '${cctv.fps}'),
      _buildSpecChip('Bitrate', cctv.bitrate),
    ],
  );

  Widget _buildSpecChip(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingS,
      vertical: 4,
    ),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: AppColors.primary.withOpacity(0.3),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
