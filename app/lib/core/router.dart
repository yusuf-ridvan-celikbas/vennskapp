import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/discover/book_holders_screen.dart';
import '../features/discover/discover_screen.dart';
import '../features/library/item_detail_screen.dart';
import '../features/library/manual_book_screen.dart';
import '../features/library/scan_screen.dart';
import '../features/library/search_book_screen.dart';
import '../features/library/shelf_screen.dart';
import '../features/loans/loan_detail_screen.dart';
import '../features/loans/loans_screen.dart';
import '../features/me/me_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/home_shell.dart';
import '../features/social/friends_screen.dart';
import '../features/social/person_screen.dart';
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
      const gates = {'/loading', '/welcome', '/onboarding'};
      // Remember where the user was heading (e.g. after a page reload) so
      // they land there once signed in, instead of on the shelf.
      final from = gates.contains(here)
          ? state.uri.queryParameters['from']
          : state.uri.toString();
      if (target != null) {
        if (here == target) return null;
        return from == null || from == '/shelf'
            ? target
            : Uri(path: target, queryParameters: {'from': from}).toString();
      }
      return gates.contains(here) ? (from ?? '/shelf') : null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/welcome', builder: (_, _) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/people/:id',
        builder: (_, state) =>
            PersonScreen(userId: state.pathParameters['id']!),
      ),
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
                routes: [
                  GoRoute(
                    path: 'book/:id',
                    parentNavigatorKey: _rootKey,
                    builder: (_, state) =>
                        BookHoldersScreen(bookId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/loans',
                builder: (_, _) => const LoansScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootKey,
                    builder: (_, state) =>
                        LoanDetailScreen(loanId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                builder: (_, _) => const MeScreen(),
                routes: [
                  GoRoute(
                    path: 'friends',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const FriendsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
