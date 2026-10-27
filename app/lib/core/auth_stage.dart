import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/profile/profile_repository.dart';
import 'supabase.dart';

enum AuthStage { loading, signedOut, needsOnboarding, ready }

/// Where the user is in the sign-in journey; drives router redirects.
final authStageProvider = Provider<AuthStage>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return AuthStage.signedOut;
  final profile = ref.watch(myProfileProvider);
  return switch (profile) {
    AsyncData(:final value) when value != null && value.isComplete =>
      AuthStage.ready,
    AsyncData() || AsyncError() => AuthStage.needsOnboarding,
    _ => AuthStage.loading,
  };
});
