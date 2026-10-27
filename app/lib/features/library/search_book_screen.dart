import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../books/book.dart';
import '../books/book_cover.dart';
import '../books/book_lookup.dart';
import 'add_to_shelf.dart';

class SearchBookScreen extends ConsumerStatefulWidget {
  const SearchBookScreen({super.key});

  @override
  ConsumerState<SearchBookScreen> createState() => _SearchBookScreenState();
}

class _SearchBookScreenState extends ConsumerState<SearchBookScreen> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<BookCandidate>? _results;
  bool _loading = false;
  int _searchId = 0;
  final _added = <int>{};

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => _search(text));
  }

  Future<void> _search(String text) async {
    if (text.trim().length < 2) return;
    final id = ++_searchId;
    setState(() => _loading = true);
    final results = await ref.read(bookLookupProvider).search(text);
    if (!mounted || id != _searchId) return; // a newer search is running
    setState(() {
      _results = results;
      _added.clear();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = _results;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addSearch)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _query,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.searchHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: _onChanged,
              onSubmitted: _search,
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: results == null
                ? const SizedBox.shrink()
                : results.isEmpty
                ? _NoResults(
                    onManual: () => context.replace('/shelf/add/manual'),
                  )
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final book = results[i];
                      return _ResultTile(
                        book: book,
                        added: _added.contains(i),
                        onAdd: () async {
                          final (result, _) = await addToShelf(
                            context,
                            ref,
                            book,
                          );
                          if (result != AddResult.failed && mounted) {
                            setState(() => _added.add(i));
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.book,
    required this.added,
    required this.onAdd,
  });

  final BookCandidate book;
  final bool added;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = [
      if (book.publishedYear != null) '${book.publishedYear}',
      if (book.pageCount != null) l10n.pageCount(book.pageCount!),
    ].join(' · ');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: BookCover(title: book.title, url: book.coverUrl, width: 44),
      title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          book.authors.join(', '),
          details,
        ].where((s) => s.isNotEmpty).join('\n'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: added
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              semanticLabel: l10n.onYourShelf,
            )
          : IconButton.filledTonal(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              tooltip: l10n.addToShelf,
            ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onManual});

  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.searchNoResults, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onManual,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.addManual),
            ),
          ],
        ),
      ),
    );
  }
}
