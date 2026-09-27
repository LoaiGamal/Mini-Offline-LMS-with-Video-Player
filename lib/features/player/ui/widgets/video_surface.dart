import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thaheen_task/features/player/logic/player_cubit.dart';
import 'package:thaheen_task/features/player/logic/player_state.dart';
import 'package:thaheen_task/features/player/ui/widgets/player_controls.dart';
import 'package:thaheen_task/features/player/ui/widgets/video_error_view.dart';
import 'package:video_player/video_player.dart';

class VideoSurface extends StatefulWidget {
  const VideoSurface({
    super.key,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    this.title,
    this.subtitle,
  });

  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final String? title;
  final String? subtitle;

  @override
  State<VideoSurface> createState() => _VideoSurfaceState();
}

class _VideoSurfaceState extends State<VideoSurface> {
  static const Duration _hideDelay = Duration(seconds: 3);

  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDelay, () {
      if (!mounted) return;
      final PlayerState state = context.read<PlayerCubit>().state;
      if (state is PlayerReady && state.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _onSurfaceTap() {
    final PlayerState state = context.read<PlayerCubit>().state;
    final bool isPlaying = state is PlayerReady && state.isPlaying;
    if (_controlsVisible && isPlaying) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlayerCubit cubit = context.read<PlayerCubit>();
    final Widget content = BlocConsumer<PlayerCubit, PlayerState>(
      listenWhen: (PlayerState previous, PlayerState current) {
        return previous is PlayerReady &&
            current is PlayerReady &&
            previous.isPlaying != current.isPlaying;
      },
      listener: (BuildContext context, PlayerState state) {
        if (state is PlayerReady && state.isPlaying) {
          _scheduleHide();
        } else {
          _hideTimer?.cancel();
          setState(() => _controlsVisible = true);
        }
      },
      builder: (BuildContext context, PlayerState state) {
        final VideoPlayerController? controller = cubit.controller;
        return switch (state) {
          PlayerLoading() => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          PlayerError() => VideoErrorView(onRetry: cubit.initialize),
          PlayerReady() when controller == null => const SizedBox.shrink(),
          PlayerReady() => Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Center(
                child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onSurfaceTap,
              ),
              IgnorePointer(
                ignoring: !_controlsVisible,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: SafeArea(
                    top: widget.isFullscreen,
                    bottom: widget.isFullscreen,
                    left: widget.isFullscreen,
                    right: widget.isFullscreen,
                    child: PlayerControls(
                      position: state.position,
                      duration: state.duration,
                      isPlaying: state.isPlaying,
                      isBuffering: state.isBuffering,
                      speed: state.speed,
                      isFullscreen: widget.isFullscreen,
                      title: widget.title,
                      subtitle: widget.subtitle,
                      onTogglePlay: () {
                        cubit.togglePlay();
                        _scheduleHide();
                      },
                      onSeek: (Duration position) {
                        cubit.seekTo(position);
                        _scheduleHide();
                      },
                      onCycleSpeed: () {
                        final int index = PlayerCubit.speeds.indexOf(
                          state.speed,
                        );
                        cubit.setSpeed(
                          PlayerCubit.speeds[(index + 1) %
                              PlayerCubit.speeds.length],
                        );
                        _scheduleHide();
                      },
                      onToggleFullscreen: widget.onToggleFullscreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        };
      },
    );

    return ColoredBox(
      color: Colors.black,
      child: widget.isFullscreen
          ? SizedBox.expand(child: content)
          : AspectRatio(aspectRatio: 16 / 9, child: content),
    );
  }
}
