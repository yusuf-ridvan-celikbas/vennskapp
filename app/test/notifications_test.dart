import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vennskapp/features/notifications/app_notification.dart';
import 'package:vennskapp/features/notifications/notification_text.dart';
import 'package:vennskapp/features/notifications/notifications_repository.dart';
import 'package:vennskapp/features/notifications/notifications_screen.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

AppNotification _n(
  String type,
  Map<String, dynamic> payload, {
  bool read = false,
}) => AppNotification.fromJson({
  'id': '$type-${payload.hashCode}',
  'type': type,
  'payload': payload,
  'created_at': '2026-10-27T10:00:00Z',
  'read_at': read ? '2026-10-27T11:00:00Z' : null,
});

Future<String> _render(WidgetTester tester, AppNotification n) async {
  late String text;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          text = notificationText(context, n);
          return const SizedBox();
        },
      ),
    ),
  );
  return text;
}

void main() {
  const loan = {
    'loan_id': 'L1',
    'title': 'Dune',
    'name': 'Ayşe',
    'person_id': 'P1',
  };

  test(
    'loan notifications open the loan, friend requests the friends list',
    () {
      expect(_n('loan_requested', loan).route, '/loans/L1');
      expect(_n('friend_request', {'person_id': 'P1'}).route, '/me/friends');
      expect(_n('friend_accepted', {'person_id': 'P1'}).route, '/people/P1');
      expect(_n('something_new', {}).route, isNull);
    },
  );

  testWidgets('text depends on the type and payload', (tester) async {
    expect(
      await _render(tester, _n('loan_accepted', {...loan, 'days': 21})),
      'Ayşe will lend you Dune for 21 days. Arrange the handover!',
    );
    expect(
      await _render(
        tester,
        _n('loan_handover_confirmed', {...loan, 'started': true}),
      ),
      'The loan of Dune has started',
    );
    expect(
      await _render(
        tester,
        _n('loan_declined', {...loan, 'reason': 'lent_to_someone_else'}),
      ),
      'Dune went to another neighbor this time',
    );
    expect(
      await _render(tester, _n('loan_overdue', {...loan, 'role': 'owner'})),
      "Ayşe hasn't returned Dune yet",
    );
    expect(
      await _render(tester, _n('loan_overdue', {...loan, 'role': 'borrower'})),
      'Dune is overdue. Please bring it back to Ayşe.',
    );
    expect(
      await _render(tester, _n('mystery', {})),
      'You have a new notification',
    );
  });

  testWidgets('the bell counts unread notifications', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsProvider.overrideWith(
            (ref) => Stream.value([
              _n('loan_requested', loan),
              _n('friend_request', {'person_id': 'P2', 'name': 'Can'}),
              _n('loan_returned', loan, read: true),
            ]),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(appBar: AppBar(actions: const [NotificationBell()])),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });
}
