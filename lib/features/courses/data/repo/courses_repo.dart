import 'package:thaheen_task/features/courses/data/local/courses_local_source.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';

class CoursesRepo {
  const CoursesRepo(this._localSource);

  final CoursesLocalSource _localSource;

  Future<List<Course>> getCourses() async {
    final List<Course> courses = await _localSource.loadCourses();
    _validateIds(courses);
    return courses;
  }

  Future<Set<String>> findMissingVideos(List<Course> courses) async {
    final Set<String> assets = await _localSource.loadAssetPaths();
    return <String>{
      for (final Course course in courses)
        for (final Lesson lesson in course.orderedLessons)
          if (!assets.contains(lesson.video)) lesson.video,
    };
  }

  void _validateIds(List<Course> courses) {
    final Set<String> courseIds = <String>{};
    for (final Course course in courses) {
      if (!courseIds.add(course.id)) {
        throw FormatException('Duplicate course id "${course.id}"');
      }
      final Set<String> lessonIds = <String>{};
      for (final Lesson lesson in course.orderedLessons) {
        if (!lessonIds.add(lesson.id)) {
          throw FormatException('Duplicate lesson id "${lesson.id}" in course "${course.id}"');
        }
      }
    }
  }
}
