import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/store_entity.dart';
import '../cubit/store_cubit.dart';
import '../cubit/store_state.dart';

/// Halaman yang menampilkan daftar semua toko Vernon Store.
///
/// Menampilkan loading indicator, pesan error dengan tombol retry,
/// pesan empty state, dan daftar toko dalam bentuk card grid.
class StoreListPage extends StatefulWidget {
  /// Route name untuk navigasi.
  static const String routeName = '/stores';

  const StoreListPage({super.key});

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  @override
  void initState() {
    super.initState();
    context.read<StoreCubit>().loadStores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.storeList),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: AppDimensions.cardElevation,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppStrings.refresh,
            onPressed: () => context.read<StoreCubit>().loadStores(),
          ),
        ],
      ),
      body: BlocBuilder<StoreCubit, StoreState>(
        builder: (context, state) {
          if (state is StoreLoading) {
            return _buildLoadingState();
          }
          if (state is StoreError) {
            return _buildErrorState(state.message);
          }
          if (state is StoreLoaded) {
            if (state.stores.isEmpty) {
              return _buildEmptyState();
            }
            return _buildStoreList(state.stores);
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  /// Widget loading state dengan centered indicator.
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppDimensions.spacingM),
          Text(
            AppStrings.loading,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /// Widget error state dengan pesan dan tombol retry.
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: AppDimensions.iconXl,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            ElevatedButton.icon(
              onPressed: () => context.read<StoreCubit>().loadStores(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(AppStrings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingL,
                  vertical: AppDimensions.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget empty state ketika tidak ada toko.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.store_outlined,
            size: AppDimensions.iconXl,
            color: AppColors.onSurfaceVariant,
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

  /// Widget daftar toko dalam bentuk grid responsive.
  Widget _buildStoreList(List<StoreEntity> stores) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
                ? 2
                : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppDimensions.spacingM,
            mainAxisSpacing: AppDimensions.spacingM,
            childAspectRatio: 1.6,
          ),
          itemCount: stores.length,
          itemBuilder: (context, index) => _StoreCard(store: stores[index]),
        );
      },
    );
  }
}

/// Card widget untuk menampilkan ringkasan satu toko.
class _StoreCard extends StatelessWidget {
  final StoreEntity store;

  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(),
            const SizedBox(height: AppDimensions.spacingS),
            const Divider(thickness: AppDimensions.dividerThickness),
            const SizedBox(height: AppDimensions.spacingS),
            _buildLocationRow(),
            const SizedBox(height: AppDimensions.spacingXs),
            _buildTimezoneRow(),
            if (store.description != null &&
                store.description!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              _buildDescriptionRow(),
            ],
          ],
        ),
      ),
    );
  }

  /// Header card berisi nama toko dan badge status.
  Widget _buildCardHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            store.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        _StatusBadge(isActive: store.isActive),
      ],
    );
  }

  /// Row yang menampilkan lokasi toko.
  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: AppDimensions.iconS,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Expanded(
          child: Text(
            store.location,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Row yang menampilkan timezone toko.
  Widget _buildTimezoneRow() {
    return Row(
      children: [
        const Icon(
          Icons.schedule_outlined,
          size: AppDimensions.iconS,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Text(
          store.timezone,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Row yang menampilkan deskripsi toko (opsional).
  Widget _buildDescriptionRow() {
    return Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: AppDimensions.iconS,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Expanded(
          child: Text(
            store.description!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Badge kecil yang menampilkan status aktif/tidak aktif toko.
class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.onSurfaceVariant.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Text(
            isActive ? AppStrings.storeActive : AppStrings.storeInactive,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  isActive ? AppColors.success : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
