import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import '../library/library_item.dart';
import '../social/person.dart';

/// A book that people the viewer can see own, with counts per group.
class DiscoverBook {
  const DiscoverBook({
    required this.bookId,
    required this.title,
    required this.authors,
    required this.friends,
    required this.neighbors,
    required this.others,
    required this.lendable,
    this.coverUrl,
    this.pageCount,
    this.publishedYear,
  });

  final String bookId;
  final String title;
  final List<String> authors;
  final int friends;
  final int neighbors;
  final int others;
  final int lendable;
  final String? coverUrl;
  final int? pageCount;
  final int? publishedYear;

  factory DiscoverBook.fromJson(Map<String, dynamic> json) => DiscoverBook(
    bookId: json['book_id'] as String,
    title: json['title'] as String,
    authors: (json['authors'] as List).cast<String>(),
    friends: json['friends'] as int,
    neighbors: json['neighbors'] as int,
    others: json['others'] as int,
    lendable: json['lendable'] as int,
    coverUrl: json['cover_url'] as String?,
    pageCount: json['page_count'] as int?,
    publishedYear: json['published_year'] as int?,
  );
}

/// Someone who has a copy of a book, as the viewer may see them.
class Holder {
  const Holder({
    required this.itemId,
    required this.ownerId,
    required this.username,
    required this.displayName,
    required this.relationship,
    required this.lendable,
    required this.status,
    this.areaName,
    this.approxKm,
    this.rating,
    this.review,
  });

  final String itemId;
  final String ownerId;
  final String username;
  final String displayName;
  final Relationship relationship;
  final bool lendable;
  final ReadingStatus status;
  final String? areaName;
  final int? approxKm;
  final int? rating;
  final String? review;

  factory Holder.fromJson(Map<String, dynamic> json) => Holder(
    itemId: json['item_id'] as String,
    ownerId: json['owner_id'] as String,
    username: json['username'] as String,
    displayName: json['display_name'] as String,
    relationship: Relationship.fromDb(json['relationship'] as String),
    lendable: json['lendable'] as bool,
    status: ReadingStatus.values.byName(json['status'] as String),
    areaName: json['area_name'] as String?,
    approxKm: json['approx_km'] as int?,
    rating: json['rating'] as int?,
    review: json['review'] as String?,
  );
}

class DiscoverRepository {
  DiscoverRepository(this._db);

  final SupabaseClient _db;

  Future<List<DiscoverBook>> books(String query) async {
    final rows =
        await _db.rpc('discover_books', params: {'query': query}) as List;
    return rows
        .cast<Map<String, dynamic>>()
        .map(DiscoverBook.fromJson)
        .toList();
  }

  Future<List<Holder>> holders(String bookId) async {
    final rows = await _db.rpc(
      'search_book_holders',
      params: {'target_book': bookId},
    ) as List;
    return rows.cast<Map<String, dynamic>>().map(Holder.fromJson).toList();
  }
}

final discoverRepositoryProvider = Provider(
  (ref) => DiscoverRepository(ref.watch(supabaseProvider)),
);

final discoverBooksProvider = FutureProvider.family<List<DiscoverBook>, String>(
  (ref, query) {
    ref.watch(currentUserIdProvider);
    return ref.watch(discoverRepositoryProvider).books(query);
  },
);

final bookHoldersProvider = FutureProvider.family<List<Holder>, String>(
  (ref, bookId) => ref.watch(discoverRepositoryProvider).holders(bookId),
);
