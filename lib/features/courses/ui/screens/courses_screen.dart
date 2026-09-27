import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thaheen_task/core/components/app_icon_button.dart';
import 'package:thaheen_task/core/components/empty_view.dart';
import 'package:thaheen_task/core/components/error_view.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';
import 'package:thaheen_task/core/router/app_router.dart';
import 'package:thaheen_task/core/theme/theme_cubit.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/courses/logic/course_search.dart';
import 'package:thaheen_task/features/courses/logic/courses_cubit.dart';
import 'package:thaheen_task/features/courses/logic/courses_state.dart';
import 'package:thaheen_task/features/courses/ui/widgets/continue_watching_card.dart';
import 'package:thaheen_task/features/courses/ui/widgets/course_card.dart';
import 'package:thaheen_task/features/courses/ui/widgets/course_search_field.dart';
import 'package:thaheen_task/features/courses/ui/widgets/courses_skeleton.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';
import 'package:thaheen_task/features/progress/logic/progress_cubit.dart';
import 'package:thaheen_task/features/progress/logic/progress_rules.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CoursesCubit, CoursesState>(
          builder: (BuildContext context, CoursesState state) {
            return switch (state) {
              CoursesLoaded(:final List<Course> courses, :final String query) =>
                _CoursesList(courses: courses, query: query),
              CoursesLoading() => const _WithHeader(child: CoursesSkeleton()),
              CoursesEmpty() => const _WithHeader(
                child: EmptyView(
                  title: AppStrings.emptyCoursesTitle,
                  message: AppStrings.emptyCoursesMessage,
                ),
              ),
              CoursesError() => _WithHeader(
                child: ErrorView(
                  title: AppStrings.coursesErrorTitle,
                  message: AppStrings.coursesErrorMessage,
                  onRetry: () => context.read<CoursesCubit>().loadCourses(),
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _CoursesHeader extends StatelessWidget {
  const _CoursesHeader({this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? subtitle = this.subtitle;
    final bool isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.coursesTitle,
                  style: theme.textTheme.headlineMedium,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AppIconButton(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: isDark
                ? AppStrings.enableLightMode
                : AppStrings.enableDarkMode,
            onPressed: () =>
                context.read<ThemeCubit>().toggle(theme.brightness),
          ),
        ],
      ),
    );
  }
}

class _WithHeader extends StatelessWidget {
  const _WithHeader({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _CoursesHeader(),
        Expanded(child: child),
      ],
    );
  }
}

class _CoursesList extends StatelessWidget {
  const _CoursesList({required this.courses, required this.query});

  final List<Course> courses;
  final String query;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Map<String, LessonProgress> progress = context
        .watch<ProgressCubit>()
        .state
        .lessons;
    final bool isSearching = query.trim().isNotEmpty;
    final List<Course> visibleCourses = CourseSearch.filter(courses, query);
    final ({Course course, Lesson lesson})? continueWatching = isSearching
        ? null
        : ProgressRules.continueWatching(courses, progress);
    final int lessonsCount = courses.fold(
      0,
      (int total, Course course) => total + course.orderedLessons.length,
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: <Widget>[
        _CoursesHeader(
          subtitle:
              '${AppStrings.coursesCount(courses.length)} · ${AppStrings.lessonsCount(lessonsCount)}',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CourseSearchField(
                initialQuery: query,
                onChanged: context.read<CoursesCubit>().search,
              ),
              const SizedBox(height: 22),
              if (continueWatching != null) ...<Widget>[
                Text(AppStrings.continueWatching, style: textTheme.titleMedium),
                const SizedBox(height: 12),
                ContinueWatchingCard(
                  course: continueWatching.course,
                  lesson: continueWatching.lesson,
                  position:
                      progress[LessonProgress.keyFor(
                            continueWatching.course.id,
                            continueWatching.lesson.id,
                          )]
                          ?.position ??
                      Duration.zero,
                  onTap: () => context.push(
                    AppRoutes.lesson(
                      continueWatching.course.id,
                      continueWatching.lesson.id,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
              Text(
                isSearching ? AppStrings.searchResults : AppStrings.allCourses,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (visibleCourses.isEmpty) const _NoResults(),
              for (final Course course in visibleCourses) ...<Widget>[
                CourseCard(
                  course: course,
                  progress: ProgressRules.courseProgress(course, progress),
                  onTap: () => context.push(AppRoutes.courseDetails(course.id)),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(AppStrings.noResultsTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            AppStrings.noResultsMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
