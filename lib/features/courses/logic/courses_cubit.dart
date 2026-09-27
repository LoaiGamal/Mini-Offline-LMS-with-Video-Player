import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';
import 'package:thaheen_task/features/courses/data/repo/courses_repo.dart';
import 'package:thaheen_task/features/courses/logic/courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit(this._repo) : super(const CoursesState.loading());

  final CoursesRepo _repo;

  Future<void> loadCourses() async {
    emit(const CoursesState.loading());
    try {
      final List<Course> courses = await _repo.getCourses();
      if (courses.isEmpty) {
        emit(const CoursesState.empty());
        return;
      }
      final Set<String> missingVideos = await _repo.findMissingVideos(courses);
      emit(CoursesState.loaded(courses: courses, missingVideos: missingVideos));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const CoursesState.error());
    }
  }

  void search(String query) {
    final CoursesState state = this.state;
    if (state is CoursesLoaded) emit(state.copyWith(query: query));
  }
}
