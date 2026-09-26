import 'package:json_annotation/json_annotation.dart';

part 'lesson.g.dart';

@JsonSerializable(createToJson: false)
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.durationSec,
    required this.video,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  final String id;
  final String title;
  final int durationSec;
  final String video;
}
