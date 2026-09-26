import 'package:go_router/go_router.dart';
import 'package:thaheen_task/features/courses/ui/screens/courses_screen.dart';

abstract final class AppRoutes {
  static const courses = '/';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.courses,
  routes: [
    GoRoute(
      path: AppRoutes.courses,
      builder: (context, state) => const CoursesScreen(),
    ),
  ],
);
