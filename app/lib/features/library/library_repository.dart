import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import '../books/book.dart';
import 'library_item.dart';

/// Thrown when the user already has this book on their shelf.
class AlreadyOnShelf implements Exception {
  const AlreadyOnShelf();
}

class LibraryRepository {
  LibraryRepository(this._db);

  final SupabaseClient _db;

  static const _select = '*, books(*)';

  Future<List<LibraryItem>> myShelf(String userId) async {
    final rows = await _db
        .from('library_items')
        .select(_select)
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
    return rows.map(LibraryItem.fromJson).toList();
  }

  Future<LibraryItem> item(String id) async {
    final row = await _db
        .from('library_items')
        .select(_select)
        .eq('id', id)
        .single();
    return LibraryItem.fromJson(row);
  }

  /// Adds the book to the catalog (if needed) and to the user's shelf.
  Future<LibraryItem> add(BookCandidate candidate) async {
    final bookId = await _db.rpc(
      'upsert_book',
      params: {'book': candidate.toJson()},
    );
    try {
      final row = await _db
          .from('library_items')
          .insert({'book_id': bookId})
          .select(_select)
          .single();
      return LibraryItem.fromJson(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw const AlreadyOnShelf();
      rethrow;
    }
  }

  Future<void> update(String id, LibraryItemChanges changes) async {
    final body = changes.toJson();
    if (body.isEmpty) return;
    await _db.from('library_items').update(body).eq('id', id);
  }

  Future<void> remove(String id) =>
      _db.from('library_items').delete().eq('id', id);
}

final libraryRepositoryProvider = Provider(
  (ref) => LibraryRepository(ref.watch(supabaseProvider)),
);

final myShelfProvider = FutureProvider<List<LibraryItem>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];
  return ref.watch(libraryRepositoryProvider).myShelf(userId);
});

final libraryItemProvider = FutureProvider.family<LibraryItem, String>(
  (ref, id) => ref.watch(libraryRepositoryProvider).item(id),
);
