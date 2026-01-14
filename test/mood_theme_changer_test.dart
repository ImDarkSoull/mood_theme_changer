import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_theme_changer/mood_theme_changer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MoodEnum', () {
    test('contains 7 moods', () {
      expect(UserMood.values.length, 7);
    });
  });

  group('MoodThemeConfig', () {
    test('toThemeData generates valid ThemeData', () {
      const config = MoodThemeConfig(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        surfaceTintFactor: 0.5,
      );

      final theme = config.toThemeData();
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.colorScheme.surfaceTint, isNotNull);
    });
  });

  group('MoodThemeProvider', () {
    late Map<UserMood, MoodThemeConfig> mockThemes;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockThemes = {
        UserMood.happy: const MoodThemeConfig(
            seedColor: Colors.yellow, brightness: Brightness.light),
        UserMood.sad: const MoodThemeConfig(
            seedColor: Colors.blue, brightness: Brightness.dark),
      };
    });

    testWidgets('initializes with default mood (happy)', (tester) async {
      await tester.pumpWidget(
        MoodThemeProvider(
          moodThemes: mockThemes,
          child: MaterialApp(
            home: Builder(builder: (context) {
              return Text(MoodThemeProvider.of(context).currentMood.toString());
            }),
          ),
        ),
      );

      expect(find.text(UserMood.happy.toString()), findsOneWidget);
    });

    testWidgets('changes mood and updates theme', (tester) async {
      await tester.pumpWidget(
        MoodThemeProvider(
          moodThemes: mockThemes,
          child: Builder(builder: (context) {
            return MaterialApp(
              theme: Theme.of(context),
              home: Scaffold(
                body: Column(
                  children: [
                    Text('Mood: ${MoodThemeProvider.of(context).currentMood}'),
                    ElevatedButton(
                      onPressed: () {
                        MoodThemeProvider.of(context).setMood(UserMood.sad);
                      },
                      child: const Text('Change Mood'),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );

      expect(find.text('Mood: UserMood.happy'), findsOneWidget);

      await tester.tap(find.text('Change Mood'));
      await tester.pumpAndSettle(); // Wait for animation

      expect(find.text('Mood: UserMood.sad'), findsOneWidget);
    });

    testWidgets('persists mood to SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MoodThemeProvider(
          moodThemes: mockThemes,
          child: Builder(builder: (context) {
            return MaterialApp(
              home: ElevatedButton(
                onPressed: () async {
                  await MoodThemeProvider.of(context).setMood(UserMood.sad);
                },
                child: const Text('Save Mood'),
              ),
            );
          }),
        ),
      );

      await tester.tap(find.text('Save Mood'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('mood_theme_changer_index'), UserMood.sad.index);
    });

    testWidgets('loads persisted mood on validation', (tester) async {
      SharedPreferences.setMockInitialValues(
          {'mood_theme_changer_index': UserMood.sad.index});

      await tester.pumpWidget(
        MoodThemeProvider(
          moodThemes: mockThemes,
          child: MaterialApp(
            home: Builder(builder: (context) {
              return Text('Mood: ${MoodThemeProvider.of(context).currentMood}');
            }),
          ),
        ),
      );

      // Pump to allow futurebuilder/async init to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Mood: UserMood.sad'), findsOneWidget);
    });
  });
}
