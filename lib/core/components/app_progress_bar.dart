import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color,
    this.trackColor,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double progress = value.clamp(0.0, 1.0);
    final BorderRadius radius = BorderRadius.circular(height / 2);

    return Semantics(
      value: '${(progress * 100).round()}%',
      child: Container(
        height: height,
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(color: trackColor ?? colors.surfaceContainerHighest, borderRadius: radius),
        child: FractionallySizedBox(
          widthFactor: progress,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color ?? colors.primary, borderRadius: radius),
          ),
        ),
      ),
    );
  }
}
