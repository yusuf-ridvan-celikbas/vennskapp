import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final _authChangesProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange,
);

/// The signed-in user's id, or null. Rebuilds on every auth change.
final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(_authChangesProvider);
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});
