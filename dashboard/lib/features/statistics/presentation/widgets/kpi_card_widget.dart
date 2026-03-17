import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Widget kartu KPI yang menampilkan satu metrik utama dengan ikon dan label.
class KpiCardWidget extends StatelessWidget {
  /// Label metrik yang ditampilkan.
  final String label;

  /// Nilai metrik dalam bentuk string yang sudah diformat.
  final String value;

  /// Ikon yang mewakili metrik.
  final IconData icon;

  /// Warna aksen kartu. Default menggunakan [AppColors.primary].
  final Color? accentColor;

  /// Subtitle atau keterangan tambahan di bawah nilai.
  final String? subtitle;

  const KpiCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: AppDimensions.iconXl,
                  height: AppDimensions.iconXl,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Icon(icon, color: color, size: AppDimensions.iconM),
                ),
                const Spacer(),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingS,
                      vertical: AppDimensions.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCircle,
                      ),
                    ),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: color,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
