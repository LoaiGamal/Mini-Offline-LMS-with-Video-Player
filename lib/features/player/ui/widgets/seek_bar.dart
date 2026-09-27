import 'package:flutter/material.dart';
import 'package:thaheen_task/core/utils/duration_format.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double max = widget.duration.inMilliseconds <= 0
        ? 1
        : widget.duration.inMilliseconds.toDouble();
    final double value =
        (_dragValue ?? widget.position.inMilliseconds.toDouble()).clamp(0, max);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        activeTrackColor: colors.secondary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
        thumbColor: colors.secondary,
        overlayColor: colors.secondary.withValues(alpha: 0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: value,
        max: max,
        semanticFormatterCallback: (double value) =>
            formatDuration(Duration(milliseconds: value.round())),
        onChangeStart: (double value) => setState(() => _dragValue = value),
        onChanged: (double value) => setState(() => _dragValue = value),
        onChangeEnd: (double value) {
          widget.onSeek(Duration(milliseconds: value.round()));
          setState(() => _dragValue = null);
        },
      ),
    );
  }
}
