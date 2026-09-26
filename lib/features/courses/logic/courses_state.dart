import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';

part 'courses_state.freezed.dart';

@freezed
sealed class CoursesState with _$CoursesState {
  const factory CoursesState.loading() = CoursesLoading;

  const factory CoursesState.loaded({
    required List<Course> courses,
    required Set<String> missingVideos,
  }) = CoursesLoaded;

  const factory CoursesState.empty() = CoursesEmpty;

  const factory CoursesState.error() = CoursesError;
}
