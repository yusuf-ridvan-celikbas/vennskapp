import 'package:flutter_test/flutter_test.dart';
import 'package:vennskapp/features/loans/loan.dart';

Loan _loan({
  LoanRole role = LoanRole.borrower,
  LoanStatus status = LoanStatus.active,
  bool overdue = false,
  bool myHandover = false,
  String? extensionStatus,
  int extensionsUsed = 0,
  DateTime? dueAt,
}) => Loan(
  id: 'l1',
  role: role,
  status: status,
  overdue: overdue,
  bookId: 'b1',
  title: 'Book',
  authors: const [],
  otherId: 'u2',
  otherName: 'Ayşe',
  otherUsername: 'ayse',
  myHandoverConfirmed: myHandover,
  theirHandoverConfirmed: false,
  extensionsUsed: extensionsUsed,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  extensionStatus: extensionStatus,
  dueAt: dueAt,
);

void main() {
  test('daysLeft counts calendar days, ignoring the time of day', () {
    final now = DateTime(2026, 10, 27, 23, 30);
    expect(_loan(dueAt: DateTime(2026, 10, 28, 0, 15)).daysLeft(now), 1);
    expect(_loan(dueAt: DateTime(2026, 10, 27, 8)).daysLeft(now), 0);
    expect(_loan(dueAt: DateTime(2026, 10, 24)).daysLeft(now), -3);
    expect(_loan().daysLeft(now), isNull);
  });

  test('owner must act on a new request, borrower waits', () {
    expect(
      _loan(role: LoanRole.owner, status: LoanStatus.requested).needsMyAction,
      isTrue,
    );
    expect(_loan(status: LoanStatus.requested).needsMyAction, isFalse);
  });

  test('handover needs action until I confirmed', () {
    expect(_loan(status: LoanStatus.accepted).needsMyAction, isTrue);
    expect(
      _loan(status: LoanStatus.accepted, myHandover: true).needsMyAction,
      isFalse,
    );
  });

  test('owner answers extensions; overdue borrower should return', () {
    expect(
      _loan(role: LoanRole.owner, extensionStatus: 'pending').needsMyAction,
      isTrue,
    );
    expect(_loan(overdue: true).needsMyAction, isTrue);
    expect(_loan().needsMyAction, isFalse);
  });

  test('only one extension per loan', () {
    expect(_loan().canRequestExtension, isTrue);
    expect(_loan(extensionStatus: 'pending').canRequestExtension, isFalse);
    expect(_loan(extensionsUsed: 1).canRequestExtension, isFalse);
    expect(_loan(role: LoanRole.owner).canRequestExtension, isFalse);
  });
}
