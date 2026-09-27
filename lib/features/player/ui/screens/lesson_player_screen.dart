import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thaheen_task/core/components/app_button.dart';
import 'package:thaheen_task/core/components/app_icon_button.dart';
import 'package:thaheen_task/core/components/error_view.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';
import 'package:thaheen_task/core/router/app_router.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/courses/data/models/section.dart';
import 'package:thaheen_task/features/courses/logic/courses_cubit.dart';
import 'package:thaheen_task/features/courses/logic/courses_state.dart';
import 'package:thaheen_task/features/notes/ui/widgets/notes_sheet.dart';
import 'package:thaheen_task/features/player/data/repo/player_settings_repo.dart';
import 'package:thaheen_task/features/player/logic/player_cubit.dart';
import 'package:thaheen_task/features/player/logic/player_state.dart';
import 'package:thaheen_task/features/player/ui/widgets/next_lesson_card.dart';
import 'package:thaheen_task/features/player/ui/widgets/speed_selector.dart';
import 'package:thaheen_task/features/player/ui/widgets/video_surface.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';
import 'package:thaheen_task/features/progress/logic/progress_cubit.dart';
import 'package:thaheen_task/features/progress/logic/progress_rules.dart';

class LessonPlayerScreen extends StatelessWidget {
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final CoursesState coursesState = context.watch<CoursesCubit>().state;
    if (coursesState is CoursesLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Course? course = coursesState is CoursesLoaded
        ? coursesState.courses
              .where((Course item) => item.id == courseId)
              .firstOrNull
        : null;
    final Lesson? lesson = course?.orderedLessons
        .where((Lesson item) => item.id == lessonId)
        .firstOrNull;
    if (course == null || lesson == null) {
      return const _MessageScaffold(
        child: ErrorView(
          title: AppStrings.lessonNotFoundTitle,
          message: AppStrings.lessonNotFoundMessage,
        ),
      );
    }

    final Map<String, LessonProgress> progress = context
        .read<ProgressCubit>()
        .state
        .lessons;
    if (!ProgressRules.isUnlocked(course, lesson, progress)) {
      return const _MessageScaffold(
        child: ErrorView(
          title: AppStrings.lessonLockedTitle,
          message: AppStrings.lessonLockedMessage,
        ),
      );
    }

    return BlocProvider<PlayerCubit>(
      create: (BuildContext context) {
        return PlayerCubit(
          courseId: course.id,
          lesson: lesson,
          progressCubit: context.read<ProgressCubit>(),
          settingsRepo: context.read<PlayerSettingsRepo>(),
        )..initialize();
      },
      child: _PlayerView(course: course, lesson: lesson),
    );
  }
}

class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: AppStrings.back,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _PlayerView extends StatefulWidget {
  const _PlayerView({required this.course, required this.lesson});

  final Course course;
  final Lesson lesson;

  @override
  State<_PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<_PlayerView> {
  late final AppLifecycleListener _lifecycleListener;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onHide: () => context.read<PlayerCubit>().pause(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _restoreSystemUi();
    super.dispose();
  }

  void _setFullscreen(bool isFullscreen) {
    setState(() => _isFullscreen = isFullscreen);
    if (isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      _restoreSystemUi();
    }
  }

  void _restoreSystemUi() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final Course course = widget.course;
    final Lesson lesson = widget.lesson;
    final List<Lesson> lessons = course.orderedLessons;
    final Section section = course.sections.firstWhere(
      (Section item) => item.lessons.contains(lesson),
    );
    final String lessonPosition = AppStrings.lessonPosition(
      section.title,
      lessons.indexOf(lesson) + 1,
      lessons.length,
    );

    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _setFullscreen(false);
      },
      child: _isFullscreen
          ? Scaffold(
              backgroundColor: Colors.black,
              body: VideoSurface(
                isFullscreen: true,
                title: lesson.title,
                subtitle: '${course.title} · ${section.title}',
                onToggleFullscreen: () => _setFullscreen(false),
              ),
            )
          : Scaffold(
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                      child: Row(
                        children: <Widget>[
                          AppIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: AppStrings.back,
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              course.title,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    VideoSurface(
                      isFullscreen: false,
                      onToggleFullscreen: () => _setFullscreen(true),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _LessonDetails(
                        course: course,
                        lesson: lesson,
                        lessonPosition: lessonPosition,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _LessonDetails extends StatelessWidget {
  const _LessonDetails({
    required this.course,
    required this.lesson,
    required this.lessonPosition,
  });

  final Course course;
  final Lesson lesson;
  final String lessonPosition;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, LessonProgress> progress = context
        .watch<ProgressCubit>()
        .state
        .lessons;
    final PlayerState playerState = context.watch<PlayerCubit>().state;
    final Lesson? next = ProgressRules.nextLesson(course, lesson);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(lesson.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          lessonPosition,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Text(AppStrings.playbackSpeed, style: theme.textTheme.labelLarge),
        const SizedBox(height: 10),
        SpeedSelector(
          speeds: PlayerCubit.speeds,
          selected: playerState is PlayerReady
              ? playerState.speed
              : PlayerCubit.speeds.first,
          onChanged: playerState is PlayerReady
              ? context.read<PlayerCubit>().setSpeed
              : null,
        ),
        if (next != null) ...<Widget>[
          const SizedBox(height: 20),
          NextLessonCard(
            title: next.title,
            isUnlocked: ProgressRules.isUnlocked(course, next, progress),
            onOpen: () =>
                context.pushReplacement(AppRoutes.lesson(course.id, next.id)),
          ),
        ],
        const SizedBox(height: 20),
        AppButton(
          label: AppStrings.lessonNotes,
          icon: Icons.edit_outlined,
          variant: AppButtonVariant.outlined,
          onPressed: () => _openNotes(context),
        ),
      ],
    );
  }

  Future<void> _openNotes(BuildContext context) async {
    final PlayerCubit player = context.read<PlayerCubit>();
    final PlayerState state = player.state;
    final bool wasPlaying = state is PlayerReady && state.isPlaying;
    bool jumped = false;
    await player.pause();
    if (!context.mounted) return;

    await showNotesSheet(
      context,
      courseId: course.id,
      lessonId: lesson.id,
      lessonTitle: lesson.title,
      position: state is PlayerReady ? state.position : Duration.zero,
      onJump: (Duration position) async {
        jumped = true;
        await player.seekTo(position);
        await player.play();
      },
    );
    if (wasPlaying && !jumped) await player.play();
  }
}
