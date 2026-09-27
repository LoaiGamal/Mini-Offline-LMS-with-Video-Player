import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thaheen_task/features/notes/data/models/lesson_note.dart';
import 'package:thaheen_task/features/notes/data/repo/notes_repo.dart';
import 'package:thaheen_task/features/notes/logic/notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repo) : super(NotesState(notes: _repo.loadNotes()));

  final NotesRepo _repo;

  List<LessonNote> notesFor(String courseId, String lessonId) {
    return state.notes
        .where(
          (LessonNote note) =>
              note.courseId == courseId && note.lessonId == lessonId,
        )
        .toList()
      ..sort((LessonNote a, LessonNote b) {
        final int byPosition = a.position.compareTo(b.position);
        return byPosition != 0
            ? byPosition
            : a.createdAt.compareTo(b.createdAt);
      });
  }

  Future<void> addNote({
    required String courseId,
    required String lessonId,
    required Duration position,
    required String text,
  }) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final DateTime now = DateTime.now();
    final LessonNote note = LessonNote(
      id: now.microsecondsSinceEpoch.toString(),
      courseId: courseId,
      lessonId: lessonId,
      position: position,
      text: trimmed,
      createdAt: now,
    );
    await _update(<LessonNote>[...state.notes, note]);
  }

  Future<void> deleteNote(String id) async {
    await _update(
      state.notes.where((LessonNote note) => note.id != id).toList(),
    );
  }

  Future<void> restoreNote(LessonNote note) async {
    await _update(<LessonNote>[...state.notes, note]);
  }

  Future<void> _update(List<LessonNote> notes) async {
    emit(state.copyWith(notes: notes));
    try {
      await _repo.saveNotes(notes);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}
