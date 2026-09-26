import 'package:flutter/material.dart';
import 'package:thaheen_task/core/components/app_progress_bar.dart';
import 'package:thaheen_task/core/components/status_badge.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';
import 'package:thaheen_task/core/utils/duration_format.dart';

enum LessonTileState { completed, inProgress, notStarted, locked, unavailable }

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.title,
    required this.duration,
    required this.state,
    this.position = Duration.zero,
    this.onTap,
  });

  final String title;
  final Duration duration;
  final LessonTileState state;
  final Duration position;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isLocked = state == LessonTileState.locked;
    final bool isInProgress = state == LessonTileState.inProgress;

    final (String, Color, Color) badge = switch (state) {
      LessonTileState.completed => (AppStrings.statusCompleted, colors.onPrimaryContainer, colors.primaryContainer),
      LessonTileState.inProgress => (AppStrings.statusInProgress, colors.onTertiaryContainer, colors.tertiaryContainer),
      LessonTileState.notStarted => (AppStrings.statusNotStarted, colors.onSurface, colors.surfaceContainerHighest),
      LessonTileState.locked => (AppStrings.statusLocked, colors.onSurfaceVariant, colors.surfaceContainerHighest),
      LessonTileState.unavailable => (AppStrings.statusUnavailable, colors.onErrorContainer, colors.errorContainer),
    };

    return Material(
      color: isInProgress ? colors.tertiaryContainer.withValues(alpha: 0.5) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              _StatusIcon(state: state),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isLocked ? colors.outline : colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isInProgress)
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AppProgressBar(
                              value: duration.inMilliseconds == 0 ? 0 : position.inMilliseconds / duration.inMilliseconds,
                              height: 4,
                              color: colors.tertiary,
                              trackColor: colors.tertiaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${formatDuration(position)} / ${formatDuration(duration)}',
                            textDirection: TextDirection.ltr,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${formatDuration(duration)} ${AppStrings.minutes}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isLocked ? colors.outline : colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(label: badge.$1, foregroundColor: badge.$2, backgroundColor: badge.$3),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.state});

  final LessonTileState state;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final (Color, Color?, Color, IconData, double) style = switch (state) {
      LessonTileState.completed => (colors.primary, null, colors.onPrimary, Icons.check_rounded, 20),
      LessonTileState.inProgress => (colors.tertiaryContainer, colors.tertiary, colors.tertiary, Icons.play_arrow_rounded, 18),
      LessonTileState.notStarted => (Colors.transparent, colors.primary, colors.primary, Icons.play_arrow_rounded, 18),
      LessonTileState.locked => (colors.surfaceContainerHighest, null, colors.outline, Icons.lock_outline_rounded, 18),
      LessonTileState.unavailable => (colors.errorContainer, null, colors.error, Icons.error_outline_rounded, 20),
    };
    final Color? borderColor = style.$2;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: style.$1,
        shape: BoxShape.circle,
        border: borderColor == null ? null : Border.all(color: borderColor, width: 2),
      ),
      child: Icon(style.$4, size: style.$5, color: style.$3),
    );
  }
}
