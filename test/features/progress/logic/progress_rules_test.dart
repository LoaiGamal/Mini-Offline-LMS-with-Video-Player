import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/courses/data/models/section.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';
import 'package:thaheen_task/features/progress/logic/progress_rules.dart';

const Lesson l1 = Lesson(id: 'l1', title: 'l1', durationSec: 100, video: 'l1.mp4');
const Lesson l2 = Lesson(id: 'l2', title: 'l2', durationSec: 100, video: 'l2.mp4');
const Lesson l3 = Lesson(id: 'l3', title: 'l3', durationSec: 100, video: 'l3.mp4');

const Course course = Course(
  id: 'c1',
  title: 'course',
  instructor: 'instructor',
  thumbnail: 'thumb.png',
  sections: <Section>[
    Section(id: 's1', title: 's1', lessons: <Lesson>[l1, l2]),
    Section(id: 's2', title: 's2', lessons: <Lesson>[l3]),
  ],
);

LessonProgress progress(
  String lessonId, {
  String courseId = 'c1',
  int positionSec = 10,
  bool isCompleted = false,
  DateTime? updatedAt,
}) {
  return LessonProgress(
    courseId: courseId,
    lessonId: lessonId,
    position: Duration(seconds: positionSec),
    isCompleted: isCompleted,
    updatedAt: updatedAt ?? DateTime(2026),
  );
}

Map<String, LessonProgress> byKey(List<LessonProgress> items) {
  return <String, LessonProgress>{for (final LessonProgress item in items) item.key: item};
}

void main() {
  group('reachedCompletion', () {
    const Duration duration = Duration(seconds: 100);

    test('is false below 90%', () {
      expect(ProgressRules.reachedCompletion(position: const Duration(seconds: 89), duration: duration), isFalse);
    });

    test('is true at exactly 90% and above', () {
      expect(ProgressRules.reachedCompletion(position: const Duration(seconds: 90), duration: duration), isTrue);
      expect(ProgressRules.reachedCompletion(position: duration, duration: duration), isTrue);
    });

    test('is false when the duration is unknown', () {
      expect(ProgressRules.reachedCompletion(position: Duration.zero, duration: Duration.zero), isFalse);
    });
  });

  group('isUnlocked', () {
    test('first lesson is always unlocked', () {
      expect(ProgressRules.isUnlocked(course, l1, <String, LessonProgress>{}), isTrue);
    });

    test('a lesson is locked until the previous one is completed', () {
      expect(ProgressRules.isUnlocked(course, l2, byKey(<LessonProgress>[progress('l1', positionSec: 50)])), isFalse);
      expect(ProgressRules.isUnlocked(course, l2, byKey(<LessonProgress>[progress('l1', isCompleted: true)])), isTrue);
    });

    test('unlock carries across sections', () {
      expect(ProgressRules.isUnlocked(course, l3, byKey(<LessonProgress>[progress('l1', isCompleted: true)])), isFalse);
      expect(ProgressRules.isUnlocked(course, l3, byKey(<LessonProgress>[progress('l2', isCompleted: true)])), isTrue);
    });

    test('completing the same lesson id in another course does not unlock', () {
      expect(
        ProgressRules.isUnlocked(course, l2, byKey(<LessonProgress>[progress('l1', courseId: 'c2', isCompleted: true)])),
        isFalse,
      );
    });
  });

  group('courseProgress', () {
    test('is completed lessons over total lessons', () {
      final Map<String, LessonProgress> items = byKey(<LessonProgress>[
        progress('l1', isCompleted: true),
        progress('l2', positionSec: 50),
      ]);
      expect(ProgressRules.courseProgress(course, items), closeTo(1 / 3, 0.0001));
    });

    test('is 0 for a course with no lessons', () {
      const Course empty = Course(id: 'c2', title: '', instructor: '', thumbnail: '', sections: <Section>[]);
      expect(ProgressRules.courseProgress(empty, <String, LessonProgress>{}), 0);
    });
  });

  group('lessonStatus', () {
    test('maps progress to a status', () {
      expect(ProgressRules.lessonStatus(null), LessonStatus.notStarted);
      expect(ProgressRules.lessonStatus(progress('l1', positionSec: 0)), LessonStatus.notStarted);
      expect(ProgressRules.lessonStatus(progress('l1')), LessonStatus.inProgress);
      expect(ProgressRules.lessonStatus(progress('l1', isCompleted: true)), LessonStatus.completed);
    });
  });

  group('resumePosition', () {
    const Duration duration = Duration(seconds: 100);

    test('resumes from the saved position', () {
      expect(ProgressRules.resumePosition(progress('l1', positionSec: 40), duration), const Duration(seconds: 40));
    });

    test('restarts from 0 when the saved position is near the end', () {
      expect(ProgressRules.resumePosition(progress('l1', positionSec: 95, isCompleted: true), duration), Duration.zero);
    });
  });

  group('nextLesson', () {
    test('crosses sections and returns null after the last lesson', () {
      expect(ProgressRules.nextLesson(course, l2), l3);
      expect(ProgressRules.nextLesson(course, l3), isNull);
    });
  });

  group('continueWatching', () {
    test('returns the most recently watched unfinished lesson', () {
      final Map<String, LessonProgress> items = byKey(<LessonProgress>[
        progress('l1', updatedAt: DateTime(2026, 1, 1)),
        progress('l2', updatedAt: DateTime(2026, 1, 2)),
        progress('l3', isCompleted: true, updatedAt: DateTime(2026, 1, 3)),
      ]);
      expect(ProgressRules.continueWatching(<Course>[course], items)?.lesson, l2);
    });

    test('ignores progress for lessons that no longer exist', () {
      final Map<String, LessonProgress> items = byKey(<LessonProgress>[progress('removed')]);
      expect(ProgressRules.continueWatching(<Course>[course], items), isNull);
    });
  });
}
