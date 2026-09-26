import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/features/progress/data/local/progress_local_source.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';
import 'package:thaheen_task/features/progress/data/repo/progress_repo.dart';
import 'package:thaheen_task/features/progress/logic/progress_cubit.dart';

Future<ProgressCubit> createCubit() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return ProgressCubit(ProgressRepo(ProgressLocalSource(prefs)));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('progress survives an app restart', () async {
    final ProgressCubit cubit = await createCubit();
    await cubit.savePosition(
      courseId: 'c1',
      lessonId: 'l1',
      position: const Duration(seconds: 42),
      duration: const Duration(seconds: 100),
    );

    final ProgressCubit restarted = await createCubit();
    final LessonProgress? restored = restarted.progressOf('c1', 'l1');
    expect(restored?.position, const Duration(seconds: 42));
    expect(restored?.isCompleted, isFalse);
  });

  test('a lesson completes at 90% and stays completed when rewatched', () async {
    final ProgressCubit cubit = await createCubit();
    await cubit.savePosition(
      courseId: 'c1',
      lessonId: 'l1',
      position: const Duration(seconds: 90),
      duration: const Duration(seconds: 100),
    );
    expect(cubit.progressOf('c1', 'l1')?.isCompleted, isTrue);

    await cubit.savePosition(
      courseId: 'c1',
      lessonId: 'l1',
      position: const Duration(seconds: 5),
      duration: const Duration(seconds: 100),
    );
    expect(cubit.progressOf('c1', 'l1')?.isCompleted, isTrue);
  });

  test('corrupt saved data starts fresh instead of crashing', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'lesson_progress': 'not json'});
    final ProgressCubit cubit = await createCubit();
    expect(cubit.state.lessons, isEmpty);
  });
}
