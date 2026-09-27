import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:thaheen_task/features/courses/ui/screens/course_details_screen.dart';
import 'package:thaheen_task/features/courses/ui/screens/courses_screen.dart';
import 'package:thaheen_task/features/player/ui/screens/lesson_player_screen.dart';

abstract final class AppRoutes {
  static const String courses = '/';

  static String courseDetails(String courseId) => '/courses/$courseId';

  static String lesson(String courseId, String lessonId) =>
      '/courses/$courseId/lessons/$lessonId';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.courses,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.courses,
      builder: (BuildContext context, GoRouterState state) =>
          const CoursesScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'courses/:courseId',
          builder: (BuildContext context, GoRouterState state) {
            return CourseDetailsScreen(
              courseId: state.pathParameters['courseId']!,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'lessons/:lessonId',
              builder: (BuildContext context, GoRouterState state) {
                return LessonPlayerScreen(
                  courseId: state.pathParameters['courseId']!,
                  lessonId: state.pathParameters['lessonId']!,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
