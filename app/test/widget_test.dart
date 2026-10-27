import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vennskapp/app.dart';
import 'package:vennskapp/core/auth_stage.dart';
import 'package:vennskapp/features/library/library_repository.dart';

void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    Size size, {
    AuthStage stage = AuthStage.ready,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStageProvider.overrideWithValue(stage),
          myShelfProvider.overrideWith((ref) async => const []),
        ],
        child: const VennskApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phone: bottom tabs switch between screens', (tester) async {
    await pumpAt(tester, const Size(400, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Your shelf is waiting'), findsOneWidget);

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Find a book nearby'), findsOneWidget);
  });

  testWidgets('wide screen: navigation rail', (tester) async {
    await pumpAt(tester, const Size(1024, 768));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('signed out: redirected to the welcome screen', (tester) async {
    await pumpAt(tester, const Size(400, 800), stage: AuthStage.signedOut);

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('sign up requires the 18+ checkbox', (tester) async {
    await pumpAt(tester, const Size(400, 800), stage: AuthStage.signedOut);

    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.no');
    await tester.enterText(find.byType(TextFormField).at(1), 'longenough');
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('VennskApp is for adults (18+) for now.'), findsOneWidget);
  });
}
