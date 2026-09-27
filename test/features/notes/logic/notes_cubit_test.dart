import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/features/notes/data/local/notes_local_source.dart';
import 'package:thaheen_task/features/notes/data/models/lesson_note.dart';
import 'package:thaheen_task/features/notes/data/repo/notes_repo.dart';
import 'package:thaheen_task/features/notes/logic/notes_cubit.dart';

Future<NotesCubit> createCubit() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return NotesCubit(NotesRepo(NotesLocalSource(prefs)));
}

Future<void> addNote(NotesCubit cubit, int seconds, String text) {
  return cubit.addNote(
    courseId: 'c1',
    lessonId: 'l1',
    position: Duration(seconds: seconds),
    text: text,
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('notes survive an app restart', () async {
    await addNote(await createCubit(), 42, 'ملاحظة');

    final List<LessonNote> notes = (await createCubit()).notesFor('c1', 'l1');
    expect(notes.single.text, 'ملاحظة');
    expect(notes.single.position, const Duration(seconds: 42));
  });

  test('notes are sorted by video time and scoped to their lesson', () async {
    final NotesCubit cubit = await createCubit();
    await addNote(cubit, 60, 'later');
    await addNote(cubit, 10, 'earlier');
    await cubit.addNote(
      courseId: 'c2',
      lessonId: 'l1',
      position: Duration.zero,
      text: 'other course',
    );

    expect(
      cubit.notesFor('c1', 'l1').map((LessonNote note) => note.text),
      <String>['earlier', 'later'],
    );
  });

  test('blank notes are ignored and text is trimmed', () async {
    final NotesCubit cubit = await createCubit();
    await addNote(cubit, 0, '   ');
    await addNote(cubit, 0, '  نص  ');
    expect(cubit.notesFor('c1', 'l1').single.text, 'نص');
  });

  test('a deleted note can be restored', () async {
    final NotesCubit cubit = await createCubit();
    await addNote(cubit, 5, 'note');
    final LessonNote note = cubit.notesFor('c1', 'l1').single;

    await cubit.deleteNote(note.id);
    expect(cubit.notesFor('c1', 'l1'), isEmpty);

    await cubit.restoreNote(note);
    expect(cubit.notesFor('c1', 'l1').single.id, note.id);
  });

  test('corrupt saved notes start fresh instead of crashing', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'lesson_notes': 'not json',
    });
    expect((await createCubit()).state.notes, isEmpty);
  });
}
