import 'package:flutter/material.dart';
import 'package:thaheen_task/core/components/app_card.dart';
import 'package:thaheen_task/core/components/app_progress_bar.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/ui/widgets/course_thumbnail.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.progress,
    required this.onTap,
  });

  final Course course;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final int percent = (progress * 100).round();

    return AppCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          CourseThumbnail(path: course.thumbnail, width: 96, height: 96),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(course.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '${course.instructor} · ${AppStrings.lessonsCount(course.orderedLessons.length)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(child: AppProgressBar(value: progress)),
                    const SizedBox(width: 10),
                    Text(
                      '$percent%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: percent > 0 ? colors.primary : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
