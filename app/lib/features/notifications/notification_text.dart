import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../loans/loan_labels.dart';
import 'app_notification.dart';

String notificationText(BuildContext context, AppNotification n) {
  final l10n = AppLocalizations.of(context);
  final name = n.name;
  final title = n.title;
  final days = n.payload['days'] as int? ?? 0;
  final owner = n.payload['role'] == 'owner';
  return switch (n.type) {
    'loan_requested' => l10n.notifLoanRequested(name, title),
    'loan_accepted' => l10n.notifLoanAccepted(name, title, days),
    'loan_declined' when n.payload['reason'] == 'lent_to_someone_else' =>
      l10n.notifLoanLentElsewhere(title),
    'loan_declined' => l10n.notifLoanDeclined(name, title),
    'loan_cancelled' => l10n.notifLoanCancelled(name, title),
    'loan_handover_confirmed' when n.payload['started'] == true =>
      l10n.notifLoanStarted(title),
    'loan_handover_confirmed' => l10n.notifLoanHandover(name, title),
    'loan_extension_requested' => l10n.notifExtensionRequested(
      name,
      title,
      days,
    ),
    'loan_extension_accepted' => l10n.notifExtensionAccepted(name, title),
    'loan_extension_declined' => l10n.notifExtensionDeclined(name, title),
    'loan_returned' => l10n.notifLoanReturned(name, title),
    'loan_expired' => l10n.notifLoanExpired(title),
    'loan_due_soon' => l10n.notifLoanDueSoon(
      title,
      name,
      formatDate(
        context,
        DateTime.parse(n.payload['due_at'] as String).toLocal(),
      ),
    ),
    'loan_overdue' when owner => l10n.notifLoanOverdueOwner(name, title),
    'loan_overdue' => l10n.notifLoanOverdue(title, name),
    'friend_request' => l10n.notifFriendRequest(name),
    'friend_accepted' => l10n.notifFriendAccepted(name),
    _ => l10n.notifGeneric,
  };
}

IconData notificationIcon(AppNotification n) => switch (n.type) {
  'loan_requested' => Icons.volunteer_activism_outlined,
  'loan_accepted' || 'loan_extension_accepted' => Icons.check_circle_outline,
  'loan_handover_confirmed' => Icons.handshake_outlined,
  'loan_extension_requested' => Icons.more_time,
  'loan_returned' => Icons.assignment_return_outlined,
  'loan_due_soon' => Icons.event_outlined,
  'loan_overdue' => Icons.warning_amber_outlined,
  'friend_request' || 'friend_accepted' => Icons.person_add_alt,
  _ when n.type.startsWith('loan_') => Icons.swap_horiz,
  _ => Icons.notifications_outlined,
};
