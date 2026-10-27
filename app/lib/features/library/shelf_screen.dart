import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../shell/empty_state.dart';

class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabShelf)),
      body: EmptyState(
        icon: Icons.auto_stories,
        title: l10n.shelfEmptyTitle,
        body: l10n.shelfEmptyBody,
      ),
    );
  }
}
