import 'package:thaheen_task/features/notes/data/local/notes_local_source.dart';
import 'package:thaheen_task/features/notes/data/models/lesson_note.dart';

class NotesRepo {
  const NotesRepo(this._localSource);

  final NotesLocalSource _localSource;

  List<LessonNote> loadNotes() {
    try {
      return _localSource.readAll();
    } catch (_) {
      return <LessonNote>[];
    }
  }

  Future<void> saveNotes(List<LessonNote> notes) {
    return _localSource.writeAll(notes);
  }
}
