import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import 'app_notification.dart';

class NotificationsRepository {
  NotificationsRepository(this._db);

  final SupabaseClient _db;

  /// My latest notifications, updated live through Supabase Realtime.
  Stream<List<AppNotification>> watch(String userId) => _db
      .from('notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(50)
      .map((rows) => rows.map(AppNotification.fromJson).toList());

  /// Marks [ids] as read, or all of them when null.
  Future<void> markRead([List<String>? ids]) =>
      _db.rpc('mark_notifications_read', params: {'ids': ids});
}

final notificationsRepositoryProvider = Provider(
  (ref) => NotificationsRepository(ref.watch(supabaseProvider)),
);

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(notificationsRepositoryProvider).watch(userId);
});

final unreadNotificationsProvider = Provider<int>(
  (ref) =>
      ref.watch(notificationsProvider).value?.where((n) => n.unread).length ??
      0,
);
