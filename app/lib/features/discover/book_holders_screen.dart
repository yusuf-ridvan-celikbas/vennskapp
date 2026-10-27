import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../../core/supabase.dart';
import '../books/book.dart';
import '../books/book_cover.dart';
import '../loans/loan.dart';
import '../loans/request_loan_sheet.dart';
import '../social/people_labels.dart';
import 'discover_repository.dart';

final _bookProvider = FutureProvider.family<Book, String>((ref, id) async {
  final row = await ref
      .watch(supabaseProvider)
      .from('books')
      .select()
      .eq('id', id)
      .single();
  return Book.fromJson(row);
});

/// "Who has this book?": friends first, then neighbors by distance, then
/// everyone else who shares publicly.
class BookHoldersScreen extends ConsumerWidget {
  const BookHoldersScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final book = ref.watch(_bookProvider(bookId)).value;
    final holders = ref.watch(bookHoldersProvider(bookId));

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              if (book != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCover(title: book.title, url: book.coverUrl, width: 90),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title, style: theme.textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(book.authors.join(', ')),
                          if (book.pageCount != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.pageCount(book.pageCount!),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              ...switch (holders) {
                AsyncData(:final value) => [
                  if (value.any((h) => h.lendable)) ...[
                    Text(
                      l10n.holdersCanLend,
                      style: theme.textTheme.titleMedium,
                    ),
                    for (final h in value.where((h) => h.lendable))
                      _HolderTile(holder: h, book: book),
                  ],
                  if (value.any((h) => !h.lendable)) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.holdersNotLending,
                      style: theme.textTheme.titleMedium,
                    ),
                    for (final h in value.where((h) => !h.lendable))
                      _HolderTile(holder: h, book: book),
                  ],
                  if (value.isEmpty) Text(l10n.holdersNone),
                ],
                AsyncError(:final error) => [Text(l10n.genericError('$error'))],
                _ => [const Center(child: CircularProgressIndicator())],
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _HolderTile extends StatelessWidget {
  const _HolderTile({required this.holder, required this.book});

  final Holder holder;
  final Book? book;

  Widget _availability(BuildContext context, AppLocalizations l10n) {
    if (holder.myLoanId != null) {
      return OutlinedButton(
        onPressed: () => context.push('/loans/${holder.myLoanId}'),
        child: Text(switch (holder.myLoanStatus) {
          LoanStatus.requested => l10n.holderRequested,
          LoanStatus.accepted => l10n.holderPromised,
          _ => l10n.holderYouHaveIt,
        }),
      );
    }
    if (holder.onLoan) return Text(l10n.holderLentOut);
    if (!holder.lendable || book == null) return Icon(holder.relationship.icon);
    return FilledButton.tonal(
      onPressed: () => showRequestLoanSheet(
        context,
        holder: holder,
        bookId: book!.id,
        bookTitle: book!.title,
      ),
      child: Text(l10n.holderAskToBorrow),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: PersonAvatar(name: holder.displayName),
      title: Text(holder.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            personSubtitle(
              l10n,
              holder.relationship,
              area: holder.areaName,
              km: holder.approxKm,
            ),
          ),
          if (holder.rating != null)
            Text(
              '★' * holder.rating! + '☆' * (5 - holder.rating!),
              semanticsLabel: l10n.detailStars(holder.rating!),
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          if (holder.review != null)
            Text(
              '“${holder.review}”',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      trailing: _availability(context, l10n),
      onTap: () => context.push('/people/${holder.ownerId}'),
    );
  }
}
