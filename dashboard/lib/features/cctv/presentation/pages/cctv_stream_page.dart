import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../cubit/streaming_cubit.dart';
import '../cubit/streaming_state.dart';
import '../widgets/cctv_info_panel.dart';
import '../widgets/stream_player_widget.dart';

/// Page untuk menampilkan video streaming kamera.
class CCTVStreamPage extends StatefulWidget {
  /// ID toko pemilik kamera.
  final int storeId;

  /// ID kamera yang akan di-stream.
  final int cameraId;

  const CCTVStreamPage({
    super.key,
    required this.storeId,
    required this.cameraId,
  });

  @override
  State<CCTVStreamPage> createState() => _CCTVStreamPageState();
}

class _CCTVStreamPageState extends State<CCTVStreamPage> {
  late StreamingCubit _streamingCubit;

  @override
  void initState() {
    super.initState();
    _streamingCubit = getIt<StreamingCubit>();
    _streamingCubit.initialize(widget.storeId, widget.cameraId);
  }

  @override
  void dispose() {
    _streamingCubit.disposeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StreamingCubit>.value(
      value: _streamingCubit,
      child: BlocBuilder<StreamingCubit, StreamingState>(
        builder: (context, state) {
          final isFullscreen = state.isFullscreen;

          return Scaffold(
            backgroundColor: AppColors.primaryDark,
            appBar: isFullscreen ? null : _buildAppBar(context, state),
            body: isFullscreen
                ? _buildFullscreenView(context)
                : _buildNormalView(context, state),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    StreamingState state,
  ) {
    final cameraName = state.cctv?.name ?? 'CCTV Stream';

    return AppBar(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.surface,
      title: Text(cameraName),
    );
  }

  Widget _buildNormalView(BuildContext context, StreamingState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVideoSection(),
          if (state.cctv != null)
            CCTVInfoPanel(cctv: state.cctv!),
        ],
      ),
    );
  }

  Widget _buildFullscreenView(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<StreamingCubit>().toggleFullscreen(),
      child: Stack(
        children: [
          _buildVideoSection(),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.primary,
              onPressed: () =>
                  context.read<StreamingCubit>().toggleFullscreen(),
              child: const Icon(
                Icons.fullscreen_exit,
                color: AppColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: AppColors.primaryDark,
        child: const StreamPlayerWidget(),
      ),
    );
  }
}
