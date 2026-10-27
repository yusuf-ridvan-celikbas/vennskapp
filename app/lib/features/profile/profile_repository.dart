import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import 'profile.dart';

class ProfileRepository {
  ProfileRepository(this._db);

  final SupabaseClient _db;

  Future<Profile?> fetch(String userId) async {
    final row =
        await _db.from('profiles').select().eq('id', userId).maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<void> completeOnboarding({
    required String userId,
    required String username,
    required String displayName,
    required VisibilityLevel defaultVisibility,
    required double lat,
    required double lon,
    required String areaName,
  }) async {
    await _db.from('profiles').update({
      'username': username,
      'display_name': displayName,
      'default_visibility': defaultVisibility.name,
    }).eq('id', userId);
    await _db.rpc('set_home_location',
        params: {'lat': lat, 'lon': lon, 'area': areaName});
  }
}

final profileRepositoryProvider =
    Provider((ref) => ProfileRepository(ref.watch(supabaseProvider)));

final myProfileProvider = FutureProvider<Profile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(profileRepositoryProvider).fetch(userId);
});
