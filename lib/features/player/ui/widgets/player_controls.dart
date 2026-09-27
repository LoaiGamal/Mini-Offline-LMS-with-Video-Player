import 'package:flutter/material.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';
import 'package:thaheen_task/core/utils/duration_format.dart';
import 'package:thaheen_task/core/utils/speed_format.dart';
import 'package:thaheen_task/features/player/ui/widgets/seek_bar.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isBuffering,
    required this.speed,
    required this.isFullscreen,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onCycleSpeed,
    required this.onToggleFullscreen,
    this.title,
    this.subtitle,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final double speed;
  final bool isFullscreen;
  final VoidCallback onTogglePlay;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onCycleSpeed;
  final VoidCallback onToggleFullscreen;
  final String? title;
  final String? subtitle;

  static const Color _scrim = Color(0x8C000000);

  bool get _isEnded => duration > Duration.zero && position >= duration;

  double get _horizontalPadding => isFullscreen ? 24 : 12;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? title = this.title;

    return Stack(
      children: <Widget>[
        if (isFullscreen && title != null) _buildTopBar(textTheme, title),
        Center(child: _buildCenterButton()),
        _buildBottomBar(textTheme),
      ],
    );
  }

  Widget _buildTopBar(TextTheme textTheme, String title) {
    final String? subtitle = this.subtitle;
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: Container(
        color: _scrim,
        padding: EdgeInsets.fromLTRB(
          _horizontalPadding,
          8,
          _horizontalPadding,
          8,
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onToggleFullscreen,
              tooltip: AppStrings.exitFullscreen,
              color: Colors.white,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(color: Colors.white),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    if (isBuffering && !isPlaying) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    final (IconData, String) playAction = isPlaying
        ? (Icons.pause_rounded, AppStrings.pause)
        : _isEnded
        ? (Icons.replay_rounded, AppStrings.replay)
        : (Icons.play_arrow_rounded, AppStrings.play);

    return IconButton(
      onPressed: onTogglePlay,
      tooltip: playAction.$2,
      iconSize: isFullscreen ? 32 : 28,
      style: IconButton.styleFrom(
        fixedSize: Size.square(isFullscreen ? 72 : 64),
        backgroundColor: _scrim,
        foregroundColor: Colors.white,
      ),
      icon: Icon(playAction.$1),
    );
  }

  Widget _buildBottomBar(TextTheme textTheme) {
    return PositionedDirectional(
      start: 0,
      end: 0,
      bottom: 0,
      child: Container(
        color: _scrim,
        padding: EdgeInsets.fromLTRB(
          _horizontalPadding,
          0,
          _horizontalPadding,
          4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 28,
              child: SeekBar(
                position: position,
                duration: duration,
                onSeek: onSeek,
              ),
            ),
            Row(
              children: <Widget>[
                const SizedBox(width: 8),
                _buildTimeLabel(textTheme),
                const Spacer(),
                _buildSpeedButton(textTheme),
                _buildFullscreenButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLabel(TextTheme textTheme) {
    return Text(
      '${formatDuration(position)} / ${formatDuration(duration)}',
      textDirection: TextDirection.ltr,
      style: textTheme.bodySmall?.copyWith(color: Colors.white),
    );
  }

  Widget _buildSpeedButton(TextTheme textTheme) {
    return Tooltip(
      message: AppStrings.changeSpeed,
      child: OutlinedButton(
        onPressed: onCycleSpeed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
          textStyle: textTheme.labelMedium,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        child: Text(formatSpeed(speed), textDirection: TextDirection.ltr),
      ),
    );
  }

  Widget _buildFullscreenButton() {
    return IconButton(
      onPressed: onToggleFullscreen,
      tooltip: isFullscreen
          ? AppStrings.exitFullscreen
          : AppStrings.enterFullscreen,
      color: Colors.white,
      icon: Icon(
        isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
      ),
    );
  }
}
