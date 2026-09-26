import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/features/progress/data/models/lesson_progress.dart';

class ProgressLocalSource {
  const ProgressLocalSource(this._prefs);

  static const String _progressKey = 'lesson_progress';

  final SharedPreferences _prefs;

  List<LessonProgress> readAll() {
    final String? raw = _prefs.getString(_progressKey);
    if (raw == null) return <LessonProgress>[];
    return (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(LessonProgress.fromJson)
        .toList();
  }

  Future<void> writeAll(List<LessonProgress> progress) async {
    await _prefs.setString(_progressKey, jsonEncode(progress));
  }
}
