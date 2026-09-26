import 'package:thaheen_task/features/progress/data/local/progress_local_source.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';

class ProgressRepo {
  const ProgressRepo(this._localSource);

  final ProgressLocalSource _localSource;

  Map<String, LessonProgress> loadProgress() {
    try {
      return <String, LessonProgress>{
        for (final LessonProgress progress in _localSource.readAll()) progress.key: progress,
      };
    } catch (_) {
      return <String, LessonProgress>{};
    }
  }

  Future<void> saveProgress(Map<String, LessonProgress> progress) {
    return _localSource.writeAll(progress.values.toList());
  }
}
