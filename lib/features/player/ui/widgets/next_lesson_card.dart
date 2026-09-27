import 'package:flutter/material.dart';
import 'package:thaheen_task/core/components/app_button.dart';
import 'package:thaheen_task/core/components/app_card.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';

class NextLessonCard extends StatelessWidget {
  const NextLessonCard({
    super.key,
    required this.title,
    required this.isUnlocked,
    required this.onOpen,
  });

  final String title;
  final bool isUnlocked;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppStrings.nextLesson,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          AppButton(
            label: isUnlocked
                ? AppStrings.startNextLesson
                : AppStrings.nextLessonLocked,
            icon: isUnlocked
                ? Icons.arrow_forward_rounded
                : Icons.lock_outline_rounded,
            onPressed: isUnlocked ? onOpen : null,
          ),
        ],
      ),
    );
  }
}
