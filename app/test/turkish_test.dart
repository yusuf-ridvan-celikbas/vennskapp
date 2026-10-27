import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

void main() {
  testWidgets('Turkish strings, plurals and placeholders render', (
    tester,
  ) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(l10n.tabShelf, 'Rafım');
    expect(l10n.daysLeft(0), 'Bugün teslim');
    expect(l10n.daysLeft(5), '5 gün kaldı');
    expect(
      l10n.notifLoanRequested('Ayşe', 'Dune'),
      'Ayşe, “Dune” kitabını ödünç almak istiyor',
    );
  });
}
