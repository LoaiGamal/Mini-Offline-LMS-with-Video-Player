import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:thaheen_task/core/constants/app_assets.dart';
import 'package:thaheen_task/features/courses/data/models/course.dart';

class CoursesLocalSource {
  const CoursesLocalSource();

  Future<List<Course>> loadCourses() async {
    final String raw = await rootBundle.loadString(AppAssets.coursesJson);
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['courses'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Course.fromJson)
        .toList();
  }

  Future<Set<String>> loadAssetPaths() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().toSet();
  }
}
