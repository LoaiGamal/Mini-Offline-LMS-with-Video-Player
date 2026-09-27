import 'package:json_annotation/json_annotation.dart';

part 'lesson_note.g.dart';

@JsonSerializable()
class LessonNote {
  const LessonNote({
    required this.id,
    required this.courseId,
    required this.lessonId,
    required this.position,
    required this.text,
    required this.createdAt,
  });

  factory LessonNote.fromJson(Map<String, dynamic> json) =>
      _$LessonNoteFromJson(json);

  final String id;
  final String courseId;
  final String lessonId;
  final Duration position;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$LessonNoteToJson(this);
}
