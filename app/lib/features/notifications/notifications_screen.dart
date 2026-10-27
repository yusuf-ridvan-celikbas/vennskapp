import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../shell/empty_state.dart';
import 'app_notification.dart';
import 'notification_text.dart';
import 'notifications_repository.dart';

/// Bell for the tab app bars; the badge counts unread notifications.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsProvider);
    return IconButton(
      tooltip: AppLocalizations.of(context).notificationsTitle,
      onPressed: () => context.push('/notifications'),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: Icon(
          unread > 0 ? Icons.notifications : Icons.notifications_outlined,
        ),
      ),
    );
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    if (n.unread) {
      await ref.read(notificationsRepositoryProvider).markRead([n.id]);
    }
    final route = n.route;
    if (route != null && context.mounted) context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationsProvider);
    final timeFormat = DateFormat.MMMd(
      Localizations.localeOf(context).toString(),
    ).add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsRepositoryProvider).markRead(),
              child: Text(l10n.notificationsMarkAllRead),
            ),
        ],
      ),
      body: switch (notifications) {
        AsyncData(:final value) when value.isEmpty => EmptyState(
          icon: Icons.notifications_none,
          title: l10n.notificationsEmptyTitle,
          body: l10n.notificationsEmptyBody,
        ),
        AsyncData(:final value) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView.separated(
              itemCount: value.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = value[i];
                return ListTile(
                  tileColor: n.unread
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.35,
                        )
                      : null,
                  leading: Icon(
                    notificationIcon(n),
                    color: n.type == 'loan_overdue'
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  title: Text(
                    notificationText(context, n),
                    style: n.unread
                        ? const TextStyle(fontWeight: FontWeight.w600)
                        : null,
                  ),
                  subtitle: Text(timeFormat.format(n.createdAt)),
                  trailing: n.unread
                      ? Semantics(
                          label: l10n.notificationsUnread,
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                  onTap: () => _open(context, ref, n),
                );
              },
            ),
          ),
        ),
        AsyncError(:final error) => Center(
          child: Text(l10n.genericError('$error')),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
