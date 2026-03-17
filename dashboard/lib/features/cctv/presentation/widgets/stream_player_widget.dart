import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/streaming_cubit.dart';
import '../cubit/streaming_state.dart';

/// Widget untuk menampilkan video player stream dengan controls overlay.
class StreamPlayerWidget extends StatelessWidget {
  const StreamPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreamingCubit, StreamingState>(
      builder: (context, state) {
        return switch (state.streamStatus) {
          StreamStatus.initial || StreamStatus.loading => _buildLoadingView(),
          StreamStatus.streaming => _buildVideoPlayerStack(context, state),
          StreamStatus.error =>
            _buildErrorView(state.errorMessage ?? AppStrings.unknownError),
          StreamStatus.noSignal => _buildNoSignalView(),
        };
      },
    );
  }

  Widget _buildLoadingView() => Container(
    color: AppColors.primaryDark,
    child: const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
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
          AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          ),
          AnimatedOpacity(
            opacity: state.showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !state.showControls,
              child: _buildControlsOverlay(context, state),
            ),
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
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: AppColors.surface),
                  onPressed: () => cubit.toggleFullscreen(),
                  tooltip: 'Fullscreen',
                ),
              ],
            ),
          ),
          FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => cubit.togglePlayPause(),
            child: Icon(
              state.isPlaying ? Icons.pause : Icons.play_arrow,
              color: AppColors.surface,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Row(
              children: [
                Icon(
                  state.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: AppColors.surface,
                  size: AppDimensions.iconM,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Slider(
                    value: state.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) => cubit.setVolume(value),
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.surface.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) => Container(
    color: AppColors.primaryDark,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: AppDimensions.iconXl,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          const Text(
            'Stream Error',
            style: TextStyle(
              color: AppColors.surface,
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
              style: TextStyle(
                color: AppColors.surface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildNoSignalView() => Container(
    color: AppColors.primaryDark,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.signal_cellular_off,
            color: AppColors.warning,
            size: AppDimensions.iconXl,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            AppStrings.streamInactive,
            style: const TextStyle(
              color: AppColors.surface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Kamera sedang tidak aktif',
            style: TextStyle(
              color: AppColors.surface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
