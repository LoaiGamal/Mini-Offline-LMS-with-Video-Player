import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'shows lesson statuses and explains why a locked lesson cannot open',
    (WidgetTester tester) async {
      await pumpApp(
        tester,
        progress: <Map<String, Object>>[
          lessonProgress('l1', positionSec: 115, isCompleted: true),
        ],
      );

      await tester.tap(find.text('مقدمة في التشريح'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.statusCompleted), findsOneWidget);
      expect(find.text(AppStrings.statusNotStarted), findsOneWidget);
      expect(find.text(AppStrings.statusLocked), findsNWidgets(3));

      await tester.tap(find.text('الغضاريف'));
      await tester.pump();

      expect(find.text(AppStrings.lockedLesson('المفاصل')), findsOneWidget);
    },
  );
}
