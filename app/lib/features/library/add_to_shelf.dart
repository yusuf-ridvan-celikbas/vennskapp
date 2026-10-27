import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../books/book.dart';
import 'library_item.dart';
import 'library_repository.dart';

enum AddResult { added, duplicate, failed }

/// Adds [candidate] to the shelf and shows a snackbar. With [undoable], the
/// snackbar offers Undo (used by bulk scanning).
Future<(AddResult, LibraryItem?)> addToShelf(
  BuildContext context,
  WidgetRef ref,
  BookCandidate candidate, {
  bool undoable = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final repo = ref.read(libraryRepositoryProvider);
  try {
    final item = await repo.add(candidate);
    ref.invalidate(myShelfProvider);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.addedToShelf(candidate.title)),
          action: undoable
              ? SnackBarAction(
                  label: l10n.undo,
                  onPressed: () async {
                    await repo.remove(item.id);
                    ref.invalidate(myShelfProvider);
                  },
                )
              : null,
        ),
      );
    return (AddResult.added, item);
  } on AlreadyOnShelf {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.alreadyOnShelf(candidate.title))),
      );
    return (AddResult.duplicate, null);
  } catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.genericError('$e'))));
    return (AddResult.failed, null);
  }
}
