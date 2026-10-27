import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase.dart';
import '../profile/profile_repository.dart';
import '../profile/visibility_labels.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(myProfileProvider).value;

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
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.signOut),
                  onTap: () => ref.read(supabaseProvider).auth.signOut(),
                ),
              ],
            ),
    );
  }
}
