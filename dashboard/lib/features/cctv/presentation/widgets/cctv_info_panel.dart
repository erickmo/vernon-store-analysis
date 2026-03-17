import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/cctv_entity.dart';

/// Widget untuk menampilkan informasi detail kamera.
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
      color: AppColors.primaryDark,
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacingM),
          _buildLocation(context),
          if (cctv.description != null && cctv.description!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingS),
            _buildDescription(context),
          ],
          const SizedBox(height: AppDimensions.spacingM),
          _buildInfoRow(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          cctv.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: AppDimensions.spacingM),
      _buildStatusBadge(context),
    ],
  );

  Widget _buildStatusBadge(BuildContext context) {
    final (statusText, statusColor) = switch (cctv.status) {
      CCTVStatus.online => ('Online', AppColors.success),
      CCTVStatus.offline => ('Offline', AppColors.error),
      CCTVStatus.alert => ('Alert', AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildLocation(BuildContext context) => Row(
    children: [
      const Icon(
        Icons.location_on,
        color: AppColors.accentLight,
        size: AppDimensions.iconS,
      ),
      const SizedBox(width: AppDimensions.spacingS),
      Expanded(
        child: Text(
          cctv.locationZone,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.accentLight,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _buildDescription(BuildContext context) => Text(
    cctv.description!,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );

  Widget _buildInfoRow(BuildContext context) => Wrap(
    spacing: AppDimensions.spacingS,
    runSpacing: AppDimensions.spacingS,
    children: [
      _buildInfoChip(context, 'Kamera ID', '${cctv.id}'),
      _buildInfoChip(context, 'Toko ID', '${cctv.storeId}'),
      _buildInfoChip(context, 'Status', cctv.isActive ? 'Aktif' : 'Tidak Aktif'),
    ],
  );

  Widget _buildInfoChip(BuildContext context, String label, String value) =>
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingS,
          vertical: AppDimensions.spacingXs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.accentLight,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
}
