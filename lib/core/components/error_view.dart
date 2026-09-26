import 'package:flutter/material.dart';
import 'package:thaheen_task/core/components/message_view.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: MessageView(
        illustration: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: colors.errorContainer, shape: BoxShape.circle),
          child: Icon(Icons.error_outline_rounded, size: 34, color: colors.error),
        ),
        title: title,
        message: message,
        actionLabel: AppStrings.retry,
        actionIcon: Icons.refresh_rounded,
        onAction: onRetry,
      ),
    );
  }
}
