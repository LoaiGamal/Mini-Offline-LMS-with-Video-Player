import 'package:flutter/material.dart';
import 'package:thaheen_task/core/components/app_button.dart';

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final Widget illustration;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? label = actionLabel;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            illustration,
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (label != null && onAction != null) ...<Widget>[
              const SizedBox(height: 24),
              AppButton(label: label, icon: actionIcon, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
