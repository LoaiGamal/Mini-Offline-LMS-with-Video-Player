import 'package:flutter/material.dart';

enum AppButtonVariant { filled, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    const Size minimumSize = Size(0, 48);
    const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 24);
    const OutlinedBorder shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14)));
    final Widget? iconWidget = icon == null ? null : Icon(icon, size: 18);
    final Widget labelWidget = Text(label, textAlign: TextAlign.center);

    switch (variant) {
      case AppButtonVariant.filled:
        final ButtonStyle style = FilledButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          shape: shape,
          textStyle: theme.textTheme.labelLarge,
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          disabledForegroundColor: colors.onSurfaceVariant,
        );
        return iconWidget == null
            ? FilledButton(onPressed: onPressed, style: style, child: labelWidget)
            : FilledButton.icon(onPressed: onPressed, style: style, icon: iconWidget, label: labelWidget);
      case AppButtonVariant.outlined:
        final ButtonStyle style = OutlinedButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          shape: shape,
          textStyle: theme.textTheme.labelLarge,
          foregroundColor: colors.primary,
          side: BorderSide(color: onPressed == null ? colors.outlineVariant : colors.primary),
        );
        return iconWidget == null
            ? OutlinedButton(onPressed: onPressed, style: style, child: labelWidget)
            : OutlinedButton.icon(onPressed: onPressed, style: style, icon: iconWidget, label: labelWidget);
    }
  }
}
