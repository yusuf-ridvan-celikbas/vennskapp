import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/discover/discover_screen.dart';
import '../features/library/shelf_screen.dart';
import '../features/loans/loans_screen.dart';
import '../features/me/me_screen.dart';
import '../features/shell/home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/shelf',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/shelf', builder: (_, __) => const ShelfScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/discover', builder: (_, __) => const DiscoverScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/loans', builder: (_, __) => const LoansScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/me', builder: (_, __) => const MeScreen()),
          ]),
        ],
      ),
    ],
  );
});
