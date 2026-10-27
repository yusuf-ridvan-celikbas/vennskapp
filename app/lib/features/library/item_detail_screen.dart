import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../books/book_cover.dart';
import '../profile/profile.dart';
import '../profile/profile_repository.dart';
import '../profile/visibility_labels.dart';
import 'library_item.dart';
import 'library_repository.dart';
import 'status_labels.dart';

/// The owner's view of one of their books: status, rating, review, lending
/// and visibility. Every change is saved immediately.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    LibraryItemChanges changes,
  ) async {
    try {
      await ref.read(libraryRepositoryProvider).update(itemId, changes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).genericError('$e')),
          ),
        );
      }
    }
    ref.invalidate(libraryItemProvider(itemId));
    ref.invalidate(myShelfProvider);
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.removeTitle),
        content: Text(l10n.removeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(libraryRepositoryProvider).remove(itemId);
    ref.invalidate(myShelfProvider);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final item = ref.watch(libraryItemProvider(itemId));
    final defaultVisibility =
        ref.watch(myProfileProvider).value?.defaultVisibility ??
        VisibilityLevel.neighbors;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _remove(context, ref),
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.remove,
          ),
        ],
      ),
      body: switch (item) {
        AsyncData(:final value) => _Details(
          item: value,
          defaultVisibility: defaultVisibility,
          onChange: (c) => _save(context, ref, c),
        ),
        AsyncError(:final error) => Center(
          child: Text(l10n.genericError('$error')),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.item,
    required this.defaultVisibility,
    required this.onChange,
  });

  final LibraryItem item;
  final VisibilityLevel defaultVisibility;
  final ValueChanged<LibraryItemChanges> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final book = item.book;
    final facts = [
      if (book.publishedYear != null) '${book.publishedYear}',
      if (book.pageCount != null) l10n.pageCount(book.pageCount!),
      if (book.isbn13 != null) 'ISBN ${book.isbn13}',
    ].join(' · ');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(title: book.title, url: book.coverUrl, width: 110),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        book.authors.join(', '),
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(facts, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l10n.detailStatus, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<ReadingStatus>(
              segments: [
                for (final s in ReadingStatus.values)
                  ButtonSegment(
                    value: s,
                    icon: Icon(s.icon),
                    label: Text(s.label(l10n)),
                  ),
              ],
              selected: {item.status},
              onSelectionChanged: (s) =>
                  onChange(LibraryItemChanges(status: s.first)),
            ),
            const SizedBox(height: 24),
            Text(l10n.detailRating, style: theme.textTheme.titleSmall),
            Row(
              children: [
                for (var star = 1; star <= 5; star++)
                  IconButton(
                    onPressed: () => onChange(
                      star == item.rating
                          ? const LibraryItemChanges(clear: {'rating'})
                          : LibraryItemChanges(rating: star),
                    ),
                    icon: Icon(
                      star <= (item.rating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: l10n.detailStars(star),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _ReviewField(
              initial: item.review ?? '',
              onSave: (text) => onChange(
                text.isEmpty
                    ? const LibraryItemChanges(clear: {'review'})
                    : LibraryItemChanges(review: text),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: item.lendable,
              onChanged: (v) => onChange(LibraryItemChanges(lendable: v)),
              title: Text(l10n.detailLendable),
              subtitle: Text(l10n.detailLendableHelp),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<VisibilityLevel?>(
              initialValue: item.visibility,
              decoration: InputDecoration(
                labelText: l10n.detailVisibility,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    l10n.detailVisibilityDefault(defaultVisibility.label(l10n)),
                  ),
                ),
                for (final level in VisibilityLevel.values)
                  DropdownMenuItem(
                    value: level,
                    child: Row(
                      children: [
                        Icon(level.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(level.label(l10n)),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => onChange(
                v == null
                    ? const LibraryItemChanges(clear: {'visibility'})
                    : LibraryItemChanges(visibility: v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Review text that saves when the field loses focus.
class _ReviewField extends StatefulWidget {
  const _ReviewField({required this.initial, required this.onSave});

  final String initial;
  final ValueChanged<String> onSave;

  @override
  State<_ReviewField> createState() => _ReviewFieldState();
}

class _ReviewFieldState extends State<_ReviewField> {
  late final _text = TextEditingController(text: widget.initial);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      final value = _text.text.trim();
      if (!_focus.hasFocus && value != widget.initial) widget.onSave(value);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _text,
      focusNode: _focus,
      maxLines: 4,
      maxLength: 500,
      decoration: InputDecoration(
        labelText: l10n.detailReview,
        hintText: l10n.detailReviewHint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
