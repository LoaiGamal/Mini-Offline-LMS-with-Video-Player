import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/core/utils/duration_format.dart';

void main() {
  test('formats minutes and seconds', () {
    expect(formatDuration(Duration.zero), '0:00');
    expect(formatDuration(const Duration(seconds: 54)), '0:54');
    expect(formatDuration(const Duration(minutes: 9, seconds: 50)), '9:50');
  });

  test('adds hours when needed', () {
    expect(formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
  });

  test('treats negative durations as zero', () {
    expect(formatDuration(const Duration(seconds: -5)), '0:00');
  });
}
