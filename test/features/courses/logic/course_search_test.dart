import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/courses/data/models/section.dart';
import 'package:thaheen_task/features/courses/logic/course_search.dart';

const Course anatomy = Course(
  id: 'anatomy',
  title: 'مقدمة في التشريح',
  instructor: 'د. سارة',
  thumbnail: '',
  sections: <Section>[
    Section(
      id: 's1',
      title: 'الجهاز الهيكلي',
      lessons: <Lesson>[
        Lesson(id: 'l1', title: 'العظام', durationSec: 60, video: ''),
      ],
    ),
  ],
);

const Course physiology = Course(
  id: 'physiology',
  title: 'أساسيات علم وظائف الأعضاء',
  instructor: 'د. أحمد',
  thumbnail: '',
  sections: <Section>[
    Section(
      id: 's1',
      title: 'الجهاز الدوري',
      lessons: <Lesson>[
        Lesson(id: 'l1', title: 'القلب', durationSec: 60, video: ''),
      ],
    ),
  ],
);

const List<Course> courses = <Course>[anatomy, physiology];

void main() {
  test('an empty query returns every course', () {
    expect(CourseSearch.filter(courses, '   '), courses);
  });

  test('matches the course title, instructor and lesson titles', () {
    expect(CourseSearch.filter(courses, 'التشريح'), <Course>[anatomy]);
    expect(CourseSearch.filter(courses, 'أحمد'), <Course>[physiology]);
    expect(CourseSearch.filter(courses, 'القلب'), <Course>[physiology]);
  });

  test('ignores diacritics and alef variants', () {
    expect(CourseSearch.filter(courses, 'اساسيات'), <Course>[physiology]);
    expect(CourseSearch.filter(courses, 'العِظَام'), <Course>[anatomy]);
  });

  test('returns nothing when no course matches', () {
    expect(CourseSearch.filter(courses, 'كيمياء'), isEmpty);
  });
}
