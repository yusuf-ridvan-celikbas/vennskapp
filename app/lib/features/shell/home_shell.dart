import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../loans/loans_repository.dart';
import '../notifications/notification_text.dart';
import '../notifications/notifications_repository.dart';
import '../social/social_repository.dart';

/// Bottom tabs on phones, a navigation rail from 600 dp up.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _select(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final waiting = ref.watch(loansNeedingActionProvider);
    ref.listen(notificationsProvider, (previous, next) {
      final before = previous?.value;
      final now = next.value;
      if (before == null || now == null) return;
      final known = {for (final n in before) n.id};
      final fresh = now.where((n) => !known.contains(n.id)).toList();
      if (fresh.isEmpty) return;
      // Something happened elsewhere: reload what it may have changed.
      ref.invalidate(myLoansProvider);
      ref.invalidate(loanProvider);
      ref.invalidate(loanEventsProvider);
      ref.invalidate(myPeopleProvider);
      ref.invalidate(personProvider);
      final n = fresh.first;
      final route = n.route;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notificationText(context, n)),
          action: route == null
              ? null
              : SnackBarAction(
                  label: l10n.notificationsView,
                  onPressed: () => context.push(route),
                ),
        ),
      );
    });
    Widget badged(IconData icon, int index) => Badge(
      isLabelVisible: index == 2 && waiting > 0,
      label: Text('$waiting'),
      child: Icon(icon),
    );
    final destinations = [
      (Icons.auto_stories_outlined, Icons.auto_stories, l10n.tabShelf),
      (Icons.travel_explore_outlined, Icons.travel_explore, l10n.tabDiscover),
      (Icons.swap_horiz_outlined, Icons.swap_horiz, l10n.tabLoans),
      (Icons.person_outline, Icons.person, l10n.tabMe),
    ];

    if (MediaQuery.sizeOf(context).width >= 600) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final (i, (icon, selected, label)) in destinations.indexed)
                  NavigationRailDestination(
                    icon: badged(icon, i),
                    selectedIcon: badged(selected, i),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _select,
        destinations: [
          for (final (i, (icon, selected, label)) in destinations.indexed)
            NavigationDestination(
              icon: badged(icon, i),
              selectedIcon: badged(selected, i),
              label: label,
            ),
        ],
      ),
    );
  }
}
