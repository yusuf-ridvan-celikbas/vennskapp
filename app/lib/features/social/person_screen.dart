import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../books/book_cover.dart';
import 'people_labels.dart';
import 'person.dart';
import 'report_dialog.dart';
import 'social_repository.dart';

/// Another person's profile and the part of their shelf the viewer may see.
class PersonScreen extends ConsumerWidget {
  const PersonScreen({super.key, required this.userId});

  final String userId;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(SocialRepository repo) action,
  ) async {
    try {
      await action(ref.read(socialRepositoryProvider));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).genericError('$e')),
          ),
        );
      }
    }
    invalidateSocial(ref, userId);
  }

  Future<void> _confirmBlock(
    BuildContext context,
    WidgetRef ref,
    Person person,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.blockTitle(person.displayName)),
        content: Text(l10n.blockBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n.block),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await _run(context, ref, (r) => r.block(person.id));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final person = ref.watch(personProvider(userId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (person.value case final p?)
            PopupMenuButton<String>(
              onSelected: (choice) => switch (choice) {
                'unfriend' => _run(
                  context,
                  ref,
                  (r) => r.removeFriendship(p.id),
                ),
                'block' => _confirmBlock(context, ref, p),
                'report' => showReportDialog(
                  context,
                  ref,
                  personId: p.id,
                  name: p.displayName,
                ),
                _ => _run(context, ref, (r) => r.unblock(p.id)),
              },
              itemBuilder: (_) => [
                if (p.friendshipAccepted)
                  PopupMenuItem(value: 'unfriend', child: Text(l10n.unfriend)),
                p.blockedByMe
                    ? PopupMenuItem(value: 'unblock', child: Text(l10n.unblock))
                    : PopupMenuItem(value: 'block', child: Text(l10n.block)),
                PopupMenuItem(value: 'report', child: Text(l10n.report)),
              ],
            ),
        ],
      ),
      body: switch (person) {
        AsyncData(:final value) when value == null => Center(
          child: Text(l10n.personNotFound),
        ),
        AsyncData(:final value) => _PersonBody(
          person: value!,
          onAction: (action) => _run(context, ref, action),
        ),
        AsyncError(:final error) => Center(
          child: Text(l10n.genericError('$error')),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _PersonBody extends ConsumerWidget {
  const _PersonBody({required this.person, required this.onAction});

  final Person person;
  final void Function(Future<void> Function(SocialRepository)) onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final shelf = ref.watch(personShelfProvider(person.id));

    final Widget friendButton = switch (person) {
      Person(blockedByMe: true) => OutlinedButton.icon(
        onPressed: () => onAction((r) => r.unblock(person.id)),
        icon: const Icon(Icons.block),
        label: Text(l10n.unblock),
      ),
      Person(friendshipAccepted: true) => FilledButton.tonalIcon(
        onPressed: null,
        icon: const Icon(Icons.favorite),
        label: Text(l10n.relFriend),
      ),
      Person(hasPendingRequest: true, requestSentByMe: true) =>
        OutlinedButton.icon(
          onPressed: () => onAction((r) => r.removeFriendship(person.id)),
          icon: const Icon(Icons.hourglass_top),
          label: Text(l10n.friendRequestSentCancel),
        ),
      Person(hasPendingRequest: true) => FilledButton.icon(
        onPressed: () =>
            onAction((r) => r.respond(person.friendshipId!, accept: true)),
        icon: const Icon(Icons.check),
        label: Text(l10n.friendAccept),
      ),
      _ => FilledButton.icon(
        onPressed: () => onAction((r) => r.sendRequest(person.username)),
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.friendsAdd),
      ),
    };

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                PersonAvatar(name: person.displayName, radius: 40),
                const SizedBox(height: 12),
                Text(person.displayName, style: theme.textTheme.headlineSmall),
                Text('@${person.username}'),
                const SizedBox(height: 4),
                Text(
                  personSubtitle(
                    l10n,
                    person.relationship,
                    area: person.areaName,
                    km: person.approxKm,
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                if (person.thumbsUp != null && person.thumbsUp! > 0)
                  Text(
                    l10n.meThumbsUp(person.thumbsUp!),
                    style: theme.textTheme.bodySmall,
                  ),
                const SizedBox(height: 16),
                friendButton,
                if (!person.profileVisible && !person.blockedByMe) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.personPrivateNote,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        ...switch (shelf) {
          AsyncData(:final value) when value.isNotEmpty => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  l10n.personShelf(value.length),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.5,
                ),
                itemCount: value.length,
                itemBuilder: (context, i) {
                  final item = value[i];
                  return InkWell(
                    onTap: () => context.push('/discover/book/${item.book.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookCover(
                          title: item.book.title,
                          url: item.book.coverUrl,
                          width: 120,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          AsyncData() => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.personShelfEmpty, textAlign: TextAlign.center),
              ),
            ),
          ],
          _ => [const SliverToBoxAdapter(child: SizedBox.shrink())],
        },
      ],
    );
  }
}
