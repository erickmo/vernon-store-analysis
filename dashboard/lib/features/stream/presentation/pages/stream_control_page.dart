import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/stream_status_entity.dart';
import '../cubit/stream_status_cubit.dart';
import '../cubit/stream_status_state.dart';

/// Halaman kontrol stream kamera secara real-time.
class StreamControlPage extends StatefulWidget {
  const StreamControlPage({super.key});

  @override
  State<StreamControlPage> createState() => _StreamControlPageState();
}

class _StreamControlPageState extends State<StreamControlPage> {
  @override
  void initState() {
    super.initState();
    context.read<StreamStatusCubit>().loadStatus();
  }

  @override
  void dispose() {
    context.read<StreamStatusCubit>().disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text(AppStrings.cameraList),
        actions: [
          BlocBuilder<StreamStatusCubit, StreamStatusState>(
            builder: (context, state) {
              final isConnected = switch (state) {
                StreamStatusLoaded(:final isWsConnected) => isWsConnected,
                _ => false,
              };

              return IconButton(
                icon: Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  color: isConnected ? AppColors.success : AppColors.surface,
                ),
                tooltip: isConnected ? 'WebSocket Terhubung' : 'Hubungkan WebSocket',
                onPressed: () {
                  if (isConnected) {
                    context
                        .read<StreamStatusCubit>()
                        .disconnectWebSocket();
                  } else {
                    context
                        .read<StreamStatusCubit>()
                        .connectWebSocket();
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.refresh,
            onPressed: () => context.read<StreamStatusCubit>().loadStatus(),
          ),
        ],
      ),
      body: BlocConsumer<StreamStatusCubit, StreamStatusState>(
        listener: (context, state) {
          if (state is StreamWsAlertReceived) {
            _showAlertSnackBar(context, state.event);
          }
        },
        builder: (context, state) {
          return switch (state) {
            StreamStatusInitial() => const SizedBox.shrink(),
            StreamStatusLoading() ||
            StreamControlling() =>
              const Center(child: CircularProgressIndicator()),
            StreamStatusError(:final message) => _ErrorView(
              message: message,
              onRetry: () =>
                  context.read<StreamStatusCubit>().loadStatus(),
            ),
            StreamStatusLoaded(:final status, :final isWsConnected) =>
              _StreamStatusView(
                status: status,
                isWsConnected: isWsConnected,
              ),
            StreamWsDetectionReceived(:final status) => _StreamStatusView(
              status: status,
              isWsConnected: true,
            ),
            StreamWsAlertReceived(:final status) => _StreamStatusView(
              status: status,
              isWsConnected: true,
            ),
          };
        },
      ),
    );
  }

  void _showAlertSnackBar(
    BuildContext context,
    WsShopliftingAlertEvent event,
  ) {
    final confidence = (event.confidence * 100).toStringAsFixed(0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.alertHigh,
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.surface),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Text(
                '${AppStrings.shopliftingAlert} — Kamera ${event.cameraId} ($confidence%)',
                style: const TextStyle(color: AppColors.surface),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: AppStrings.close,
          textColor: AppColors.surface,
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}

class _StreamStatusView extends StatelessWidget {
  final StreamStatusEntity status;
  final bool isWsConnected;

  const _StreamStatusView({
    required this.status,
    required this.isWsConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryBar(
          status: status,
          isWsConnected: isWsConnected,
        ),
        _GlobalControls(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            itemCount: status.cameras.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.spacingS),
            itemBuilder: (context, index) {
              return _CameraStatusCard(camera: status.cameras[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final StreamStatusEntity status;
  final bool isWsConnected;

  const _SummaryBar({required this.status, required this.isWsConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        children: [
          _StatChip(
            label: AppStrings.streamActive,
            value: '${status.activeCameras}/${status.registeredCameras}',
            color: AppColors.success,
          ),
          const SizedBox(width: AppDimensions.spacingM),
          if (isWsConnected)
            _StatChip(
              label: 'Live',
              value: 'WS',
              color: AppColors.accentLight,
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimensions.spacingS,
          height: AppDimensions.spacingS,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _GlobalControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  context.read<StreamStatusCubit>().startAllStreams(),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text(AppStrings.startAllStreams),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: const BorderSide(color: AppColors.success),
                minimumSize:
                    const Size(0, AppDimensions.buttonHeightS),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  context.read<StreamStatusCubit>().stopAllStreams(),
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text(AppStrings.stopAllStreams),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize:
                    const Size(0, AppDimensions.buttonHeightS),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraStatusCard extends StatelessWidget {
  final CameraStreamStatusEntity camera;

  const _CameraStatusCard({required this.camera});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        camera.isRunning ? AppColors.streamActive : AppColors.streamInactive;

    return Card(
      color: AppColors.surface,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Row(
          children: [
            Container(
              width: AppDimensions.spacingM,
              height: AppDimensions.spacingM,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kamera ${camera.cameraId} — ${camera.zone}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    'Orang: ${camera.personsInFrame}  |  Total: ${camera.totalDetections}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  if (camera.lastFrameAt != null)
                    Text(
                      'Frame terakhir: ${_formatTime(camera.lastFrameAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
            _CameraControlButton(camera: camera),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}

class _CameraControlButton extends StatelessWidget {
  final CameraStreamStatusEntity camera;

  const _CameraControlButton({required this.camera});

  @override
  Widget build(BuildContext context) {
    if (camera.isRunning) {
      return IconButton(
        icon: const Icon(Icons.stop_circle_outlined),
        color: AppColors.error,
        tooltip: AppStrings.stopStream,
        onPressed: () =>
            context.read<StreamStatusCubit>().stopCamera(camera.cameraId),
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.play_circle_outline),
        color: AppColors.success,
        tooltip: AppStrings.startStream,
        onPressed: () =>
            context.read<StreamStatusCubit>().startCamera(camera.cameraId),
      );
    }
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
