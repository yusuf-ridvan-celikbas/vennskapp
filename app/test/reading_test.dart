import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vennskapp/features/reading/reading_repository.dart';
import 'package:vennskapp/features/reading/reading_screen.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

Widget _wrap(ReadingStats stats) => ProviderScope(
  overrides: [readingStatsProvider.overrideWith((ref) async => stats)],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: ReadingStatsCard()),
  ),
);

void main() {
  test('stats parse from the RPC row, with numeric strings or numbers', () {
    final s = ReadingStats.fromJson({
      'pages_per_hour': 42.5,
      'pace_pages_per_day': 35,
      'pace_confidence': 0.75,
      'books_this_year': 6,
      'pages_last_30_days': 900,
      'minutes_last_30_days': 1200,
      'sessions_count': 20,
      'example_days_300': 14,
    });
    expect(s.pagesPerHour, 42.5);
    expect(s.pacePagesPerDay, 35.0);
    expect(s.exampleDays300, 14);
  });

  testWidgets('new reader sees the cold-start explanation', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ReadingStats(
          pacePagesPerDay: 20,
          paceConfidence: 0,
          booksThisYear: 0,
          pagesLast30Days: 0,
          minutesLast30Days: 0,
          sessionsCount: 0,
          exampleDays300: 28,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your pace: about 20 pages a day'), findsOneWidget);
    expect(find.textContaining('We start with a typical pace'), findsOneWidget);
    expect(find.text('–'), findsOneWidget); // no pages/hour yet
  });

  testWidgets('experienced reader sees what a 300-page book would get', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ReadingStats(
          pacePagesPerDay: 35,
          paceConfidence: 0.75,
          booksThisYear: 6,
          pagesLast30Days: 900,
          minutesLast30Days: 1200,
          sessionsCount: 20,
          exampleDays300: 14,
          pagesPerHour: 45,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('A 300-page book would get about 14 days.'),
      findsOneWidget,
    );
    expect(find.text('6'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
  });
}
