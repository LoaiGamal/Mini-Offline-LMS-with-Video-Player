import 'package:flutter/material.dart';
import 'package:thaheen_task/core/components/app_card.dart';
import 'package:thaheen_task/core/components/app_progress_bar.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';
import 'package:thaheen_task/core/utils/duration_format.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/courses/data/models/section.dart';
import 'package:thaheen_task/features/courses/ui/widgets/course_thumbnail.dart';

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({
    super.key,
    required this.course,
    required this.lesson,
    required this.position,
    this.onTap,
  });

  final Course course;
  final Lesson lesson;
  final Duration position;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Duration duration = Duration(seconds: lesson.durationSec);
    final double progress = duration.inMilliseconds == 0 ? 0 : position.inMilliseconds / duration.inMilliseconds;
    final Section section = course.sections.firstWhere((Section item) => item.lessons.contains(lesson));
    final TextStyle? mutedStyle = theme.textTheme.bodySmall?.copyWith(color: colors.onPrimaryFixedVariant);

    return AppCard(
      onTap: onTap,
      color: colors.primaryFixed,
      showBorder: false,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CourseThumbnail(path: course.thumbnail, width: 64, height: 64, radius: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${course.title} · ${section.title}', style: mutedStyle),
                    const SizedBox(height: 4),
                    Text(
                      lesson.title,
                      style: theme.textTheme.titleMedium?.copyWith(color: colors.onPrimaryFixed),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: colors.secondary, shape: BoxShape.circle),
                child: Icon(Icons.play_arrow_rounded, color: colors.onSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressBar(value: progress, color: colors.secondary, trackColor: colors.primaryFixedDim),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(AppStrings.watchedPercent((progress.clamp(0.0, 1.0) * 100).round()), style: mutedStyle),
              Text(AppStrings.remaining(formatDuration(duration - position)), style: mutedStyle),
            ],
          ),
        ],
      ),
    );
  }
}
