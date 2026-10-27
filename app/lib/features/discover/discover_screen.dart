import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../books/book_cover.dart';
import '../notifications/notifications_screen.dart';
import '../shell/empty_state.dart';
import 'discover_repository.dart';

/// Search books that friends, neighbors and public users have. With an empty
/// query it shows recent books from people around you.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => setState(() => _query = text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(discoverBooksProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabDiscover),
        actions: const [NotificationBell()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.discoverHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: _onChanged,
              onSubmitted: (t) => setState(() => _query = t.trim()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(discoverBooksProvider(_query).future),
              child: switch (results) {
                AsyncData(:final value) when value.isEmpty => ListView(
                  children: [
                    EmptyState(
                      icon: Icons.travel_explore,
                      title: _query.isEmpty
                          ? l10n.discoverNothingNearbyTitle
                          : l10n.discoverNoMatchTitle,
                      body: _query.isEmpty
                          ? l10n.discoverNothingNearbyBody
                          : l10n.discoverNoMatchBody,
                    ),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/me/friends'),
                        icon: const Icon(Icons.person_add_alt),
                        label: Text(l10n.friendsAdd),
                      ),
                    ),
                  ],
                ),
                AsyncData(:final value) => ListView.separated(
                  itemCount: value.length + 1,
                  separatorBuilder: (_, i) => i == 0
                      ? const SizedBox.shrink()
                      : const Divider(height: 1),
                  itemBuilder: (context, i) => i == 0
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: Text(
                            _query.isEmpty
                                ? l10n.discoverAroundYou
                                : l10n.discoverResults(value.length),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        )
                      : _DiscoverTile(book: value[i - 1]),
                ),
                AsyncError(:final error) => Center(
                  child: Text(l10n.genericError('$error')),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverTile extends StatelessWidget {
  const _DiscoverTile({required this.book});

  final DiscoverBook book;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final who = [
      if (book.friends > 0) l10n.countFriends(book.friends),
      if (book.neighbors > 0) l10n.countNeighbors(book.neighbors),
      if (book.others > 0) l10n.countOthers(book.others),
    ].join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: BookCover(title: book.title, url: book.coverUrl, width: 44),
      title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.authors.join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(who, style: theme.textTheme.bodySmall),
          if (book.lendable > 0)
            Text(
              l10n.countCanLend(book.lendable),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      onTap: () => context.push('/discover/book/${book.bookId}'),
    );
  }
}
