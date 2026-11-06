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
import 'package:kartu_profil_digital/models/profile_data.dart';
import 'package:kartu_profil_digital/services/pref_service.dart';

void main() {
  test('profile data round-trips through JSON', () {
    const profile = ProfileData(
      name: 'Test User',
      title: 'Developer',
      bio: 'Builds apps',
    );

    expect(ProfileData.fromJson(profile.toJson()).toMap(), profile.toMap());
  });

  test('profile data map uses defaults for missing fields', () {
    expect(ProfileData.fromMap({}).toMap(), ProfileData.defaults.toMap());
  });

  test('profile preference can be saved, loaded, and cleared', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PrefService.init();
    const profile = ProfileData(
      name: 'Test User',
      title: 'Developer',
      bio: 'Builds apps',
    );

    expect(prefs.profile.toMap(), ProfileData.defaults.toMap());

    await prefs.saveProfile(profile);
    expect(prefs.profile.toMap(), profile.toMap());

    await prefs.clearProfile();
    expect(prefs.profile.toMap(), ProfileData.defaults.toMap());
  });

  test('debug keys returns stored preference keys', () async {
    SharedPreferences.setMockInitialValues({
      'open_count': 1,
      'is_dark_mode': true,
      'profile_data': ProfileData.defaults.toJson(),
    });
    final prefs = await PrefService.init();

    expect(
      prefs.debugKeys,
      containsAll({'open_count', 'is_dark_mode', 'profile_data'}),
    );
  });

  test('invalid stored profile data falls back to defaults', () async {
    SharedPreferences.setMockInitialValues({'profile_data': '{invalid'});
    final prefs = await PrefService.init();

    expect(prefs.profile.toMap(), ProfileData.defaults.toMap());
  });

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

  testWidgets('validates and saves edited profile data', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PrefService.init();
    await tester.pumpWidget(MyApp(prefs: prefs));

    await tester.tap(find.byTooltip('Edit profil'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profil'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '  ');
    await tester.enterText(find.byType(TextFormField).at(1), '  ');
    await tester.enterText(find.byType(TextFormField).at(2), '  ');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Wajib diisi'), findsNWidgets(3));

    await tester.enterText(find.byType(TextFormField).at(0), 'Updated Name');
    await tester.enterText(find.byType(TextFormField).at(1), 'Updated Role');
    await tester.enterText(find.byType(TextFormField).at(2), 'Updated bio');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Updated Name'), findsOneWidget);
    expect(find.text('Updated Role'), findsOneWidget);
    expect(find.text('Updated bio'), findsOneWidget);
    expect(
      prefs.profile.toMap(),
      const ProfileData(
        name: 'Updated Name',
        title: 'Updated Role',
        bio: 'Updated bio',
      ).toMap(),
    );
  });

  testWidgets('resets the profile to defaults', (WidgetTester tester) async {
    const savedProfile = ProfileData(
      name: 'Saved Name',
      title: 'Saved Role',
      bio: 'Saved bio',
    );
    SharedPreferences.setMockInitialValues({
      'profile_data': savedProfile.toJson(),
    });
    final prefs = await PrefService.init();
    await tester.pumpWidget(MyApp(prefs: prefs));

    expect(find.text('Saved Name'), findsOneWidget);

    await tester.tap(find.text('Reset Profil'));
    await tester.pumpAndSettle();

    expect(find.text(ProfileData.defaults.name), findsOneWidget);
    expect(find.text(ProfileData.defaults.title), findsOneWidget);
    expect(find.text(ProfileData.defaults.bio), findsOneWidget);
    expect(find.text('Profil dikembalikan ke bawaan'), findsOneWidget);
    expect(prefs.profile.toMap(), ProfileData.defaults.toMap());
  });
}
