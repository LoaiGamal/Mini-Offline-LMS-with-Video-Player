import 'package:flutter/material.dart';
import 'package:thaheen_task/core/utils/speed_format.dart';

class SpeedSelector extends StatelessWidget {
  const SpeedSelector({
    super.key,
    required this.speeds,
    required this.selected,
    required this.onChanged,
  });

  final List<double> speeds;
  final double selected;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final ValueChanged<double>? onChanged = this.onChanged;

    return Row(
      children: <Widget>[
        for (final double speed in speeds) ...<Widget>[
          if (speed != speeds.first) const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              selected: speed == selected,
              inMutuallyExclusiveGroup: true,
              child: OutlinedButton(
                onPressed: onChanged == null ? null : () => onChanged(speed),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  textStyle: theme.textTheme.labelLarge,
                  backgroundColor: speed == selected
                      ? colors.primary
                      : colors.surfaceContainerLowest,
                  foregroundColor: speed == selected
                      ? colors.onPrimary
                      : colors.onSurface,
                  side: BorderSide(
                    color: speed == selected
                        ? colors.primary
                        : colors.outlineVariant,
                  ),
                ),
                child: Text(
                  formatSpeed(speed),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
