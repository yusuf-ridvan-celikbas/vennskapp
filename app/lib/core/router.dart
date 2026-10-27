import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/discover/discover_screen.dart';
import '../features/library/shelf_screen.dart';
import '../features/loans/loans_screen.dart';
import '../features/me/me_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/home_shell.dart';
import 'auth_stage.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final stage = ValueNotifier(ref.read(authStageProvider));
  ref.listen(authStageProvider, (_, next) => stage.value = next);
  ref.onDispose(stage.dispose);

  return GoRouter(
    initialLocation: '/shelf',
    refreshListenable: stage,
    redirect: (context, state) {
      final here = state.matchedLocation;
      final target = switch (stage.value) {
        AuthStage.loading => '/loading',
        AuthStage.signedOut => '/welcome',
        AuthStage.needsOnboarding => '/onboarding',
        AuthStage.ready => null,
      };
      if (target != null) return here == target ? null : target;
      // Ready: leave the gate screens for the app.
      const gates = {'/loading', '/welcome', '/onboarding'};
      return gates.contains(here) ? '/shelf' : null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/welcome', builder: (_, _) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/shelf', builder: (_, _) => const ShelfScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (_, _) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/loans', builder: (_, _) => const LoansScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/me', builder: (_, _) => const MeScreen())],
          ),
        ],
      ),
    ],
  );
});
