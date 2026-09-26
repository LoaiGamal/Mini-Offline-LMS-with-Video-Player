import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';
import 'package:thaheen_task/features/progress/data/repo/progress_repo.dart';
import 'package:thaheen_task/features/progress/logic/progress_rules.dart';
import 'package:thaheen_task/features/progress/logic/progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._repo) : super(ProgressState(lessons: _repo.loadProgress()));

  final ProgressRepo _repo;

  LessonProgress? progressOf(String courseId, String lessonId) {
    return state.lessons[LessonProgress.keyFor(courseId, lessonId)];
  }

  Future<void> savePosition({
    required String courseId,
    required String lessonId,
    required Duration position,
    required Duration duration,
  }) async {
    final bool wasCompleted = progressOf(courseId, lessonId)?.isCompleted ?? false;
    final LessonProgress updated = LessonProgress(
      courseId: courseId,
      lessonId: lessonId,
      position: position,
      isCompleted: wasCompleted || ProgressRules.reachedCompletion(position: position, duration: duration),
      updatedAt: DateTime.now(),
    );
    final Map<String, LessonProgress> lessons = <String, LessonProgress>{
      ...state.lessons,
      updated.key: updated,
    };
    emit(state.copyWith(lessons: lessons));

    try {
      await _repo.saveProgress(lessons);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}
