import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/features/notes/data/models/lesson_note.dart';

class NotesLocalSource {
  const NotesLocalSource(this._prefs);

  static const String _notesKey = 'lesson_notes';

  final SharedPreferences _prefs;

  List<LessonNote> readAll() {
    final String? raw = _prefs.getString(_notesKey);
    if (raw == null) return <LessonNote>[];
    return (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(LessonNote.fromJson)
        .toList();
  }

  Future<void> writeAll(List<LessonNote> notes) async {
    await _prefs.setString(_notesKey, jsonEncode(notes));
  }
}
