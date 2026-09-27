import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thaheen_task/core/components/app_button.dart';
import 'package:thaheen_task/core/components/app_icon_button.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';
import 'package:thaheen_task/core/utils/duration_format.dart';
import 'package:thaheen_task/features/notes/data/models/lesson_note.dart';
import 'package:thaheen_task/features/notes/logic/notes_cubit.dart';
import 'package:thaheen_task/features/notes/logic/notes_state.dart';
import 'package:thaheen_task/features/notes/ui/widgets/note_tile.dart';

Future<void> showNotesSheet(
  BuildContext context, {
  required String courseId,
  required String lessonId,
  required String lessonTitle,
  required Duration position,
  required ValueChanged<Duration> onJump,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    builder: (BuildContext context) => NotesSheet(
      courseId: courseId,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      position: position,
      onJump: onJump,
    ),
  );
}

class NotesSheet extends StatefulWidget {
  const NotesSheet({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.lessonTitle,
    required this.position,
    required this.onJump,
  });

  final String courseId;
  final String lessonId;
  final String lessonTitle;
  final Duration position;
  final ValueChanged<Duration> onJump;

  @override
  State<NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends State<NotesSheet> {
  static const Duration _undoDuration = Duration(seconds: 4);

  final TextEditingController _controller = TextEditingController();
  LessonNote? _deletedNote;
  Timer? _undoTimer;

  @override
  void dispose() {
    _controller.dispose();
    _undoTimer?.cancel();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<NotesCubit>().addNote(
      courseId: widget.courseId,
      lessonId: widget.lessonId,
      position: widget.position,
      text: _controller.text,
    );
    _controller.clear();
  }

  void _delete(LessonNote note) {
    context.read<NotesCubit>().deleteNote(note.id);
    _undoTimer?.cancel();
    setState(() => _deletedNote = note);
    _undoTimer = Timer(_undoDuration, () {
      if (mounted) setState(() => _deletedNote = null);
    });
  }

  void _undoDelete() {
    final LessonNote? note = _deletedNote;
    if (note == null) return;
    _undoTimer?.cancel();
    context.read<NotesCubit>().restoreNote(note);
    setState(() => _deletedNote = null);
  }

  void _jump(Duration position) {
    Navigator.of(context).pop();
    widget.onJump(position);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.65,
        child: BlocBuilder<NotesCubit, NotesState>(
          builder: (BuildContext context, NotesState state) {
            final List<LessonNote> notes = context.read<NotesCubit>().notesFor(
              widget.courseId,
              widget.lessonId,
            );
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildHeader(context, notes.length),
                  const SizedBox(height: 16),
                  _buildComposer(context),
                  const SizedBox(height: 16),
                  Expanded(
                    child: notes.isEmpty
                        ? const _NotesEmpty()
                        : ListView.separated(
                            itemCount: notes.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(height: 10),
                            itemBuilder: (BuildContext context, int index) {
                              final LessonNote note = notes[index];
                              return NoteTile(
                                note: note,
                                onJump: () => _jump(note.position),
                                onDelete: () => _delete(note),
                              );
                            },
                          ),
                  ),
                  if (_deletedNote != null) _buildUndoBar(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int notesCount) {
    final ThemeData theme = Theme.of(context);
    final String subtitle = notesCount == 0
        ? widget.lessonTitle
        : '${widget.lessonTitle} · ${AppStrings.notesCount(notesCount)}';

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppStrings.myNotes, style: theme.textTheme.titleMedium),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppIconButton(
          icon: Icons.close_rounded,
          tooltip: AppStrings.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildComposer(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.outlineVariant),
    );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: AppStrings.noteHint,
                border: border,
                enabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                _TimeChip(time: formatDuration(widget.position)),
                const Spacer(),
                AppButton(
                  label: AppStrings.saveNote,
                  onPressed: value.text.trim().isEmpty ? null : _save,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildUndoBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 4, 4),
      decoration: BoxDecoration(
        color: colors.inverseSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Semantics(
        liveRegion: true,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                AppStrings.noteDeleted,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onInverseSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: _undoDelete,
              style: TextButton.styleFrom(foregroundColor: colors.secondary),
              child: const Text(AppStrings.undo),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.schedule_rounded,
            size: 14,
            color: colors.onTertiaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            AppStrings.noteAt(time),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesEmpty extends StatelessWidget {
  const _NotesEmpty();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(AppStrings.noNotesTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              AppStrings.noNotesMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
