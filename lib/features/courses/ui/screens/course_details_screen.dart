import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thaheen_task/core/components/app_card.dart';
import 'package:thaheen_task/core/components/app_icon_button.dart';
import 'package:thaheen_task/core/components/app_progress_bar.dart';
import 'package:thaheen_task/core/components/app_snack_bar.dart';
import 'package:thaheen_task/core/components/empty_view.dart';
import 'package:thaheen_task/core/components/error_view.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';
import 'package:thaheen_task/core/utils/duration_format.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/courses/data/models/section.dart';
import 'package:thaheen_task/features/courses/logic/courses_cubit.dart';
import 'package:thaheen_task/features/courses/logic/courses_state.dart';
import 'package:thaheen_task/features/courses/ui/widgets/course_thumbnail.dart';
import 'package:thaheen_task/features/courses/ui/widgets/lesson_tile.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';
import 'package:thaheen_task/features/progress/logic/progress_cubit.dart';
import 'package:thaheen_task/features/progress/logic/progress_rules.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CoursesCubit, CoursesState>(
          builder: (BuildContext context, CoursesState state) {
            if (state is CoursesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final Course? course = state is CoursesLoaded
                ? state.courses.where((Course item) => item.id == courseId).firstOrNull
                : null;
            if (course == null) {
              return const _WithBackButton(
                child: ErrorView(title: AppStrings.courseNotFoundTitle, message: AppStrings.courseNotFoundMessage),
              );
            }
            if (course.orderedLessons.isEmpty) {
              return _WithBackButton(
                child: EmptyView(actionLabel: AppStrings.backToCourses, onAction: () => context.pop()),
              );
            }
            return _CourseDetailsBody(course: course, missingVideos: (state as CoursesLoaded).missingVideos);
          },
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AppIconButton(
        icon: Icons.arrow_back_rounded,
        tooltip: AppStrings.back,
        onPressed: () => context.pop(),
      ),
    );
  }
}

class _WithBackButton extends StatelessWidget {
  const _WithBackButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, 0), child: _BackButton()),
        Expanded(child: child),
      ],
    );
  }
}

class _CourseDetailsBody extends StatelessWidget {
  const _CourseDetailsBody({required this.course, required this.missingVideos});

  final Course course;
  final Set<String> missingVideos;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Map<String, LessonProgress> progress = context.watch<ProgressCubit>().state.lessons;
    final List<Lesson> lessons = course.orderedLessons;
    final double courseProgress = ProgressRules.courseProgress(course, progress);
    final Duration totalDuration = Duration(
      seconds: lessons.fold(0, (int total, Lesson lesson) => total + lesson.durationSec),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        const _BackButton(),
        const SizedBox(height: 16),
        CourseThumbnail(path: course.thumbnail, height: 180, radius: 20),
        const SizedBox(height: 20),
        Text(course.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '${course.instructor} · ${AppStrings.lessonsCount(lessons.length)} · '
          '${formatDuration(totalDuration)} ${AppStrings.minutes}',
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(child: AppProgressBar(value: courseProgress, height: 8)),
            const SizedBox(width: 10),
            Text(
              AppStrings.completedPercent((courseProgress * 100).round()),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: colors.primary),
            ),
          ],
        ),
        for (final Section section in course.sections)
          if (section.lessons.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            _SectionHeader(section: section, courseId: course.id, progress: progress),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (final Lesson lesson in section.lessons) ...<Widget>[
                    if (lesson != section.lessons.first) const Divider(),
                    _buildLessonTile(context, lesson, lessons, progress),
                  ],
                ],
              ),
            ),
          ],
      ],
    );
  }

  Widget _buildLessonTile(
    BuildContext context,
    Lesson lesson,
    List<Lesson> lessons,
    Map<String, LessonProgress> progress,
  ) {
    final LessonProgress? lessonProgress = progress[LessonProgress.keyFor(course.id, lesson.id)];
    final bool isUnlocked = ProgressRules.isUnlocked(course, lesson, progress);
    final LessonTileState state = _tileState(lessonProgress, isUnlocked, missingVideos.contains(lesson.video));

    return LessonTile(
      title: lesson.title,
      duration: Duration(seconds: lesson.durationSec),
      position: lessonProgress?.position ?? Duration.zero,
      state: state,
      onTap: isUnlocked
          ? null
          : () {
              final Lesson previous = lessons[lessons.indexOf(lesson) - 1];
              showAppSnackBar(
                context,
                message: AppStrings.lockedLesson(previous.title),
                icon: Icons.lock_outline_rounded,
              );
            },
    );
  }

  LessonTileState _tileState(LessonProgress? lessonProgress, bool isUnlocked, bool isVideoMissing) {
    if (!isUnlocked) return LessonTileState.locked;
    if (isVideoMissing) return LessonTileState.unavailable;
    return switch (ProgressRules.lessonStatus(lessonProgress)) {
      LessonStatus.completed => LessonTileState.completed,
      LessonStatus.inProgress => LessonTileState.inProgress,
      LessonStatus.notStarted => LessonTileState.notStarted,
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section, required this.courseId, required this.progress});

  final Section section;
  final String courseId;
  final Map<String, LessonProgress> progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int completed = section.lessons
        .where((Lesson lesson) => progress[LessonProgress.keyFor(courseId, lesson.id)]?.isCompleted ?? false)
        .length;

    return Row(
      children: <Widget>[
        Expanded(child: Text(section.title, style: theme.textTheme.titleSmall)),
        Text(
          AppStrings.completedOf(completed, section.lessons.length),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
