import 'package:json_annotation/json_annotation.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';

part 'section.g.dart';

@JsonSerializable(createToJson: false)
class Section {
  const Section({required this.id, required this.title, required this.lessons});

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);

  final String id;
  final String title;
  final List<Lesson> lessons;
}
