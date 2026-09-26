import 'package:json_annotation/json_annotation.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/courses/data/models/section.dart';

part 'course.g.dart';

@JsonSerializable(createToJson: false)
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.sections,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  final String id;
  final String title;
  final String instructor;
  final String thumbnail;
  final List<Section> sections;

  List<Lesson> get orderedLessons => <Lesson>[for (final Section section in sections) ...section.lessons];
}
