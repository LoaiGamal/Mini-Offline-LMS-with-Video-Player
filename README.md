# Thaheen – Mini Offline LMS

A small, fully offline, Arabic-first (RTL) learning app built for the Thaheen Flutter screening task. Students browse courses, watch video lessons that unlock in order, and their progress survives app restarts.

## How to run

Built and tested with **Flutter 3.44.9 (stable) / Dart 3.12.2**.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The `build_runner` step generates the `*.g.dart` (json_serializable) and `*.freezed.dart` (Freezed) files. Run it again after changing a model or a Cubit state.

Run the tests:

```bash
flutter test
```

## Features

### Required

- **Courses screen:** thumbnail, title, instructor, lesson count and progress % per course, plus a **Continue watching** card for the most recently watched unfinished lesson.
- **Course details:** sections and lessons with durations and a status (not started / in progress / completed). Lessons **unlock sequentially** across the whole course, including across sections; tapping a locked lesson explains which lesson to finish first.
- **Lesson player:** play/pause, an RTL seek bar, current time / duration, speed (1x / 1.25x / 1.5x / 2x), fullscreen landscape, resume from the last position, **auto-complete at 90%**, and a **Next lesson** button that respects the unlock rule.
- **Persistence:** positions, completed lessons, speed, theme and notes all survive a restart.
- **Arabic-first RTL UI** with bundled Arabic fonts (works fully offline).
- **Loading, empty and error states** everywhere, with no red screens. One lesson intentionally points to a missing video to demonstrate the playback error state.
- **Unit tests** for the progress logic, plus a few more (see [Tests](#tests)).

### Bonus

- Dark mode (follows the system until the user picks a theme; the choice is saved).
- Course search, Arabic-aware: ignores diacritics and treats أ/إ/آ, ة/ه and ى/ي as the same letter. It also matches lesson titles, so «القلب» finds the physiology course.
- Per-lesson notes saved locally, each tied to the video time; tapping a note's time jumps the video there.
- The last playback speed is remembered across lessons and restarts.
- Two widget tests covering the unlock rule, statuses, Continue watching and search end to end.

Not done: the Arabic/English switch. The app is intentionally Arabic-only (see [Trade-offs](#trade-offs)).

## Architecture

Feature-first folders, each split into `data` / `logic` / `ui`, with shared pieces in `core`. Kept deliberately small: no DI container, no use-case layer.

```
lib/
  core/
    components/   shared UI (AppCard, AppButton, AppProgressBar, EmptyView, ErrorView, ...)
    constants/    Arabic strings (with plural rules) and asset paths
    router/       go_router config
    theme/        light/dark themes + ThemeCubit
    utils/        duration and speed formatting
  features/
    courses/      data (models, JSON local source, repo) · logic (CoursesCubit, CourseSearch) · ui
    progress/     data (LessonProgress, storage) · logic (ProgressCubit, ProgressRules)
    player/       data (saved speed) · logic (PlayerCubit) · ui (player screen, custom controls)
    notes/        data · logic (NotesCubit) · ui (notes bottom sheet)
  main.dart       loads SharedPreferences, provides app-level cubits, fixes locale to ar
```

- **Repos** hide storage details and keep bad data from crashing the app. `CoursesRepo` validates IDs and reports which video files are missing from the bundle; the progress, notes and settings repos fall back to empty/defaults when the stored data is corrupt.
- **`ProgressRules`** holds every business rule as plain Dart functions with no Flutter imports: the 90% rule, unlocking, progress %, lesson status, resume position, next lesson and Continue watching. The screens call these instead of re-implementing the rules, and they are easy to unit test.
- **App-level state:** `CoursesCubit`, `ProgressCubit`, `NotesCubit` and `ThemeCubit` are provided once in `main.dart`. `ProgressCubit` is the single source of truth, so leaving the player updates the details screen and the courses list automatically.
- **Per-screen state:** `PlayerCubit` is created per lesson and owns its `VideoPlayerController`.
- **Navigation:** go_router with nested routes (`/courses/:courseId/lessons/:lessonId`), so back navigation works naturally.

### State management: Cubit + Freezed

Cubit keeps state changes explicit and easy to follow without the ceremony of events, which suits an app this size. States are **sealed Freezed unions** (e.g. `loading | loaded | empty | error`), so every screen handles every case in an exhaustive `switch`; a missed state is a compile error, not a red screen. Models use **json_serializable** instead of hand-written `fromJson`.

### Storage: SharedPreferences

The data is tiny and key-value shaped: a map of lesson progress, a list of notes, one speed and one theme value. SharedPreferences is simple, synchronous to read once loaded, and needs no schema or migrations. Hive/Isar/sqflite would add setup and generated adapters with no real benefit here. Each group of data is stored as a single JSON value (`lesson_progress`, `lesson_notes`, `playback_speed`, `theme_mode`).

If the data grew (many courses, sync with a backend, querying), I would move to sqflite or Drift.

## Key decisions and edge cases

- **90% rule:** a lesson completes when the **playback position reaches ≥ 90%** of the real video duration (read from the player, not the JSON). Seeking to the end counts, which is simpler and predictable; tracking actually-watched time would be stricter (see [What I'd do with more time](#what-id-do-with-more-time)).
- **Progress is saved** every 5 s while playing, immediately when crossing 90% (so Next lesson unlocks instantly), and on pause, seek, app backgrounding and leaving the screen. Killing the app mid-lesson still resumes close to where you were.
- **Completed stays completed.** Rewatching a completed lesson restarts from 0 if its saved position is past 90%, and it never becomes locked again.
- **Progress keys are `courseId/lessonId`.** The JSON reuses lesson IDs like `l1` across courses on purpose; keying by lesson ID alone would let one course's progress unlock another's lessons (this is covered by a test).
- **Course progress % = completed lessons / total lessons.** A course with no lessons shows a dedicated empty state.
- **RTL player:** the seek bar fills from the right, and times are shown as `0:54 / 2:00` in left-to-right order so they read correctly inside Arabic text. The video keeps its real aspect ratio (the clips are a mix of 16:9 and 4:3).
- **Fullscreen** always restores portrait and the system bars when leaving: via the exit button, the back gesture, or navigating away. The rest of the app is locked to portrait.
- **Deep links are guarded:** opening a locked or unknown lesson directly shows a message instead of playing it.
- **Missing or corrupt videos** are detected up front (the lesson shows "unavailable" in the list) and the player shows a retry-able error instead of crashing.

## Tests

`flutter test` runs 38 tests:

| Area | File | What it covers |
|---|---|---|
| Progress rules | `test/features/progress/logic/progress_rules_test.dart` | 90% boundary, unlock rule (incl. across sections and across courses with the same lesson ID), progress %, statuses, resume position, next lesson, Continue watching |
| Progress persistence | `test/features/progress/logic/progress_cubit_test.dart` | survives a restart, completed stays completed, corrupt data |
| Search | `test/features/courses/logic/course_search_test.dart` | title/instructor/lesson matches, Arabic normalisation |
| Notes | `test/features/notes/logic/notes_cubit_test.dart` | persistence, ordering, blank notes, delete + undo, corrupt data |
| Speed, theme, formatting | `player_settings_repo_test.dart`, `theme_cubit_test.dart`, `duration_format_test.dart` | persistence and fallbacks |
| Widget tests | `test/features/courses/ui/screens/` | the real app with seeded progress: statuses + locked-lesson message; Continue watching + search |

## Trade-offs

- **Arabic-only, no language switch.** The product is Arabic-first; supporting English properly would also mean bilingual course data in the JSON, so I left it out rather than translate only the UI chrome. `flutter_localizations` is used only so Material widgets render in Arabic with RTL.
- **`PlayerCubit` holds the `VideoPlayerController`**, a Flutter object inside the logic layer. Keeping it in the widget would split playback state between two places, so I accepted the trade-off.
- **No unit tests for `PlayerCubit`**, because `VideoPlayerController` needs a real platform or a mocked video platform. The rules it relies on are fully tested, and the player was tested manually on the iOS simulator.
- **Custom player controls instead of chewie**, to get a correct RTL seek bar, exactly the required speeds, and a design that matches the rest of the app.
- **Whole-value writes:** each save rewrites the full JSON for that data group. That's fine at this size; a real app would store rows individually.

## Known issues
- **Video topics don't match lesson titles.** Only three clips are bundled (brain, hearing, digestion) and they are reused across all lessons, so for example the "bones" lesson plays the brain clip.
- Deleting a note shows its undo inside the notes sheet rather than as a normal snackbar, because a snackbar would be hidden behind the open sheet.

## What I'd do with more time

- Track *actually watched* time for the 90% rule, so seeking to the end doesn't count as completion.
- Replace the placeholder assets with properly licensed, topic-matched videos and images.
- Add the Arabic/English switch with bilingual course data.
- Unit-test `PlayerCubit` with a fake video platform, and add golden tests for the main screens in light and dark.
- Test on physical Android and iOS devices, including low-end Android performance.
- Accessibility pass with TalkBack/VoiceOver on real devices.

## Time spent

Roughly **9 hours** of work, because I also completed the bonus tasks.
