// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kartu_profil_digital/main.dart';
import 'package:kartu_profil_digital/services/pref_service.dart';

void main() {
  test('dark mode preference defaults to false and can be saved', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PrefService.init();

    expect(prefs.isDarkMode, isFalse);

    await prefs.setDarkMode(true);

    expect(prefs.isDarkMode, isTrue);
  });

  testWidgets('shows the profile and persisted app open count', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'open_count': 2,
      'is_dark_mode': true,
    });
    final prefs = await PrefService.init();
    await prefs.increaseOpenCount();

    await tester.pumpWidget(MyApp(prefs: prefs));

    expect(find.text('Kartu Profil Digital'), findsOneWidget);
    expect(find.text('Kartu ini sudah dibuka 3 kali'), findsOneWidget);
    expect(find.text('Mode Gelap'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    expect(prefs.isDarkMode, isFalse);
  });
}
