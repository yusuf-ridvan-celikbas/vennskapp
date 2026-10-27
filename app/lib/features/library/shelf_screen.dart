import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../books/book_cover.dart';
import '../notifications/notifications_screen.dart';
import '../shell/empty_state.dart';
import 'library_item.dart';
import 'library_repository.dart';
import 'status_labels.dart';

class ShelfScreen extends ConsumerStatefulWidget {
  const ShelfScreen({super.key});

  @override
  ConsumerState<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends ConsumerState<ShelfScreen> {
  ReadingStatus? _filter;

  void _showAddOptions() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(l10n.addScan),
              subtitle: Text(l10n.addScanHelp),
              onTap: () {
                Navigator.pop(sheet);
                context.push('/shelf/add/scan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(l10n.addSearch),
              subtitle: Text(l10n.addSearchHelp),
              onTap: () {
                Navigator.pop(sheet);
                context.push('/shelf/add/search');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.addManual),
              subtitle: Text(l10n.addManualHelp),
              onTap: () {
                Navigator.pop(sheet);
                context.push('/shelf/add/manual');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shelf = ref.watch(myShelfProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabShelf),
        actions: const [NotificationBell()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOptions,
        icon: const Icon(Icons.add),
        label: Text(l10n.addBook),
      ),
      body: switch (shelf) {
        AsyncData(:final value) when value.isEmpty => EmptyState(
          icon: Icons.auto_stories,
          title: l10n.shelfEmptyTitle,
          body: l10n.shelfEmptyBody,
        ),
        AsyncData(:final value) => _ShelfGrid(
          items: value,
          filter: _filter,
          onFilter: (f) => setState(() => _filter = f),
        ),
        AsyncError(:final error) => Center(
          child: Text(l10n.genericError('$error')),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ShelfGrid extends StatelessWidget {
  const _ShelfGrid({
    required this.items,
    required this.filter,
    required this.onFilter,
  });

  final List<LibraryItem> items;
  final ReadingStatus? filter;
  final ValueChanged<ReadingStatus?> onFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = filter == null
        ? items
        : items.where((i) => i.status == filter).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.shelfFilterAll(items.length)),
                  selected: filter == null,
                  onSelected: (_) => onFilter(null),
                ),
                for (final s in ReadingStatus.values)
                  ChoiceChip(
                    avatar: Icon(s.icon, size: 18),
                    label: Text(s.label(l10n)),
                    selected: filter == s,
                    onSelected: (_) => onFilter(s),
                  ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.48,
            ),
            itemCount: shown.length,
            itemBuilder: (context, i) => _ShelfTile(item: shown[i]),
          ),
        ),
      ],
    );
  }
}

class _ShelfTile extends StatelessWidget {
  const _ShelfTile({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push('/shelf/item/${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(
            title: item.book.title,
            url: item.book.coverUrl,
            width: 140,
          ),
          const SizedBox(height: 6),
          Text(
            item.book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge,
          ),
          Text(
            item.book.authors.join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                item.status.icon,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  item.status.label(l10n),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
