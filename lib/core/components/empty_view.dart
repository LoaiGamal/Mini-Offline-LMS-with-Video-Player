import 'package:flutter/material.dart';
import 'package:thaheen_task/core/components/message_view.dart';
import 'package:thaheen_task/core/constants/app_assets.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.title = AppStrings.emptyLessonsTitle,
    this.message = AppStrings.emptyLessonsMessage,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return MessageView(
      illustration: Image.asset(
        isDark ? AppAssets.emptyIllustrationDark : AppAssets.emptyIllustration,
        width: 200,
        height: 160,
        excludeFromSemantics: true,
      ),
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
