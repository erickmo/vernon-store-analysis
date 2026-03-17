import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../cubit/streaming_cubit.dart';
import '../cubit/streaming_state.dart';

/// Widget untuk menampilkan video player stream dengan controls dan alerts.
class StreamPlayerWidget extends StatelessWidget {
  const StreamPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreamingCubit, StreamingState>(
      builder: (context, state) {
        return switch (state.streamStatus) {
          StreamStatus.initial || StreamStatus.loading =>
            _buildLoadingView(),
          StreamStatus.streaming =>
            _buildVideoPlayerStack(context, state),
          StreamStatus.error => _buildErrorView(state.errorMessage ?? 'Unknown error'),
          StreamStatus.noSignal =>
            _buildNoSignalView(),
        };
      },
    );
  }

  Widget _buildLoadingView() => Container(
    color: AppColors.dark,
    child: const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    ),
  );

  Widget _buildVideoPlayerStack(
    BuildContext context,
    StreamingState state,
  ) {
    final cubit = context.read<StreamingCubit>();
    final videoController = cubit.videoController;

    if (videoController == null || !videoController.value.isInitialized) {
      return _buildLoadingView();
    }

    return GestureDetector(
      onTap: () => cubit.tapOnPlayer(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          ),

          // Controls overlay
          AnimatedOpacity(
            opacity: state.showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !state.showControls,
              child: _buildControlsOverlay(context, state),
            ),
          ),

          // Alert overlay
          if (state.showAlertOverlay && state.activeAlert != null)
            Positioned(
              top: 16,
              right: 16,
              child: _buildAlertBadge(state.activeAlert!),
            ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay(BuildContext context, StreamingState state) {
    final cubit = context.read<StreamingCubit>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top controls
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () => cubit.toggleFullscreen(),
                  tooltip: 'Fullscreen',
                ),
              ],
            ),
          ),

          // Center play/pause button
          FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => cubit.togglePlayPause(),
            child: Icon(
              state.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),

          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                // Volume slider
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.volume > 0
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Expanded(
                        child: Slider(
                          value: state.volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) => cubit.setVolume(value),
                          activeColor: AppColors.primary,
                          inactiveColor: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBadge(dynamic alert) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingM,
      vertical: AppDimensions.spacingS,
    ),
    decoration: BoxDecoration(
      color: _getConfidenceColor(alert.confidence).withOpacity(0.9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '⚠️ Behaviour Alert',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          alert.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );

  Widget _buildErrorView(String message) => Container(
    color: AppColors.dark,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'Stream Error',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingL,
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildNoSignalView() => Container(
    color: AppColors.dark,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.signal_no_sim,
            color: Colors.orange,
            size: 48,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          const Text(
            'No Signal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          const Text(
            'CCTV is currently offline',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.red;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.yellow;
  }
}
