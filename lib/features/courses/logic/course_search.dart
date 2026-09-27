import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/courses/data/models/section.dart';

abstract final class CourseSearch {
  static final RegExp _diacritics = RegExp('[ً-ْـ]');
  static final RegExp _alefVariants = RegExp('[أإآ]');

  static List<Course> filter(List<Course> courses, String query) {
    final String normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return courses;
    return courses
        .where((Course course) => _matches(course, normalizedQuery))
        .toList();
  }

  static String normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(_diacritics, '')
        .replaceAll(_alefVariants, 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  static bool _matches(Course course, String normalizedQuery) {
    final List<String> fields = <String>[
      course.title,
      course.instructor,
      for (final Section section in course.sections) section.title,
      for (final Lesson lesson in course.orderedLessons) lesson.title,
    ];
    return fields.any(
      (String field) => normalize(field).contains(normalizedQuery),
    );
  }
}
