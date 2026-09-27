import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thaheen_task/features/courses/data/models/lesson.dart';
import 'package:thaheen_task/features/player/data/repo/player_settings_repo.dart';
import 'package:thaheen_task/features/player/logic/player_state.dart';
import 'package:thaheen_task/features/progress/logic/progress_cubit.dart';
import 'package:thaheen_task/features/progress/logic/progress_rules.dart';
import 'package:video_player/video_player.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this.courseId,
    required this.lesson,
    required this._progressCubit,
    required this._settingsRepo,
  }) : _speed = _savedSpeedOrDefault(_settingsRepo.loadSpeed()),
       super(const PlayerState.loading());

  static const List<double> speeds = <double>[1, 1.25, 1.5, 2];
  static const Duration _saveInterval = Duration(seconds: 5);

  final String courseId;
  final Lesson lesson;
  final ProgressCubit _progressCubit;
  final PlayerSettingsRepo _settingsRepo;

  VideoPlayerController? _controller;
  DateTime _lastSavedAt = DateTime.fromMillisecondsSinceEpoch(0);
  double _speed;

  VideoPlayerController? get controller => _controller;

  static double _savedSpeedOrDefault(double? savedSpeed) {
    return speeds.contains(savedSpeed) ? savedSpeed! : speeds.first;
  }

  Future<void> initialize() async {
    emit(const PlayerState.loading());
    await _disposeController();

    final VideoPlayerController controller = VideoPlayerController.asset(
      lesson.video,
    );
    _controller = controller;
    try {
      await controller.initialize();
      final Duration resumeAt = ProgressRules.resumePosition(
        _progressCubit.progressOf(courseId, lesson.id),
        controller.value.duration,
      );
      await controller.seekTo(resumeAt);
      await controller.setPlaybackSpeed(_speed);
      if (isClosed) return;
      controller.addListener(_onControllerChanged);
      _onControllerChanged();
      await controller.play();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      if (!isClosed) emit(const PlayerState.error());
    }
  }

  Future<void> togglePlay() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final VideoPlayerValue value = controller.value;
    if (value.isPlaying) {
      await controller.pause();
      await saveProgress();
      return;
    }
    if (value.position >= value.duration) {
      await controller.seekTo(Duration.zero);
    }
    await controller.play();
  }

  Future<void> play() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.play();
  }

  Future<void> pause() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.pause();
    await saveProgress();
  }

  Future<void> seekTo(Duration position) async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.seekTo(position);
    await saveProgress();
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _controller?.setPlaybackSpeed(speed);
    try {
      await _settingsRepo.saveSpeed(speed);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<void> saveProgress() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    _lastSavedAt = DateTime.now();
    await _progressCubit.savePosition(
      courseId: courseId,
      lessonId: lesson.id,
      position: controller.value.position,
      duration: controller.value.duration,
    );
  }

  void _onControllerChanged() {
    final VideoPlayerController? controller = _controller;
    if (controller == null || isClosed) return;
    final VideoPlayerValue value = controller.value;
    if (value.hasError) {
      emit(const PlayerState.error());
      return;
    }
    if (!value.isInitialized) return;

    emit(
      PlayerState.ready(
        position: value.position,
        duration: value.duration,
        isPlaying: value.isPlaying,
        isBuffering: value.isBuffering,
        speed: value.playbackSpeed,
      ),
    );

    final bool wasCompleted =
        _progressCubit.progressOf(courseId, lesson.id)?.isCompleted ?? false;
    final bool justCompleted =
        !wasCompleted &&
        ProgressRules.reachedCompletion(
          position: value.position,
          duration: value.duration,
        );
    final bool isSaveDue =
        value.isPlaying &&
        DateTime.now().difference(_lastSavedAt) >= _saveInterval;
    if (justCompleted || isSaveDue) saveProgress();
  }

  Future<void> _disposeController() async {
    final VideoPlayerController? controller = _controller;
    _controller = null;
    if (controller == null) return;
    controller.removeListener(_onControllerChanged);
    await controller.dispose();
  }

  @override
  Future<void> close() async {
    await saveProgress();
    await _disposeController();
    return super.close();
  }
}
