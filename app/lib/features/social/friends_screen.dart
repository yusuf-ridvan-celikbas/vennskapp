import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import 'people_labels.dart';
import 'person.dart';
import 'social_repository.dart';

/// Add friends by username; see requests, friends and blocked people.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _username = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final name = _username.text.trim().replaceFirst('@', '');
    if (name.isEmpty) return;
    setState(() => _busy = true);
    String message;
    try {
      message = switch (await ref
          .read(socialRepositoryProvider)
          .sendRequest(name)) {
        FriendRequestResult.pending => l10n.friendRequestSent(name),
        FriendRequestResult.accepted => l10n.friendNowFriends(name),
        FriendRequestResult.notFound => l10n.friendNotFound(name),
        FriendRequestResult.isMe => l10n.friendIsMe,
      };
      _username.clear();
    } catch (e) {
      message = l10n.genericError('$e');
    }
    invalidateSocial(ref);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _act(Future<void> Function(SocialRepository) action) async {
    await action(ref.read(socialRepositoryProvider));
    invalidateSocial(ref);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final people = ref.watch(myPeopleProvider).value ?? const [];
    List<PeopleEntry> of(PeopleKind k) =>
        people.where((p) => p.kind == k).toList();

    Widget section(
      String title,
      List<PeopleEntry> entries,
      Widget? Function(PeopleEntry) trailing,
    ) {
      if (entries.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
          for (final e in entries)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: PersonAvatar(name: e.displayName),
              title: Text(e.displayName),
              subtitle: Text('@${e.username}'),
              trailing: trailing(e),
              onTap: () => context.push('/people/${e.id}'),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.friendsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.friendsAddHelp, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _username,
                      autocorrect: false,
                      decoration: InputDecoration(
                        prefixText: '@',
                        labelText: l10n.onboardingUsername,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _busy ? null : _send,
                    child: Text(l10n.friendsAdd),
                  ),
                ],
              ),
              section(
                l10n.friendsIncoming,
                of(PeopleKind.incoming),
                (e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.friendDecline,
                      onPressed: () => _act(
                        (r) => r.respond(e.friendshipId!, accept: false),
                      ),
                      icon: const Icon(Icons.close),
                    ),
                    FilledButton(
                      onPressed: () =>
                          _act((r) => r.respond(e.friendshipId!, accept: true)),
                      child: Text(l10n.friendAccept),
                    ),
                  ],
                ),
              ),
              section(l10n.friendsList, of(PeopleKind.friend), (_) => null),
              section(
                l10n.friendsOutgoing,
                of(PeopleKind.outgoing),
                (e) => TextButton(
                  onPressed: () => _act((r) => r.removeFriendship(e.id)),
                  child: Text(l10n.cancel),
                ),
              ),
              section(
                l10n.friendsBlocked,
                of(PeopleKind.blocked),
                (e) => TextButton(
                  onPressed: () => _act((r) => r.unblock(e.id)),
                  child: Text(l10n.unblock),
                ),
              ),
              if (people.isEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  l10n.friendsEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
