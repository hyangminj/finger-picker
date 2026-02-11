// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:finger_picker_flutter/main.dart';

void main() {
  testWidgets('Finger Picker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FingerPickerApp());
    // Use pump() instead of pumpAndSettle() because app has infinite animations
    await tester.pump();

    // Get the localization instance for the test locale (English by default)
    final BuildContext context = tester.element(find.byType(Scaffold));
    final l10n = AppLocalizations.of(context)!;

    // Verify that the prompt text is displayed
    expect(find.text(l10n.placeYourFingers), findsOneWidget);
    expect(find.text(l10n.oneWillBeChosen), findsOneWidget);
  });
}
