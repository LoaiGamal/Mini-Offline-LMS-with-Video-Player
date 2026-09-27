import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/main.dart';

Map<String, Object> lessonProgress(
  String lessonId, {
  required int positionSec,
  required bool isCompleted,
  String courseId = 'anatomy-101',
}) {
  return <String, Object>{
    'courseId': courseId,
    'lessonId': lessonId,
    'position': Duration(seconds: positionSec).inMicroseconds,
    'isCompleted': isCompleted,
    'updatedAt': DateTime(2026, 9, 1).toIso8601String(),
  };
}

Future<void> pumpApp(
  WidgetTester tester, {
  List<Map<String, Object>> progress = const <Map<String, Object>>[],
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'lesson_progress': jsonEncode(progress),
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.runAsync(() async {
    await tester.pumpWidget(ThaheenApp(prefs: prefs));
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pumpAndSettle();
}
