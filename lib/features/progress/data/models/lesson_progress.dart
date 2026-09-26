import 'package:json_annotation/json_annotation.dart';

part 'lesson_progress.g.dart';

@JsonSerializable()
class LessonProgress {
  const LessonProgress({
    required this.courseId,
    required this.lessonId,
    required this.position,
    required this.isCompleted,
    required this.updatedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) => _$LessonProgressFromJson(json);

  final String courseId;
  final String lessonId;
  final Duration position;
  final bool isCompleted;
  final DateTime updatedAt;

  static String keyFor(String courseId, String lessonId) => '$courseId/$lessonId';

  String get key => keyFor(courseId, lessonId);

  Map<String, dynamic> toJson() => _$LessonProgressToJson(this);
}
