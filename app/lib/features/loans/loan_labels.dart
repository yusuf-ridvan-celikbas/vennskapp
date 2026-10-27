import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import 'loan.dart';

String formatDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date);

/// One-line summary of where a loan stands, from the viewer's side.
String loanStatusLine(BuildContext context, Loan loan) {
  final l10n = AppLocalizations.of(context);
  final name = loan.otherName;
  return switch (loan.status) {
    LoanStatus.requested =>
      loan.isOwner
          ? l10n.loanLineWantsToBorrow(name)
          : l10n.loanLineWaitingAnswer(name),
    LoanStatus.accepted =>
      loan.myHandoverConfirmed
          ? l10n.loanLineWaitingHandover(name)
          : l10n.loanLineArrangeHandover,
    LoanStatus.active =>
      loan.overdue
          ? l10n.loanLineOverdue(-(loan.daysLeft(DateTime.now()) ?? 0))
          : loan.isOwner && loan.extensionPending
          ? l10n.loanLineExtensionAsked(name, loan.extensionDaysRequested ?? 0)
          : l10n.daysLeft(loan.daysLeft(DateTime.now()) ?? 0),
    LoanStatus.returned => l10n.loanLineReturned(
      loan.returnedAt == null ? '' : formatDate(context, loan.returnedAt!),
    ),
    LoanStatus.declined => l10n.loanLineDeclined,
    LoanStatus.cancelled => l10n.loanLineCancelled,
  };
}

/// "From Ayşe" when borrowing, "To Mehmet" when lending.
String loanCounterpart(AppLocalizations l10n, Loan loan) => loan.isOwner
    ? l10n.loanLentTo(loan.otherName)
    : l10n.loanBorrowedFrom(loan.otherName);

String loanEventLabel(AppLocalizations l10n, LoanEvent e, bool byMe) {
  return switch (e.type) {
    'requested' => l10n.eventRequested,
    'accepted' => l10n.eventAccepted(e.payload['days'] as int? ?? 0),
    'declined' =>
      e.payload['reason'] == 'lent_to_someone_else'
          ? l10n.eventDeclinedOther
          : l10n.eventDeclined,
    'cancelled' => l10n.eventCancelled,
    'handover_confirmed' =>
      byMe ? l10n.eventHandoverByMe : l10n.eventHandoverByThem,
    'started' => l10n.eventStarted,
    'extension_requested' => l10n.eventExtensionRequested(
      e.payload['days'] as int? ?? 0,
    ),
    'extension_accepted' => l10n.eventExtensionAccepted,
    'extension_declined' => l10n.eventExtensionDeclined,
    'returned' => l10n.eventReturned,
    _ => e.type,
  };
}

Color loanStatusColor(ColorScheme scheme, Loan loan) {
  if (loan.overdue) return scheme.error;
  if (loan.needsMyAction) return scheme.primary;
  return scheme.onSurfaceVariant;
}
