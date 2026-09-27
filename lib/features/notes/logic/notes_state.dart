import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:thaheen_task/features/notes/data/models/lesson_note.dart';

part 'notes_state.freezed.dart';

@freezed
abstract class NotesState with _$NotesState {
  const factory NotesState({required List<LessonNote> notes}) = _NotesState;
}
