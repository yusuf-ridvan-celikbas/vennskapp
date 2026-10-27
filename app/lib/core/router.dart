import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/discover/discover_screen.dart';
import '../features/library/item_detail_screen.dart';
import '../features/library/manual_book_screen.dart';
import '../features/library/scan_screen.dart';
import '../features/library/search_book_screen.dart';
import '../features/library/shelf_screen.dart';
import '../features/loans/loans_screen.dart';
import '../features/me/me_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/home_shell.dart';
import 'auth_stage.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final stage = ValueNotifier(ref.read(authStageProvider));
  ref.listen(authStageProvider, (_, next) => stage.value = next);
  ref.onDispose(stage.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
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
              GoRoute(
                path: '/shelf',
                builder: (_, _) => const ShelfScreen(),
                routes: [
                  // Full-screen pages above the tab bar.
                  GoRoute(
                    path: 'add/search',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const SearchBookScreen(),
                  ),
                  GoRoute(
                    path: 'add/scan',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const ScanScreen(),
                  ),
                  GoRoute(
                    path: 'add/manual',
                    parentNavigatorKey: _rootKey,
                    builder: (_, state) => ManualBookScreen(
                      isbn: state.uri.queryParameters['isbn'],
                    ),
                  ),
                  GoRoute(
                    path: 'item/:id',
                    parentNavigatorKey: _rootKey,
                    builder: (_, state) =>
                        ItemDetailScreen(itemId: state.pathParameters['id']!),
                  ),
                ],
              ),
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
