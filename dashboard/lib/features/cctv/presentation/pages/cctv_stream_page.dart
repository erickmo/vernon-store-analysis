import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../cubit/streaming_cubit.dart';
import '../cubit/streaming_state.dart';
import '../widgets/behaviour_alerts_list.dart';
import '../widgets/cctv_info_panel.dart';
import '../widgets/stream_player_widget.dart';

/// Page untuk menampilkan video streaming CCTV dengan detail dan alerts.
class CCTVStreamPage extends StatefulWidget {
  /// ID dari CCTV yang akan di-stream.
  final String cctvId;

  const CCTVStreamPage({
    super.key,
    required this.cctvId,
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
    _streamingCubit.initialize(widget.cctvId);
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
            backgroundColor: AppColors.dark,
            appBar: isFullscreen ? null : _buildAppBar(context, state),
            body: isFullscreen
                ? _buildFullscreenView(context, state)
                : _buildNormalView(context, state),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, StreamingState state) {
    final cctvName = state.cctv?.name ?? 'CCTV Stream';

    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        cctvName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildNormalView(BuildContext context, StreamingState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video player section
          _buildVideoSection(),

          // Info panel
          if (state.cctv != null) ...[
            CCTVInfoPanel(cctv: state.cctv!),
          ],

          // Behaviour alerts section
          Container(
            color: AppColors.dark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: BehaviourAlertsList(
              alerts: state.alerts,
              cubit: context.read<StreamingCubit>(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreenView(BuildContext context, StreamingState state) {
    return GestureDetector(
      onTap: () => context.read<StreamingCubit>().toggleFullscreen(),
      child: Stack(
        children: [
          // Video player (full screen)
          _buildVideoSection(),

          // Exit fullscreen button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.primary,
              onPressed: () => context.read<StreamingCubit>().toggleFullscreen(),
              child: const Icon(Icons.fullscreen_exit, color: Colors.white),
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
        color: AppColors.dark,
        child: const StreamPlayerWidget(),
      ),
    );
  }
}
