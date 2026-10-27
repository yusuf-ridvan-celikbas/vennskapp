import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import '../library/library_item.dart';
import 'person.dart';

enum FriendRequestResult { pending, accepted, notFound, isMe }

class SocialRepository {
  SocialRepository(this._db);

  final SupabaseClient _db;

  /// null when the person does not exist or has blocked the viewer.
  Future<Person?> person(String id) async {
    final rows = await _db.rpc('get_person', params: {'target': id}) as List;
    return rows.isEmpty
        ? null
        : Person.fromJson(rows.first as Map<String, dynamic>);
  }

  Future<List<PeopleEntry>> myPeople() async {
    final rows = await _db.rpc('my_people') as List;
    return rows.cast<Map<String, dynamic>>().map(PeopleEntry.fromJson).toList();
  }

  Future<FriendRequestResult> sendRequest(String username) async {
    try {
      final status = await _db.rpc(
        'send_friend_request',
        params: {'target_username': username},
      ) as String;
      return status == 'accepted'
          ? FriendRequestResult.accepted
          : FriendRequestResult.pending;
    } on PostgrestException catch (e) {
      if (e.code == 'P0002') return FriendRequestResult.notFound;
      if (e.code == '22023') return FriendRequestResult.isMe;
      rethrow;
    }
  }

  Future<void> respond(String friendshipId, {required bool accept}) => _db.rpc(
    'respond_friend_request',
    params: {'request_id': friendshipId, 'accept': accept},
  );

  /// Unfriend, or cancel a request I sent.
  Future<void> removeFriendship(String otherUserId) =>
      _db.rpc('remove_friendship', params: {'other_user': otherUserId});

  Future<void> block(String userId) =>
      _db.rpc('block_user', params: {'target': userId});

  Future<void> unblock(String userId) =>
      _db.rpc('unblock_user', params: {'target': userId});

  /// The books of [userId] that the viewer may see (RLS filters the rest).
  Future<List<LibraryItem>> shelfOf(String userId) async {
    final rows = await _db
        .from('library_items')
        .select('*, books(*)')
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
    return rows.map(LibraryItem.fromJson).toList();
  }
}

final socialRepositoryProvider = Provider(
  (ref) => SocialRepository(ref.watch(supabaseProvider)),
);

final personProvider = FutureProvider.family<Person?, String>(
  (ref, id) => ref.watch(socialRepositoryProvider).person(id),
);

final personShelfProvider = FutureProvider.family<List<LibraryItem>, String>(
  (ref, id) => ref.watch(socialRepositoryProvider).shelfOf(id),
);

final myPeopleProvider = FutureProvider<List<PeopleEntry>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(socialRepositoryProvider).myPeople();
});

/// Refresh everything that depends on friendships/blocks after a change.
void invalidateSocial(WidgetRef ref, [String? personId]) {
  ref.invalidate(myPeopleProvider);
  if (personId != null) {
    ref.invalidate(personProvider(personId));
    ref.invalidate(personShelfProvider(personId));
  }
}
