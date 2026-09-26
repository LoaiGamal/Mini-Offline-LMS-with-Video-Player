import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';

enum LessonStatus { notStarted, inProgress, completed }

abstract final class ProgressRules {
  static const double completionThreshold = 0.9;

  static bool reachedCompletion({required Duration position, required Duration duration}) {
    if (duration <= Duration.zero) return false;
    return position.inMilliseconds >= duration.inMilliseconds * completionThreshold;
  }

  static LessonStatus lessonStatus(LessonProgress? progress) {
    if (progress == null) return LessonStatus.notStarted;
    if (progress.isCompleted) return LessonStatus.completed;
    if (progress.position > Duration.zero) return LessonStatus.inProgress;
    return LessonStatus.notStarted;
  }

  static bool isUnlocked(Course course, Lesson lesson, Map<String, LessonProgress> progress) {
    final List<Lesson> lessons = course.orderedLessons;
    final int index = lessons.indexWhere((Lesson item) => item.id == lesson.id);
    if (index == -1) return false;
    if (index == 0) return true;
    final Lesson previous = lessons[index - 1];
    return progress[LessonProgress.keyFor(course.id, previous.id)]?.isCompleted ?? false;
  }

  static double courseProgress(Course course, Map<String, LessonProgress> progress) {
    final List<Lesson> lessons = course.orderedLessons;
    if (lessons.isEmpty) return 0;
    final int completed = lessons
        .where((Lesson lesson) => progress[LessonProgress.keyFor(course.id, lesson.id)]?.isCompleted ?? false)
        .length;
    return completed / lessons.length;
  }

  static Lesson? nextLesson(Course course, Lesson lesson) {
    final List<Lesson> lessons = course.orderedLessons;
    final int index = lessons.indexWhere((Lesson item) => item.id == lesson.id);
    if (index == -1 || index == lessons.length - 1) return null;
    return lessons[index + 1];
  }

  static Duration resumePosition(LessonProgress? progress, Duration duration) {
    if (progress == null) return Duration.zero;
    if (reachedCompletion(position: progress.position, duration: duration)) return Duration.zero;
    return progress.position;
  }

  static ({Course course, Lesson lesson})? continueWatching(
    List<Course> courses,
    Map<String, LessonProgress> progress,
  ) {
    final List<LessonProgress> unfinished = progress.values
        .where((LessonProgress item) => lessonStatus(item) == LessonStatus.inProgress)
        .toList()
      ..sort((LessonProgress a, LessonProgress b) => b.updatedAt.compareTo(a.updatedAt));

    for (final LessonProgress item in unfinished) {
      for (final Course course in courses) {
        if (course.id != item.courseId) continue;
        for (final Lesson lesson in course.orderedLessons) {
          if (lesson.id == item.lessonId) return (course: course, lesson: lesson);
        }
      }
    }
    return null;
  }
}
