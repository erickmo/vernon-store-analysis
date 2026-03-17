import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/visitor_entity.dart';
import '../cubit/visitor_cubit.dart';
import '../cubit/visitor_state.dart';
import 'visitor_detail_page.dart';

/// Halaman yang menampilkan daftar visitor suatu toko.
class VisitorListPage extends StatefulWidget {
  /// ID toko yang akan ditampilkan daftar visitornya.
  final int storeId;

  const VisitorListPage({super.key, required this.storeId});

  @override
  State<VisitorListPage> createState() => _VisitorListPageState();
}

class _VisitorListPageState extends State<VisitorListPage> {
  @override
  void initState() {
    super.initState();
    context.read<VisitorCubit>().loadVisitors(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text(AppStrings.visitorList),
        elevation: AppDimensions.cardElevation,
        actions: [
          IconButton(
            onPressed: () {
              context.read<VisitorCubit>().loadVisitors(widget.storeId);
            },
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.refresh,
          ),
        ],
      ),
      body: BlocBuilder<VisitorCubit, VisitorState>(
        builder: (context, state) {
          return switch (state) {
            VisitorInitial() => const SizedBox.shrink(),
            VisitorLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            VisitorLoaded(:final visitors) => visitors.isEmpty
                ? _EmptyVisitorView()
                : _VisitorListView(visitors: visitors),
            VisitorError(:final message) => _ErrorView(
              message: message,
              onRetry: () =>
                  context.read<VisitorCubit>().loadVisitors(widget.storeId),
            ),
          };
        },
      ),
    );
  }
}

class _VisitorListView extends StatelessWidget {
  final List<VisitorEntity> visitors;

  const _VisitorListView({required this.visitors});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      itemCount: visitors.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spacingS),
      itemBuilder: (context, index) {
        return _VisitorCard(visitor: visitors[index]);
      },
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final VisitorEntity visitor;

  const _VisitorCard({required this.visitor});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: context.read<VisitorCubit>(),
                child: VisitorDetailPage(visitorId: visitor.id),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Row(
            children: [
              CircleAvatar(
                radius: AppDimensions.avatarRadiusL,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  visitor.personUid.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            visitor.label ?? visitor.personUid,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (visitor.label != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingS,
                              vertical: AppDimensions.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusCircle,
                              ),
                            ),
                            child: Text(
                              visitor.label!,
                              style: const TextStyle(
                                color: AppColors.accentDark,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      visitor.personUid,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: AppDimensions.iconS,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Text(
                          '${AppStrings.lastSeen}: ${dateFormat.format(visitor.lastSeenAt.toLocal())}',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${visitor.totalVisits}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    AppStrings.totalVisits,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyVisitorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: AppDimensions.iconXl * 1.5,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          const Text(
            AppStrings.noData,
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 16,
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
