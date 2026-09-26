import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';

part 'progress_state.freezed.dart';

@freezed
abstract class ProgressState with _$ProgressState {
  const factory ProgressState({required Map<String, LessonProgress> lessons}) = _ProgressState;
}
