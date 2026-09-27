import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'shows continue watching and hides it while searching by lesson title',
    (WidgetTester tester) async {
      await pumpApp(
        tester,
        progress: <Map<String, Object>>[
          lessonProgress('l1', positionSec: 115, isCompleted: true),
          lessonProgress('l2', positionSec: 60, isCompleted: false),
        ],
      );

      expect(find.text(AppStrings.continueWatching), findsOneWidget);
      expect(find.text('المفاصل'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'القلب');
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.continueWatching), findsNothing);
      expect(find.text(AppStrings.searchResults), findsOneWidget);
      expect(find.text('أساسيات علم وظائف الأعضاء'), findsOneWidget);
      expect(find.text('مقدمة في التشريح'), findsNothing);
    },
  );
}
