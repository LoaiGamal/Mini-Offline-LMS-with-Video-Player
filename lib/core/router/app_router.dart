import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:thaheen_task/features/courses/ui/screens/courses_screen.dart';

abstract final class AppRoutes {
  static const String courses = '/';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.courses,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.courses,
      builder: (BuildContext context, GoRouterState state) => const CoursesScreen(),
    ),
  ],
);
