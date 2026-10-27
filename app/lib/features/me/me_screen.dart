import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase.dart';
import '../profile/profile_repository.dart';
import '../profile/visibility_labels.dart';
import '../social/person.dart';
import '../social/social_repository.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(myProfileProvider).value;
    final people = ref.watch(myPeopleProvider).value ?? const [];
    final friends = people.where((p) => p.kind == PeopleKind.friend).length;
    final incoming = people.where((p) => p.kind == PeopleKind.incoming).length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMe)),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      profile.displayName!.characters.first.toUpperCase(),
                    ),
                  ),
                  title: Text(
                    profile.displayName!,
                    style: theme.textTheme.titleLarge,
                  ),
                  subtitle: Text('@${profile.username}'),
                ),
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(profile.areaName!),
                  subtitle: Text(l10n.meAreaSubtitle),
                ),
                ListTile(
                  leading: Icon(profile.defaultVisibility.icon),
                  title: Text(profile.defaultVisibility.label(l10n)),
                  subtitle: Text(l10n.meDefaultVisibilitySubtitle),
                ),
                ListTile(
                  leading: const Icon(Icons.thumb_up_outlined),
                  title: Text(l10n.meThumbsUp(profile.thumbsUp)),
                ),
                const Divider(),
                ListTile(
                  leading: Badge(
                    isLabelVisible: incoming > 0,
                    label: Text('$incoming'),
                    child: const Icon(Icons.people_outline),
                  ),
                  title: Text(l10n.friendsTitle),
                  subtitle: Text(
                    incoming > 0
                        ? l10n.friendsIncomingCount(incoming)
                        : l10n.countFriends(friends),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/me/friends'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.signOut),
                  onTap: () => ref.read(supabaseProvider).auth.signOut(),
                ),
              ],
            ),
    );
  }
}
